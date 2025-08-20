//
//  Color+Ext.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//

import UIKit

extension Color {
    init(named: String) {
        guard let rgba = UIColor(named: named)?.rgba else {
            fatalError("No color named \(named)")
        }
        self = Color(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}
