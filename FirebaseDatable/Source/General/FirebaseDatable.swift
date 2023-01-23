//
//  FirebaseDatable.swift
//  FirebaseDatable
//
//  Created by 우롱차 on 2023/01/20.
//

import Foundation

protocol FirebaseDatable: Codable {
    var path: [String] { get }
}

extension FirebaseDatable {
    var parentPath: [String] {
        var array = self.path
        array.removeLast()
        return array
    }
}
