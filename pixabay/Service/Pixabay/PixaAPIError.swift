//
//  PixabayServiceError.swift
//  pixabay
//
//  Created by Xuwei Liang on 1/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//
import Foundation

let SuccessHTTPStatusCode: Int = 200

/// PixabayService API errors
enum PixaAPIError: Error {
    case invalidURL
    case invalidParams
    case genericError
}

extension PixaAPIError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidParams:
            return "Invalid request parameters"
        case .genericError:
            return "Error has occurred, please try again later"
        }
    }
}

extension PixaAPIError: Equatable {
    static func == (lhs: PixaAPIError, rhs: PixaAPIError)-> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}
