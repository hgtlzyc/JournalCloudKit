//
//  EntryController.swift
//  JournalCloudKit
//
//  Created by lijia xu on 8/9/21.
//

import CloudKit

enum EntryError: LocalizedError {
    case notAbleToSaveEntry(Error)
    case unableToConvertToEntry
    case unableToFetchEntry(Error)
    case nilRecord
}

class EntryController {
    
    static let shared = EntryController()
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD Functions
    //create
    func createEntryWith(title: String, body: String, completion: @escaping(Result<Entry, EntryError>) -> Void ) {
        
        let newEntry = Entry(title: title, body: body)
        
        save(entry: newEntry, completion: completion)
    }
    
    //read
    func fetchEntriesWith(completion: @escaping(Result<[Entry],EntryError>) -> Void ) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.recordType, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                return completion( .failure( .unableToFetchEntry(error) ) )
            }
            
            guard let records = records else {
                return completion(.failure(<#T##EntryError#>))
            }
            
            
        }
        
    }///End Of fetchEntries
    
    
    //save
    private func save(entry: Entry, completion: @escaping (Result<Entry, EntryError>) -> Void ) {
        
        let newCKRecord = CKRecord(entry: entry)
        
        privateDB.save(newCKRecord) { record, error in
            if let error = error {
                return completion(.failure(.notAbleToSaveEntry(error)))
            }
            
            guard let record = record,
                  let newEntry = Entry(ckRecord: record) else {
                print("unable convert \(#function) in line \(#line)")
                return completion(.failure(.unableToConvertToEntry))
            }
    
            completion(.success(newEntry))
            
        }///End Of call back
        
        
    }///End Of save(entry..
    
    
    
    // MARK: - Private init
    private init() {}
    
}///End Of class
