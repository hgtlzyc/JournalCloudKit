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
    case nilRecordsreceived
    case unableToModifyEntry
}

class EntryController {
    
    static let shared = EntryController()
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - SOT
    var entries = Set<Entry>()
    
    // MARK: - CRUD Functions
    //create
    func createEntryWith(title: String, body: String, completion: @escaping(Result<Entry, EntryError>) -> Void ) {
        
        let newEntry = Entry(title: title, body: body)
        
        entries.insert(newEntry)
        
        save(entry: newEntry, completion: completion)
    }
    
    //read
    func fetchEntries(completion: @escaping(Result<[Entry],EntryError>) -> Void ) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.recordType, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                return completion( .failure( .unableToFetchEntry(error) ) )
            }
            
            guard let records = records else {
                print("nil data in \(#function) in line \(#line)")
                return completion(.failure(.nilRecordsreceived))
            }
            
            let validEntries = records.compactMap{ Entry(ckRecord: $0) }
            
            self.entries.formUnion( Set(validEntries) )
            
            completion(.success(validEntries))
            
            if validEntries.count != records.count {
                print("nil entry in \(#function) in line \(#line)")
            }

        }///End Of call back
        
    }///End Of fetchEntries
    
    //update
    func updateEntry(entry: Entry, completion: @escaping (Result<[CKRecord], EntryError>) -> Void ) {
        let ckRecord = CKRecord(entry: entry)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [ckRecord], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInitiated
        
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                return completion( .failure(.notAbleToSaveEntry(error)) )
            }
            guard let records = records else { return completion(.failure(.nilRecordsreceived)) }
            return completion(.success(records))
            
        }
        
        privateDB.add(operation)
        
    }///End Of UpdateEntry
    
    
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
