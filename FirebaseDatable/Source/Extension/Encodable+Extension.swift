//
//  Encodable+Extension.swift
//  FirebaseDatable
//
//  Created by 우롱차 on 2023/01/22.
//

extension Encodable {
    var toDictionary: [String: Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: object, options: []) else { return nil }
        guard let dictionary = jsonObject as? [String: Any] else { return nil }
        return dictionary
    }
}
