//
//  AddSessionTableViewController.swift
//  PokerLog
//
//  Created by Mike Mailian on 14.01.2021.
//

import UIKit
import RealmSwift

protocol RefreshViewDelegate {
    func refreshView()
}

class AddSessionTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var delegate: RefreshViewDelegate?
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var pokerTypeSegment: UISegmentedControl!
    @IBOutlet var gameTypeSegment: UISegmentedControl!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var moneyInTextField: UITextField!
    @IBOutlet var moneyOutTextField: UITextField!
    @IBOutlet var timePlayedTextField: UITextField!
    @IBOutlet var commentTextView: UITextView!
    
    var date = Date()
    let dateFormatter = DateFormatter()
    let realm = try! Realm()
    let sessionCard = SessionCard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Background.png"))
        
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.white.cgColor
        commentTextView.layer.cornerRadius = 5
        commentTextView.text = NSLocalizedString("comment", comment: "")
        commentTextView.textColor = .lightGray
    
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.cgColor

        moneyInTextField?.delegate = self
        moneyOutTextField.delegate = self
        timePlayedTextField.delegate = self
        commentTextView.delegate = self

        moneyInTextField.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
        moneyOutTextField.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
        timePlayedTextField.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )

        // Date formatter settings
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "dd/MM/yyyy"

        // Making segmented control text color = white
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        pokerTypeSegment.setTitleTextAttributes(titleTextAttributes, for: .normal)
        gameTypeSegment.setTitleTextAttributes(titleTextAttributes, for: .normal)

        // Makind date picker local
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        if moneyInTextField.text == "" || moneyOutTextField.text == "" || timePlayedTextField.text == ""{
            saveButton.isEnabled = false;
            saveButton.alpha = 0.5;
        } else{
            saveButton.isEnabled = true;
            saveButton.alpha = 1.0;

        }
    }
    
    
    // Textfield input lenght
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 0
        if textField == moneyInTextField {
            maxLength = 6
        } else if textField == moneyOutTextField {
            maxLength = 6
        } else if textField == timePlayedTextField {
            maxLength = 2
        }
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    
    //Comment view inut lenght
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""

           // attempt to read the range they are trying to change, or exit if we can't
           guard let stringRange = Range(range, in: currentText) else { return false }

           // add their new text to the existing text
           let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

           // make sure the result is under 16 characters
           return updatedText.count <= 150
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "e.g. Running hot today 🔥" {
            textView.text = ""
            textView.textColor = .white
        }
    }
    

    // Save input data for Session card tableview
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        date = datePicker.date
        
        try! realm.write() {
            sessionCard.pokerType = pokerTypeSegment.titleForSegment(at: pokerTypeSegment.selectedSegmentIndex)!
            sessionCard.gameType = gameTypeSegment.titleForSegment(at: gameTypeSegment.selectedSegmentIndex)!
            sessionCard.date = dateFormatter.string(from: date)
            sessionCard.moneyIn = Int(moneyInTextField.text!) ?? 0
            sessionCard.moneyOut = Int(moneyOutTextField.text!) ?? 0
            sessionCard.timePlayed = Int(timePlayedTextField.text!) ?? 0
            sessionCard.profit = sessionCard.moneyOut - sessionCard.moneyIn
            sessionCard.sortDate = date
            sessionCard.comment = commentTextView.text
            
            realm.add(sessionCard)
        }
        delegate?.refreshView()
        dismiss(animated: true, completion: nil)
    }
    
    
}
