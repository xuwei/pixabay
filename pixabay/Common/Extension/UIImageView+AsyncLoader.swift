//
//  UIImageView+AsyncLoader.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session: URLSession = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        dataTask.resume()
    }
}
