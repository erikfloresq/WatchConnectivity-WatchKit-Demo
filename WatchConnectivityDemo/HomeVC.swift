//
//  ViewController.swift
//  WatchConnectivityDemo
//
//  Created by Erik Flores on 11/26/15.
//  Copyright © 2015 orbis. All rights reserved.
//

import UIKit
import WatchConnectivity

class HomeVC: UIViewController, WCSessionDelegate {
    
// MARK: - Variables
    var items = [String]()
    var defaultDataUser = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
// MARK: - Watch Connection
    private var session: WCSession!
    
    private func configureWCSession() {
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    private var validSession: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureWCSession()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureWCSession()
    }

    
// MARK: Start Application
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.defaultDataUser.object(forKey: "DataUser") != nil {
            self.items = self.defaultDataUser.object(forKey: "DataUser")! as! [String]
            self.tableView.reloadData()
            self.sendData()
        }
    }
    
    // MARK: - Send Item to Watch
    @IBAction func addItem(_ sender: Any) {
        let addItemAlertController = UIAlertController(title: "Item", message: "Add Item", preferredStyle: .alert) as UIAlertController
        let addItemAlertAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) -> Void in
            let textField = addItemAlertController.textFields![0] as UITextField
            let messageText = textField.text!
            self.items.append(messageText)
            self.tableView.reloadData()
            self.sendDataToWatch(messageText: self.items)
            self.defaultDataUser.set(self.items, forKey: "DataUser")
            self.sendData()
        }
        addItemAlertController.addAction(addItemAlertAction)
        addItemAlertController.addTextField { (UITextField) -> Void in }
        self.present(addItemAlertController, animated: true) { () -> Void in }
    }

    
    func sendDataToWatch(messageText: [String]) -> Void {
        let applicationData = ["message" : messageText]
        // Send instance messages
        if let session = session, session.isReachable {
            session.sendMessage(applicationData,
                replyHandler: { replyData in
                    print(replyData)
                }, errorHandler: { error in
                    print(error)
            })
        }
    }
    
    func sendData() -> Void {
        do {
            let applicationDict = ["appDataUser":self.defaultDataUser.object(forKey: "DataUser")!]
            WCSession.default.transferUserInfo(applicationDict)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

}

// MARK: - Table View Data Source
extension HomeVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let homeTableCell = tableView.dequeueReusableCell(withIdentifier: "homeItemCell") else {
            fatalError("not a UITableViewCell")
        }
        homeTableCell.textLabel?.text = items[indexPath.row]
        return homeTableCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            let dataItem = ["item":indexPath.row]
            if let session = session, session.isReachable {
                session.sendMessage(dataItem, replyHandler: { (replayData) -> Void in
                    
                    }, errorHandler: { (error) -> Void in
                        
                })
            }
        }
    }
    
}

