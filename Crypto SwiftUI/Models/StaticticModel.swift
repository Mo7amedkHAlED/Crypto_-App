//
//  StaticsModel.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 24/11/2023.
//

import Foundation

struct StaticticModel: Identifiable {
    let id = UUID().uuidString
    let title: String
    let value: String
    let percentageChange: Double?
    
    init(title: String, value: String, percentageChange: Double? = nil) {
        self.title = title
        self.value = value
        self.percentageChange = percentageChange
    }
}

let newModel = StaticticModel(title: "", value: "", percentageChange: 45)
let secondModel = StaticticModel(title: "", value: "")
