//
//  EntryDetailViewController.swift
//  JournalCloudKit
//
//  Created by lijia xu on 8/9/21.
//

import UIKit

protocol EntryDetailDelegate {
    func performReload(isPartial: Bool)
}


class EntryDetailViewController: UIViewController {
    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var entry: Entry?
    var delegate: EntryDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextFiled.delegate = self
        
        updateViews()
        
    }
    
    func updateViews() {
        guard let entry = entry else { return }
        titleTextFiled.text = entry.title
        bodyTextView.text = entry.body
        
    }
    @IBAction func tappedOnTheView(_ sender: UITapGestureRecognizer) {
        resignAllFirstResponders()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let titleText = titleTextFiled.text, !titleText.isEmpty,
              let bodyText = bodyTextView.text, !bodyText.isEmpty else { return }
        
        switch entry {
        case let entry?:
            entry.title = titleText
            entry.body = bodyText
            EntryController.shared.updateEntry(entry: entry) {
                [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.delegate?.performReload(isPartial: true)
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let err):
                        print(err)
                    }
                    
                }///End Of GCD
            }

        case nil:
            EntryController.shared.createEntryWith(title: titleText, body: bodyText) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.delegate?.performReload(isPartial: true)
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let err):
                        print(err)
                        
                    }///End Of switch result
                    
                }///End Of GCD
                
            }///End Of callback
            
        }///End Of switch Entry
        
    }///End Of SavebuttonTapped
    
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        titleTextFiled.text = ""
        bodyTextView.text = ""
    }
    

}///End Of DetailVC


// MARK: - UITextFieldDelegate
extension EntryDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignAllFirstResponders()
        return true
    }
    
}///End Of TextField Delegate

// MARK: - Helpers
extension EntryDetailViewController {
    
    func resignAllFirstResponders() {
        titleTextFiled.resignFirstResponder()
        bodyTextView.resignFirstResponder()
    }
    
}///End Of helpers
