//
//  SavedCity.swift
//  G30-project
//
//  Created by Gia Nagpal on 2026-03-13.
//

import Foundation

struct SavedCity: Identifiable {
    let id: Int
    let cityName: String
    let province: String
    let country: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
}
