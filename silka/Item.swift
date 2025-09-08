//
//  Item.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
