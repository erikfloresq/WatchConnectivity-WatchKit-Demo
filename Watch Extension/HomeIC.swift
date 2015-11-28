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
    var defaultDataUserWatch =  NSUserDefaults.standardUserDefaults()
    
    private let session: WCSession? = WCSession.isSupported() ?  WCSession.defaultSession() : nil
    
    override init() {
        super.init()
        session?.delegate = self
        session?.activateSession()
    }
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        setupTable()
        print("item count \(items.count)")
    }
    
    func setupTable() -> Void {
        if let itemArray = self.defaultDataUserWatch.objectForKey("DataUserWatch") {
            self.items = itemArray as! [String]
            print("Use user default")
        }
        
        tableView.setNumberOfRows(items.count, withRowType: "homeItemRow")
        for index in 0..<tableView.numberOfRows {
            if let rowController = tableView.rowControllerAtIndex(index) as? HomeItemRow {
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

// MARK: WCSessionDelegate
extension HomeIC: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        dispatch_async(dispatch_get_main_queue()) {
            if let textValue = message["message"] as? [String] {
                //self.items.append(textValue)
                self.items = textValue
            }
            if let itemValue = message["item"] as? Int {
                self.items.removeAtIndex(itemValue)
                
            }
            self.defaultDataUserWatch.setObject(self.items, forKey: "DataUserWatch")
            self.setupTable()
            
        }
    }
    
    func session(session: WCSession, didReceiveUserInfo applicationContext: [String : AnyObject]) {
        print("string: \(applicationContext)")
        self.items = (applicationContext["appDataUser"] as? Array)!
        self.defaultDataUserWatch.setObject(self.items, forKey: "DataUserWatch")
    }
   
    
}
