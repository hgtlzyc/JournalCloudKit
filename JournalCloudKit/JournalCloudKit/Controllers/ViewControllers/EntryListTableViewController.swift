//
//  EntryListTableViewController.swift
//  JournalCloudKit
//
//  Created by lijia xu on 8/9/21.
//

import UIKit

class EntryListTableViewController: UITableViewController {

    var entries: [Entry] = []

    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fullFetchEntries()
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let targetVC = segue.destination as? EntryDetailViewController else {
            print("Returned from prepare for segue \(#line)")
            return
        }
        
        targetVC.delegate = self
        
        if segue.identifier == "toDetailVC" {
            guard let selectedEntryPath = tableView.indexPathForSelectedRow else { return }
            
            let selectedEntry = entries[selectedEntryPath.row]
            targetVC.entry = selectedEntry
            
        }
        
    }///End Of prepare

}///End Of EntryListVC

// MARK: - Table view data source
extension EntryListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        let selectedEntry = entries[indexPath.row]
        
        cell.textLabel?.text = selectedEntry.title
        cell.detailTextLabel?.text = "\(selectedEntry.timestamp)"
        
        return cell
    }
    
}///End Of Extension

// MARK: - Fetch Data
extension EntryListTableViewController {
    
    func fullFetchEntries() {
        EntryController.shared.fetchEntries { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    guard let sortedEntries = self?.generateSortedArray(Set(entries)) else { return }
                    self?.entries = sortedEntries
                    self?.tableView.reloadData()
                    
                case .failure(let err):
                    print(err)
                
                }
                
            }///End Of dispatch
            
        }///End Of callback
        
    }///End Of fetchEntries
    
    func updateEntriesFromLocalSOT() {
        entries = generateSortedArray()
        tableView.reloadData()
    }
    
    func generateSortedArray(
        _ entriesSet: Set<Entry> = EntryController.shared.entries
        ) -> [Entry] {
        
        return entriesSet.sorted{ $0.timestamp > $1.timestamp}
        
    }
    
}///End Of Extension

// MARK: - DetailVC Delagate

extension EntryListTableViewController: EntryDetailDelegate {
    func performReload(isPartial: Bool) {
        guard !isPartial else { updateEntriesFromLocalSOT(); return }
        
        fullFetchEntries()
    }
    
}///End Of Extension
