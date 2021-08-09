//
//  Entry.swift
//  JournalCloudKit
//
//  Created by lijia xu on 8/9/21.
//

import CloudKit

struct EntryConstants{
    static let recordType = "Entry"
    private static let titleKey = "title"
    private static let bodyKey = "body"
    private static let timestampKey = "timestamp"
}

class Entry {
    
    let title: String
    let body: String
    let timestamp: Date
    let ckRecordID: CKRecord.ID
    
    
    internal init(title: String,
                  body: String, timestamp: Date = Date(),
                  ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString) ) {
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.ckRecordID = ckRecordID
    }
    
}///End Of Entry

extension Entry {
    
    convenience init? (ckRecord: CKRecord) {
        
        guard let title = ckRecord[EntryConstants.titleKey] as? String,
              let body =  ckRecord[EntryConstants.bodyKey] as? String,
              let timestamp = ckRecord[EntryConstants.timestampKey] as? Date else { return nil}
       
        let id = ckRecord.recordID
        
        self.init(title: title, body: body, timestamp: timestamp, ckRecordID: id )

    }
    
}///End Of Extension

extension CKRecord {
    
    convenience init(entry: Entry) {
        self.init(recordType: EntryConstants.recordType, recordID: entry.ckRecordID)
        
        self.setValuesForKeys([
            EntryConstants.titleKey: entry.title,
            EntryConstants.bodyKey: entry.body,
            EntryConstants.timestampKey: entry.timestamp
        ])
    }
    
}///End Of Extension

