//
//  MeshBackendTask.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 20/04/2021.
//

import Foundation
import UIKit
import SwiftUI
import SwiftSoup
import SwiftyJSON

class MeshBackendTask{
    var session: Session
    var task:Task
    var proxies:FetchedResults<Proxies>
    var profiles: FetchedResults<Profile>
    var deliveryIDCart: String = ""
    var deliveryIDPut: String = ""
    var profile: Profile
    var profilename:String
    var datasku: String  = ""
    var banned = false
    var config: URLSessionConfiguration = URLSessionConfiguration.ephemeral
    var productImage = ""
    var productName = ""
    var PayPalLink = ""
    var UserAgent: String = ""
    var hostURL: String = "xyz"
    var SessionHeaders: [String : [String : String]] = ["Headers": ["Headers" : "Headers"]]
    var delay = 2000000
    
    
    init(taskdata:Task, proxies:FetchedResults<Proxies>, profiles:FetchedResults<Profile>){
        
        self.task = taskdata
        self.proxies = proxies
        self.profiles = profiles
        self.profilename = task.profile!
        self.profile = profiles[0]
        // Assigns user data to variables within the class scope.
        
        for item in self.profiles{
            if (item.profilename == self.profilename){
                self.profile = item
            }
        }
        // Find profile based on profile given in task object
        
        

        let countryCode = self.profile.countrycode?.lowercased()
        switch countryCode {
        case "gb" :
            self.hostURL = "www.\(self.task.site!).co.uk"
        case "fr" :
            self.hostURL = "www.\(self.task.site!).fr"
        case "us" :
            self.hostURL = "www.\(self.task.site!).com"
        default:
            self.hostURL = "Error"
        }
        print(self.hostURL)
        // Generates region URL based on site and country code from task object

        
        self.config = URLSessionConfiguration.ephemeral
//        self.config.urlCache = nil
//        self.config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        //partially configures session
        
        if (proxies.count == 0){
//            config.httpAdditionalHeaders = ["User-Agent": UserAgent]
            self.session = Session(configuration: config)
        } else {
            let proxy = proxies.randomElement()
            let host = proxy?.ip
            let port = Int((proxy?.port)!) ?? 0
            let username = proxy?.username
            let password = proxy?.password
            let Proxyconfig = Proxy.init(host: host!, port: port, username: username!, password: password!).createSessionConfig(existingSessionConfiguration: self.config, userAgent: self.UserAgent)

            self.session = Session(configuration: Proxyconfig)
        }
        // selects proxy  if any stored in core data entity
        // Passes proxy into Proxy function, which returns new configurations with proxies and useragent.
        
//        var referer = "\(hostURL)/product/product/\(self.task.url!)"

    }
    
}
