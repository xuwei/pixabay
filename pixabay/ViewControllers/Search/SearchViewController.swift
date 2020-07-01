//
//  ViewController.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
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
    
    func setupTableView() {
        
        guard self.tableView != nil else { return }
        
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.data[indexPath.row]
        let cell: ImageViewCell = tableView.dequeueReusableCell(withIdentifier: cellModel.identifier, for: indexPath) as! ImageViewCell
        cell.setupUI(cellModel)
        
        /// loading image from tableviewcontroller, to handle scenario where cells are already scrolled passed and we want to determine if we still apply the fetched image
        ImageLoader.shared.loadImage(from: cellModel.imageUrl) { image in
            guard let img = image else { return }
            DispatchQueue.main.async {
                if let existingCell = tableView.cellForRow(at: indexPath) as? ImageViewCell {
                    existingCell.cellImage.image = img
                }
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if viewModel.needMore(for: indexPath.row) {
                viewModel.loadMore { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let err):
                        self.alertError(with: err)
                    case .success:
                        self.refresh()
                    }
                }
                
                /// no need to check further once we know we need to load more
                return
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        viewModel.search(text) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.refresh()
            case .failure(let err):
                self.alertError(with: err)
            }
        }
    }
}

