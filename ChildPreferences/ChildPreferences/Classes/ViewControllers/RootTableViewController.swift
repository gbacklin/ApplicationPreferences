//
//  RootTableViewController.swift
//  SimplePreference
//
//  Created by Gene Backlin on 2/24/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit

let kFirstNamePreferenceKey = "first_name_preference"
let kLastNameLPreferenceLKey = "last_name_preference"
let kAccountTypePreferenceLKey = "account_type_preference"

class RootTableViewController: UITableViewController {
    var appPreferences: AppPreferences?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl!.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
        registerForNotifications()
        getAppPreferencesFromStringBundle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Utility methods
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func getAppPreferencesFromStringBundle() {
        appPreferences = AppPreferences(ids: [kFirstNamePreferenceKey, kLastNameLPreferenceLKey, kAccountTypePreferenceLKey])
        tableView.reloadData()
        return
    }
    
    // MARK: - Selector methods
    
    @objc func appWillEnterForeground(_ notification: Notification) {
        tableView.reloadData()
    }
    
    @objc func refreshTableView() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appPreferences!.preferenceIds!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let keys: [String] = appPreferences!.preferenceIds!.sorted()
        let key: String = keys[indexPath.row]
        let value: String = appPreferences!.valueFor(key: key) as! String
        
        // Configure the cell...
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value
        
        return cell
    }

}
