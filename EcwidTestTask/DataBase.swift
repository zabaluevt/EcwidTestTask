//
//  DataBase.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 17/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import Foundation
import RealmSwift

class DataBase {
    static var shared = DataBase()
    
    static var documentDirectoryURL: URL = {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    static var fileManager: FileManager = {
        return FileManager.default
    }()
    
    let realm: Realm
    
    private init(){
        let fileURL = DataBase.documentDirectoryURL.appendingPathComponent("dbPath", isDirectory: false)
        
        let configuration = Realm.Configuration(
            fileURL: fileURL,
            inMemoryIdentifier: nil,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: 33,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: false,
            objectTypes: nil)
        realm = try! Realm(configuration: configuration)
    }
    
    func beginEntityUpdate() {
        realm.beginWrite()
    }
    
    func commitEntityUpdate() {
        do {
            try realm.commitWrite()
            
        } catch {
            realm.cancelWrite()
            print("Не удалось сохранить данные.")
        }
    }
}
