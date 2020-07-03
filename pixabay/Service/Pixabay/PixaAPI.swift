//
//  PixabayService.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import Foundation

class PixaAPI {
    static let shared = PixaAPI()
    private init() {}
    
    private let accessKey: String = "17283384-73a4525424a81889f0f215c25"
    private let imageType: String = "photo"
    private let httpProtocol: String = "https"
    private let domain: String = "pixabay.com"
    private let urlPath: String = "/api"
    private let session: URLSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    /// calls search API
    func search(_ req: PixaAPISearchReq, completionHandler: @escaping (Result<PixaSearchResultModel, PixaAPIError>) -> Void) {
            let urlComponent: URLComponents? = generateSearchURL(req)
        
            /// ensure it's valid url
            guard let url = urlComponent?.url else {
                completionHandler(.failure(.invalidParams)); return
            }
            
            dataTask = session.dataTask(with: url) { [weak self] data, response, err in
                
                // clean up task afterward
                defer {
                    self?.dataTask = nil
                }
                
                
                /// checking if we have error
                if err != nil { completionHandler(.failure(.genericError)); return }
                
                /// checking if it's sucessful http response
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == SuccessHTTPStatusCode else {
                    completionHandler(.failure(.genericError)); return
                }
                
                /// parse response
                let resultDecoder = JSONDecoder()
                do {
                    let result: PixaSearchResultModel = try resultDecoder.decode(PixaSearchResultModel.self, from: data)
                    completionHandler(.success(result))
                } catch {
                    completionHandler(.failure(PixaAPIError.genericError)); return
                }
            }
            dataTask?.resume()
    }
    
    /// encapsulate the logic to generate search URL
    private func generateSearchURL(_ req: PixaAPISearchReq)->URLComponents? {
        
        /// ensure parameters makes sense first
        if req.keywords.isEmpty { return nil }
        if req.pageSize <= 0 { return nil }
        if req.pageNo <= 0 { return nil }

        var urlComponent = URLComponents()
        urlComponent.scheme = httpProtocol
        urlComponent.host = domain
        urlComponent.path = urlPath
        urlComponent.queryItems = [
            URLQueryItem(name: "key", value: accessKey),
            URLQueryItem(name: "q", value: req.keywords),
            URLQueryItem(name: "image_type", value: imageType),
            URLQueryItem(name: "per_page", value: String(req.pageSize)),
            URLQueryItem(name: "page", value: String(req.pageNo))
        ]
        return urlComponent
    }
}
