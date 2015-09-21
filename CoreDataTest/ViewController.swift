//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import UIKit
import DataCoordinator

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var dataCordinator : DataCoordinator!
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataCordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).dataCoordinator
        
        
        getUsers()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func getUsers() {
        users = dataCordinator.allObjectsOfClass(User) as! [User]
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let dateString = dateFormatter.stringFromDate(users[indexPath.row].clientCreatedAt)
        cell.textLabel!.text = dateString
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DataSource.sharedInstance.deleteObjects([users[indexPath.row]])
        getUsers()
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        let newUser: User = User()
        newUser.firstName = "Adam"
        DataSource.sharedInstance.saveObjects([newUser])
        getUsers()
    }

    @IBAction func resetButtonPressed(sender: AnyObject) {
        DataSource.sharedInstance.resetCoreData()
    }
    
    @IBAction func cleanButtonPressed(sender: AnyObject) {
        if DataSource.sharedInstance.cleanCoreData() {
            getUsers()
        }
    }
}

