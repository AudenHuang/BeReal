//
//  DataFormatter.swift
//  BeReal
//
//  Created by Auden Huang on 2/15/23.
//

import Foundation

extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}

