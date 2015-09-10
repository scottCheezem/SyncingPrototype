//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import UIKit
import CoreData
import DataCoordinator

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUsers()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUsers() {
        users = DataSource.sharedInstance.allObjectsOfClass(User.self) as! [User]
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = users[indexPath.row].firstName as String!
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DataSource.sharedInstance.deleteObjects([users[indexPath.row]])
        getUsers()
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        let newUser: User = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: CoreDataManager.shared.managedObjectContext) as! User
        newUser.firstName = "Adam"
        DataSource.sharedInstance.saveObjects([newUser])
        getUsers()
    }

}

