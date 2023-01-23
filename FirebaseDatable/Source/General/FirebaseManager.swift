//
//  FirebaseManager.swift
//
//
//  Created by 우롱차 on 2023/01/10..
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

protocol FirebaseCRUDManagerable {
    func create<T: FirebaseDatable>(_ data: T) throws
    func read<T: Decodable>(path: [String],
                            as type: T.Type,
                            completion: @escaping ((Result<T,Error>) -> Void))
    func read<T: FirebaseDatable>(_ data: T,
                                  completion: @escaping ((Result<T,Error>) -> Void))
    
    func readParent<T: FirebaseDatable>(_ data: T, completion: @escaping (Result<[T],Error>) -> Void)
    func update<T: FirebaseDatable>(updatedData: T) throws
    func update<T: Encodable>(path: [String], data: T) throws
    func delete<T: FirebaseDatable>(_ data: T)
    func delete(path: [String])
}

final class FirebaseCRUDManager: FirebaseCRUDManagerable {
    
    private var database: DatabaseReference
    static let shared: FirebaseCRUDManagerable = FirebaseCRUDManager()
    
    private init() {
        let firebaseReference = Database.database().reference()
        database = firebaseReference
    }
    
    func create<T: FirebaseDatable>(_ data: T) throws {
        
        guard let encodedValues = data.toDictionary else {
            throw FirebaseCRUDManagerError.encodedError
        }
        let taskItemRef = getReference(data: data)
        
        taskItemRef.setValue(encodedValues)
    }
    
    func read<T: Decodable>(path: [String],
                            as type: T.Type,
                            completion: @escaping ((Result<T,Error>) -> Void)) {
        let taskItemRef = getReference(array: path)
        
        taskItemRef.getData { error, dataSnapshot in
            if let error = error {
                let result: Result<T,Error> = .failure(error)
                completion(result)
                return
            }
            
            guard let dataSnapshot = dataSnapshot,
                  let encodedData = try? dataSnapshot.data(as: T.self)
            else {
                let result: Result<T,Error> = .failure(FirebaseCRUDManagerError.encodedError)
                completion(result)
                return
            }
            let result: Result<T,Error> = .success(encodedData)
            completion(result)
        }
    }
    
    func read<T: FirebaseDatable>(_ data: T,
                                  completion: @escaping ((Result<T,Error>) -> Void)) {
        
        let taskItemRef = getReference(data: data)
        
        taskItemRef.getData { error, dataSnapshot in
            if let error = error {
                let result: Result<T, Error> = .failure(error)
                completion(result)
                return
            }
            
            guard error == nil,
                  let dataSnapshot = dataSnapshot,
                  let encodedData = try? dataSnapshot.data(as: T.self)
            else {
                let result: Result<T, Error> = .failure(FirebaseCRUDManagerError.encodedError)
                completion(result)
                return
            }
            
            let result: Result<T, Error> = .success(encodedData)
            completion(result)
        }
    }
    
    func readParent<T: FirebaseDatable>(_ data: T,
                                        completion: @escaping ((Result<[T],Error>) -> Void)) {
        let taskItemRef = data.parentPath.reduce(database) { database, path in
            database.child(path)
        }
        
        taskItemRef.getData { error, dataSnapshot in
            if let error = error {
                let result: Result<[T], Error> = .failure(error)
                completion(result)
                return
            }
            
            guard let dataSnapshot = dataSnapshot,
                  let childArray = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                let result: Result<[T], Error> = .failure(FirebaseCRUDManagerError.encodedError)
                completion(result)
                return
            }
            
            let array = childArray.compactMap { child in
                try? child.data(as: T.self)
            }
            let result: Result<[T], Error> = .success(array)
            completion(result)
        }
    }
    
    func update<T: FirebaseDatable>(updatedData: T) throws {
        guard let encodedValues = updatedData.toDictionary else {
            throw FirebaseCRUDManagerError.encodedError
        }
        
        let taskItemRef = getReference(data: updatedData)
        taskItemRef.updateChildValues(encodedValues)
    }
    
    func update<T: Encodable>(path: [String], data: T) throws {
        guard let encodedValues = data.toDictionary else {
            throw FirebaseCRUDManagerError.encodedError
        }
        
        let taskItemRef = getReference(array: path)
        taskItemRef.updateChildValues(encodedValues)
    }
    
    func delete<T: FirebaseDatable>(_ data: T) {
        
        let taskItemRef = getReference(data: data)
        taskItemRef.removeValue()
    }
    
    func delete(path: [String]) {
        let taskItemRef = getReference(array: path)
        taskItemRef.removeValue()
    }
    
    private func getReference(data: FirebaseDatable) -> DatabaseReference {
        let taskItemRef = data.path.reduce(database) { database, path in
            database.child(path)
        }
        return taskItemRef
    }
    
    private func getReference(array: [String]) -> DatabaseReference {
        let taskItemRef = array.reduce(database) { database, path in
            database.child(path)
        }
        return taskItemRef
    }
}
