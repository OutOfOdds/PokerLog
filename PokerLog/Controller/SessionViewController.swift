//
//  ViewController.swift
//  WinRateApp
//
//  Created by Mike Mailian on 07.11.2020.
//

import UIKit
import Foundation
import RealmSwift

class SessionViewController: BackgroundViewController, RefreshViewDelegate, UITextViewDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addSessionButton: UIBarButtonItem!
    @IBOutlet var addSessionLabelImage: UIImageView!
    @IBOutlet var addSessionLabel: UILabel!
    @IBOutlet var filterButton: UIBarButtonItem!
    
    @IBOutlet var emptyEmoji: UILabel!
    @IBOutlet var noDataLabel: UILabel!
    @IBOutlet var tapLabel: UILabel!
    @IBOutlet var suitLabel: UILabel!

    
    func refreshView() {
        if realm.objects(SessionCard.self).count != 0 {
            hideHints()
        }
        tableView.reloadData()
    }
    
    var sessionCards: Results<SessionCard>!
    var sessionViewCell = SessionTableViewCell()
    let sessionCard = SessionCard()
    
    var selectedIndex = IndexPath(row: -1, section: 0)
    var cellIsOpen = false

    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if realm.objects(SessionCard.self).count != 0 {
            hideHints()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        // Large title
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // Light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // load Realm Data and sorting by date
    func loadData() {
        sessionCards = realm.objects(SessionCard.self).sorted(byKeyPath: "sortDate", ascending: false)
        
    }
    
    // Prepare fo segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! AddSessionTableViewController
        viewController.delegate = self
    }
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
                
        let filterController = UIAlertController(title: NSLocalizedString("sort_title", comment: ""), message: "", preferredStyle: .actionSheet)
        
        filterController.overrideUserInterfaceStyle = UIUserInterfaceStyle.light

        func showFilteredData(month: Int) {
            let currentDate = Calendar.current.date(byAdding: .minute, value: 1, to: sessionCard.sortDate)!
            let lastMounthCount = Calendar.current.date(byAdding: .month, value: month, to: currentDate)!
            self.sessionCards = self.realm.objects(SessionCard.self).sorted(byKeyPath: "sortDate", ascending: false).filter("sortDate BETWEEN {%@, %@}", lastMounthCount, currentDate)
            self.tableView.reloadData()
        }
        let action = UIAlertAction(title: "1M", style: .default) { (action) in
            showFilteredData(month: -1)
            self.filterButton.title = NSLocalizedString("1_m", comment: "")
        }
        let action2 = UIAlertAction(title: "3M", style: .default) { (action) in
            showFilteredData(month: -3)
            self.filterButton.title = NSLocalizedString("3_m", comment: "")
        }
        let action3 = UIAlertAction(title: "6M", style: .default) { (action) in
            showFilteredData(month: -6)
            self.filterButton.title = NSLocalizedString("6_m", comment: "")
        }
        let action4 = UIAlertAction(title: NSLocalizedString("1_y1", comment: ""), style: .default) { (action) in
            showFilteredData(month: -12)
            self.filterButton.title = NSLocalizedString("1_y", comment: "")
        }
        let action5 = UIAlertAction(title: NSLocalizedString("all1", comment: ""), style: .default) { (action) in
            self.loadData()
            self.tableView.reloadData()
            self.filterButton.title = NSLocalizedString("all", comment: "")
        }
        let action6 = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action) in
        }
        
        filterController.addAction(action)
        filterController.addAction(action2)
        filterController.addAction(action3)
        filterController.addAction(action4)
        filterController.addAction(action5)
        filterController.addAction(action6)

        present(filterController, animated: true, completion: nil)
    }
    
    
    func hideHints() {
        addSessionLabel.isHidden = true
        addSessionLabelImage.isHidden = true
        emptyEmoji.isHidden = true
        noDataLabel.isHidden = true
        tapLabel.isHidden = true
        suitLabel.isHidden = true
    }
    
}

//MARK: - TABLE VIEW METHODS

extension SessionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionCards?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SessionTableViewCell
        let mySessionCard = sessionCards[indexPath.row]
        
        cell.pokerTypeLabel.text = "\(mySessionCard.pokerType)" + " / \(mySessionCard.gameType)"
        cell.dateLabel.text = mySessionCard.date
        cell.moneyInLabel.text = String(mySessionCard.moneyIn)
        cell.moneyOutLabel.text = String(mySessionCard.moneyOut)
        cell.timePlayedLabel.text = String(mySessionCard.timePlayed)
        cell.commentTextView.text = mySessionCard.comment
        
        var smile = ""
        
        let moneyIn = mySessionCard.moneyIn
        let moneyOut = mySessionCard.moneyOut
        
        if moneyOut > moneyIn  {
            cell.profitLabel.text = String("+\(moneyOut - moneyIn)")
            cell.profitLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            smile = "🥳"
        } else if moneyOut < moneyIn {
            cell.profitLabel.text = String("-\(moneyIn - moneyOut)")
            cell.profitLabel.textColor = #colorLiteral(red: 0.968627451, green: 0.3607843137, blue: 0.3921568627, alpha: 1)
            smile = "😩"
        } else {
            cell.profitLabel.text = "0"
            cell.profitLabel.textColor = #colorLiteral(red: 0.4156862745, green: 0.5254901961, blue: 0.8078431373, alpha: 1)
            smile = "😴"
        }
        
        if (sessionCards?[indexPath.row].percent)! > 0 {
            cell.percentLabel.text = String(format: "+%.1f%% \(smile)", mySessionCard.percent)
        } else {
            cell.percentLabel.text = String(format: "%.1f%% \(smile)", mySessionCard.percent)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Card delete action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (action, view, complitionHandler) in
            try! realm.write{
                realm.delete(sessionCards[indexPath.row])
            }
            tableView.reloadData()
        }
        // Transparent action view
        deleteAction.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
        deleteAction.image = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        deleteAction.image?.withTintColor(.red)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // Changing cell height to show comment section
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath && cellIsOpen == true {
            return 220
        }
        return 145
    }
    
    //Reload cell on tap action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        cellIsOpen = !cellIsOpen
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [selectedIndex], with: .none)
        tableView.endUpdates()
    }
    
    
    
    
}
