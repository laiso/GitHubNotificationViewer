//
//  MasterViewController.swift
//  GitHubNotificationViewer
//
//  Copyright © 2016 laiso. All rights reserved.
//

import UIKit
import OAuthSwift

class NotificationItem {
    var title: String = "";
}

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var items: [NotificationItem] = [NotificationItem]()
    var oauthswift: OAuth2Swift! = nil

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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (oauthswift == nil){
            onSignInButton()
        }
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
    
    // MARK: -
    
    func onRefresh() {
        if let api = oauthswift {
            api.client.get("https://api.github.com/notifications",
                success: { (data, response) -> Void in
                    print(data)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.refreshControl?.endRefreshing()
                    })
                },
                failure: { error in
                    print(error.localizedDescription)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.refreshControl?.endRefreshing()
                    })
            })
        }
    }
    
    @IBAction
    func onSignInButton() {
        oauthswift = OAuth2Swift(
            consumerKey:    "139e6bcdad03cc9cf86f",
            consumerSecret: "09145cc9459ed062604b4f51ad30f5286a123477",
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: self)
        
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL(
            NSURL(string: "oauth-swift://oauth-callback/github")!,
            scope: "user,repo,notifications", state: state,
            success: { credential, response, parameters in
                self.onRefresh()
            },
            failure: { error in
                print(error.localizedDescription)
            }
        )
    }
    
}

