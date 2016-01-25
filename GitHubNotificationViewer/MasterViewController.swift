//
//  MasterViewController.swift
//  GitHubNotificationViewer
//
//  Copyright © 2016 laiso. All rights reserved.
//

import UIKit

class NotificationItem {
    var title: String = "";
}

struct GitHub {
    func loadNotifications(completionHandler: ((NSError?, [NotificationItem]?) -> Void)) {
        print("TODO: Load Notifications")
        completionHandler(nil, [NotificationItem()])
    }
}

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var items: [NotificationItem] = [NotificationItem]()


    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let
                indexPath = self.tableView.indexPathForSelectedRow,
                navigation = segue.destinationViewController as? UINavigationController,
                controller = navigation.topViewController as? DetailViewController
            {
                controller.detailItem = items[indexPath.row]
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
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
    
    // MARK: - ViewController
    
    func onRefresh() {
        let api = GitHub()
        api.loadNotifications { (error, items) -> Void in
            if let ns = items {
                self.items = ns
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
}

