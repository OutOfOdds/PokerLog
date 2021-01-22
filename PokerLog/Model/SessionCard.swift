//
//  SessionCard.swift
//  WinRateApp
//
//  Created by Mike Mailian on 10.11.2020.
//

import Foundation
import Realm
import RealmSwift

class SessionCard: Object {
 
    @objc dynamic var date: String = ""
    @objc dynamic var pokerType: String = ""
    @objc dynamic var gameType: String = ""
    @objc dynamic var moneyIn: Int = 0
    @objc dynamic var moneyOut: Int = 0
    @objc dynamic var timePlayed: Int = 0    
    @objc dynamic var sortDate: Date = Date()
    @objc dynamic var comment: String = ""

    @objc dynamic var profit: Int = 0
    
    @objc dynamic var percent: Double {
        let profit = Double(self.profit)
        return (profit / Double(moneyIn)) * 100
    }

    
}
