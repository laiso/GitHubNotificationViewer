//
//  MasterViewController.swift
//  GitHubNotificationViewer
//
//  Copyright © 2016 laiso. All rights reserved.
//

import UIKit
import SafariServices

class MasterViewController: UITableViewController {
    var items: [NotificationItem] = [NotificationItem]()
    var github = GitHub()

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = items[indexPath.row]
        cell.textLabel!.text = object.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let
            indexPath = self.tableView.indexPathForSelectedRow,
            url = items[indexPath.row].URL
        {
            let safari = SFSafariViewController(URL: url)
            self.presentViewController(safari, animated: true, completion: nil)
        }
    }
    
    // MARK: -
    
    func onRefresh() {
        github.loadNotifications { (error, notifications) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let items = notifications {
                    self.items = items
                }
                
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction
    func onSignInButton() {
        github.authorizeWithViewController(self) { () -> Void in
            self.onRefresh()
        }
    }
    
}

