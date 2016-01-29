//
//  MasterViewController.swift
//  GitHubNotificationViewer
//
//  Copyright © 2016 laiso. All rights reserved.
//

import UIKit
import SafariServices
import Haneke

class NotificationCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repositoryLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
}

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
        guard let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }

        let object = items[indexPath.row]

        if let url = object.imageURL {
            cell.iconView.hnk_setImageFromURL(url)
        }

        cell.repositoryLabel.text = object.repository
        cell.titleLabel.text = object.title
        cell.updatedAtLabel.text = object.updatedAt

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let
            indexPath = self.tableView.indexPathForSelectedRow,
            url = items[indexPath.row].URL {
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
