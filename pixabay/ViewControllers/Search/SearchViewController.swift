//
//  ViewController.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel = SearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
        setupTableView()
        registerCells()
        enableTapToKeyboardDismiss()
    }
    
    /// at worst case, with memory warning, we clean up the cache
    override func didReceiveMemoryWarning() {
        ImageLoader.shared.clearCache()
        super.didReceiveMemoryWarning()
    }
    
    func setupTableView() {
        
        guard let tableView = self.tableView else { return }
    
        /// using automatic cell height, will calculate by intrinsic value
        tableView.estimatedRowHeight = 1
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    /// register table cells
    func registerCells() {
        guard self.tableView != nil else { return }
        let cellIdentifier = ImageViewCell.cellIdentifier
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    func showLoading() {
        noResultLabel.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        self.loadingIndicator.stopAnimating()
    }
    
    func showNoResult(_ show: Bool) {
        noResultLabel.isHidden = !show
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching
extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noResult = viewModel.data.count == 0 ? true : false
        self.showNoResult(noResult)
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = viewModel.data[indexPath.row]
        let cell: ImageViewCell = tableView.dequeueReusableCell(withIdentifier: cellModel.identifier, for: indexPath) as! ImageViewCell
        
        /// setupUI doesn't add image, but resets back to nil incase there's old image from re-used cells
        cell.setupUI(cellModel)
        
        /// loading image from tableviewcontroller is important, so we can check if cell is still around
        ImageLoader.shared.loadImage(from: cellModel.imageUrl) { image in
            DispatchQueue.main.async {
                guard let image = image else { return }
                /// checking if the cell is still in memory before assigning image, incase the cell is already deallocated
                if let existingCell = tableView.cellForRow(at: indexPath) as? ImageViewCell {
                    existingCell.cellImage.image = image
                }
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if viewModel.needMore(for: indexPath.row) {
                self.viewModel.loadMore { result in
                    ///  ensure we are back in main queue in callback
                    /// to update UI
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        switch result {
                        case .failure(let err):
                            self.showNoResult(true)
                            self.alertError(with: err)
                        case .success:
                            self.refresh()
                        }
                    }
                }
                return
            }
        }
    }
}


// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    /// apply search when text editing ended on search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        showLoading()
        viewModel.search(text) { [weak self] result in
            
            /// When we handle callback in ViewController and we want to handle UI updates
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case .success(()):
                    self.refresh()
                case .failure(let err):
                    self.alertError(with: err)
                }
            }
        }
    }
}

