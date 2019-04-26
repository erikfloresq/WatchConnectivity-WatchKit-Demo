//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Erik Flores on 11/26/15.
//  Copyright © 2015 orbis. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class HomeIC: WKInterfaceController {
    
    var items = [String]()
    @IBOutlet var tableView: WKInterfaceTable!
    var defaultDataUserWatch =  UserDefaults.standard
    var session: WCSession!
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupTable()
        print("item count \(items.count)")
    }
    
    func setupTable() -> Void {
        if let itemArray = self.defaultDataUserWatch.object(forKey: "DataUserWatch") {
            self.items = itemArray as! [String]
            print("Use user default")
        }
        
        tableView.setNumberOfRows(items.count, withRowType: "homeItemRow")
        for index in 0..<tableView.numberOfRows {
            if let rowController = tableView.rowController(at: index) as? HomeItemRow {
                rowController.lblItem.setText(items[index])
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        setupTable()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
}

// MARK: - WCSessionDelegate
extension HomeIC: WCSessionDelegate {
    
    // Send Instant Messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let textValue = message["message"] as? [String] {
                //self.items.append(textValue)
                self.items = textValue
            }
            if let itemValue = message["item"] as? Int {
                self.items.remove(at: itemValue)
                
            }
            self.defaultDataUserWatch.set(self.items, forKey: "DataUserWatch")
            self.setupTable()
        }
    }
    
    // Send Messages in Background
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("string: \(applicationContext)")
        self.items = (applicationContext["appDataUser"] as? Array)!
        self.defaultDataUserWatch.set(self.items, forKey: "DataUserWatch")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
   
    
}
