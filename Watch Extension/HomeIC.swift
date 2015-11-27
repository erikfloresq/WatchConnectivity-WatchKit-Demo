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
    //var flagTable = true
    
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
        
        tableView.setNumberOfRows(items.count, withRowType: "homeItemRow")
        for index in 0..<tableView.numberOfRows {
            if let rowController = tableView.rowControllerAtIndex(index) as? HomeItemRow {
                rowController.lblItem.setText(items[index])
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        setupTable()
        print("item count \(items.count)")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
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
                self.setupTable()
            }
            if let itemValue = message["item"] as? Int {
                self.items.removeAtIndex(itemValue)
                self.setupTable()
            }
        }
    }
    
    /*func session(session: WCSession, didReceiveUserInfo applicationContext: [String : AnyObject]) {
    print("string: \(applicationContext)")
    self.items = (applicationContext["appContext"] as? Array)!
    self.setupTable()
    }*/
    
    /*func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("receive \(applicationContext)")
        
        if self.flagTable == true {
            self.items = (applicationContext["appContext"] as? Array)!
            self.setupTable()
            self.flagTable = false
        }
    }*/
    
    
    
}
