import Foundation
import OAuthSwift
import SwiftyJSON

class NotificationItem {
    var title, apiURL: String?
    var URL: NSURL? {
        get {
            if let url = apiURL?.stringByReplacingOccurrencesOfString("https://api.github.com/repos", withString: "https://github.com") {
                let u = url.stringByReplacingOccurrencesOfString("/pulls/", withString: "/pull/")
                return NSURL(string: u)!
            }
            
            return nil
        }
    }
    
    init(item: JSON){
        self.title = item["subject"]["title"].string
        self.apiURL = item["subject"]["url"].string
    }
}

class GitHub {
    private let oauthswift = OAuth2Swift(
        consumerKey:    "139e6bcdad03cc9cf86f",
        consumerSecret: "09145cc9459ed062604b4f51ad30f5286a123477",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType:   "code"
    )
    
    func authorizeWithViewController(viewController: UIViewController, _ completion: () -> Void){
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: viewController)
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL(
            NSURL(string: "oauth-swift://oauth-callback/github")!,
            scope: "user,repo,notifications", state: state,
            success: { credential, response, parameters in
                completion()
            },
            failure: { error in
                print(error.localizedDescription)
            }
        )
    }
    
    func loadNotifications(completion: (NSError?, [NotificationItem]?) -> Void){
        oauthswift.client.get("https://api.github.com/notifications",
            success: { (data, response) -> Void in
                let json = JSON(data: data)
                var items = [NotificationItem]()
                for (_, item):(String, JSON) in json {
                    items.append(NotificationItem(item: item))
                }
                
                completion(nil, items)
            },
            failure: { error in
        })
    }
}