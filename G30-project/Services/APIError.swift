//
//  APIError.swift
//  G30-project
//
//  Created by Gia Nagpal on 2026-03-13.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case noData
}
