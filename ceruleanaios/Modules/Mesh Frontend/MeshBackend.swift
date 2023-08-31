////
////  MeshBackend.swift
////  ceruleanaios
////
////  Created by Amaan Syed on 14/04/2021.
////
//
//import Foundation
//
//
func atc() {
        var semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\"billingAddress\":{\"id\":\"https://prod.jdgroupmesh.cloud/stores/jdsportsuk/customers/AF04FD635A234E6FA3FE331F9918F873/addresses/557FEF329252449697BDA6BD78DF0FE5\"},\"channel\":\"iphone-app\",\"contents\":[{\"$schema\":\"https://prod.jdgroupmesh.cloud/stores/jdsportsuk/schema/CartProduct\",\"SKU\":\"16136509.0195239343933\",\"quantity\":1}],\"deliveryAddress\":{\"id\":\"https://prod.jdgroupmesh.cloud/stores/jdsportsuk/customers/AF04FD635A234E6FA3FE331F9918F873/addresses/557FEF329252449697BDA6BD78DF0FE5\"},\"customer\":{\"id\":\"https://prod.jdgroupmesh.cloud/stores/jdsportsuk/customers/AF04FD635A234E6FA3FE331F9918F873\"}}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/carts")!,timeoutInterval: Double.infinity)
        request.addValue("prod.jdgroupmesh.cloud", forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("cart=4", forHTTPHeaderField: "mesh-version")
        request.addValue("iphone-app", forHTTPHeaderField: "mesh-commerce-channel")
        request.addValue("en-gb", forHTTPHeaderField: "accept-language")
        request.addValue("4CE1177BB983470AB15E703EC95E5285", forHTTPHeaderField: "x-api-key")
        request.addValue("jdsportsuk/6.9.0.2266 (iphone-app; iOS 14.4)", forHTTPHeaderField: "user-agent")
        request.addValue("VQYDUFVWDRABVFVRBwMOV10=", forHTTPHeaderField: "x-newrelic-id")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }



import Foundation
import UIKit
import SwiftUI
import SwiftSoup
import SwiftyJSON
import SwiftyHawk

func generateNonce() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<6).map{ _ in letters.randomElement()! })
}

struct productInfo{
    let size: String
    let sku: String
    let inStock: Bool
}

class MeshBackEndTask {
    var session: Session
    var task:Task
    var proxies:FetchedResults<Proxies>
    var profiles: FetchedResults<Profile>
    var deliveryIDCart: String = ""
    var customersID1: String = ""
    var customersID2: String = ""
    var addressID: String = ""
    var profile: Profile
    var profilename:String
    var datasku: String  = ""
    var banned = false
    var config: URLSessionConfiguration
    var productImage = ""
    var productName = ""
    var PayPalLink = ""
    var UserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Mobile/15E148 Safari/604.1"
    var hostURL: String = "xyz"
    var SessionHeaders: [String : [String : String]] = ["Headers": ["Headers" : "Headers"]]
    var referer: String
    var delay = 2000000
    var key: String
    var secret: String
    var apikey: String
    var urlextension: String
    var cartID: String = ""


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
                break
            }
        }
        // Find profile based on profile given in task object
        //https://prod.jdgroupmesh.cloud/stores/jdsportsuk/products/16138297?channel=iphone-app&expand=variations,informationBlocks,customisations

        self.key = "d1bdff50c5"
        self.secret = "3442497330233aecfe132ddfbbd4d46d"
        self.apikey = "4CE1177BB983470AB15E703EC95E5285"
        self.urlextension = "uk"
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always

        let countryCode = self.profile.countrycode?.lowercased()
        switch countryCode {
        case "gb" :
            self.hostURL = "https://prod.jdgroupmesh.cloud/stores/\(self.task.site!)uk/"
            self.key = "d1bdff50c5"
            self.secret = "3442497330233aecfe132ddfbbd4d46d"
            self.apikey = "4CE1177BB983470AB15E703EC95E5285"
            self.urlextension = "uk"
        case "fr" :
            self.hostURL = "https://prod.jdgroupmesh.cloud/stores/\(self.task.site!)fr/"
        case "us" :
            self.hostURL = "https://prod.jdgroupmesh.cloud/stores/\(self.task.site!)us/"
        case "nl" :
            self.hostURL = "https://prod.jdgroupmesh.cloud/stores/\(self.task.site!)nl/"
        case "de" :
            self.hostURL = "https://prod.jdgroupmesh.cloud/stores/\(self.task.site!)de/"
        default:
            self.hostURL = "Error"
        }
        // gets site origin based on region

        self.config = URLSessionConfiguration.ephemeral
        self.config.urlCache = nil
        self.config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
//        self.config.httpCookieAcceptPolicy = .always
        //partially configures session

        if (proxies.count == 0){
//            config.httpAdditionalHeaders = ["User-Agent": self.UserAgent]
            self.session = Session(configuration: config)
        } else {
            let proxy = proxies.randomElement()
              let host = proxy?.ip
              let port = Int((proxy?.port)!) ?? 0
              let username = proxy?.username
              let password = proxy?.password
              let Proxyconfig = Proxy.init(host: host!, port: port, username: username!, password: password!).createSessionConfig(existingSessionConfiguration: self.config, userAgent: "")
                    self.session = Session(configuration: Proxyconfig)
        }
        // selects proxy  if any stored in core data entity
        // Passes proxy into Proxy function, which returns new configurations with proxies and useragent.

        self.referer = "https://\(hostURL)/product/product/\(self.task.url!)"


        //creates referer for Headers

    }

    private func rotateProxy() {
        if let proxy = proxies.randomElement() {
                let host = proxy.ip
                let port = Int((proxy.port)!) ?? 0
                let username = proxy.username
                let password = proxy.password
            let config = Proxy.init(host: host!, port: port, username: username!, password: password!).createSessionConfig(existingSessionConfiguration: session.session.configuration, userAgent: "")
            self.session = Session(configuration: config)
            }

        }

    private func versionCheck() {
        var semaphore = DispatchSemaphore (value: 0)
        var hawkCredentials = Hawk.Credentials(id: self.key, key: self.secret, algoritm: .sha256)

        let nonce = generateNonce()

        let headerResult = try? Hawk.Client.header(uri: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/products/16138297?channel=iphone-app&expand=variations,informationBlocks,customisations",
                                                   method: "GET",
                                                   credentials: hawkCredentials,
                                                   nonce: nonce)

        var request = URLRequest(url: URL(string: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/updates?channel=iphone-app&version=6.10.0.2353")!,timeoutInterval: Double.infinity)
        request.addValue("prod.jdgroupmesh.cloud", forHTTPHeaderField: "Host")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("cart=4", forHTTPHeaderField: "mesh-version")
        request.addValue(self.apikey, forHTTPHeaderField: "x-api-key")
        request.addValue(headerResult!.headerValue, forHTTPHeaderField: "x-request-auth")
        request.addValue("jdsportsuk/6.10.0.2353 (iphone-app; iOS 14.4)", forHTTPHeaderField: "user-agent")
        request.addValue("en-gb", forHTTPHeaderField: "accept-language")
        request.addValue("iphone-app", forHTTPHeaderField: "mesh-commerce-channel")

        request.httpMethod = "GET"


        self.session.doRequest(request: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        semaphore.wait()
    }

    private func CheckStock() -> (Bool, TaskError?){
        var semaphore = DispatchSemaphore (value: 0)
        var StockError: TaskError?
        var instock = false
        var pid = self.task.url!
        print(pid)
        var request = URLRequest(url: URL(string: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/products/\(pid)?channel=iphone-app&expand=variations,informationBlocks,customisations")!)
        let hawkCredentials = Hawk.Credentials(id: self.key, key: self.secret, algoritm: .sha256)
        


        let nonce = generateNonce()

        let headerResult = try? Hawk.Client.header(uri: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/products/\(pid)?channel=iphone-app&expand=variations,informationBlocks,customisations",
                                                   method: "GET",
                                                   credentials: hawkCredentials,
                                                   nonce: nonce)


        request.addValue("prod.jdgroupmesh.cloud", forHTTPHeaderField: "Host")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("cart=4", forHTTPHeaderField: "mesh-version")
        request.addValue(self.apikey, forHTTPHeaderField: "x-api-key")
        request.addValue("\(self.task.site)\(self.urlextension)/6.10.0.2353 (iphone-app; iOS 14.4)", forHTTPHeaderField: "user-agent")
        request.addValue(headerResult!.headerValue, forHTTPHeaderField: "x-request-auth")
        request.addValue("en-gb", forHTTPHeaderField: "accept-language")
        request.addValue("iphone-app", forHTTPHeaderField: "mesh-commerce-channel")
        request.httpMethod = "GET"

        let taskSize = task.size!

        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                StockError = .RequestError
                print(error)
                semaphore.signal()
                return
            }

            guard let response = response else {
                StockError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                StockError = .NilResponseData
                semaphore.signal()
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse)
                switch httpResponse.statusCode {
            case 200...299:
                let json = try? JSON(data: data)
                self.productImage = json!["mainImage"].stringValue
                self.productName = json!["name"].stringValue

                if self.task.size?.lowercased() != "random" {
                    guard let size = json?["options"][taskSize] else {
                        print("1")
                        StockError = .ProductOOS
                        semaphore.signal()
                        return
                    }
                    if size["stockStatus"].stringValue == "IN STOCK" {
                        print("2")
                        self.datasku = size["SKU"].stringValue
                        print(self.datasku)
                        instock = true
                    } else {
                        StockError = .ProductOOS
                        semaphore.signal()
                        return
                    }
                } else {
                    print("3")
                    print(json!["options"])

                    let arrayofsizes = ["1", "1.5", "2", "2.5", "3", "3.5", "4", "4.5", "5", "5.5", "6", "6.5", "7", "7.5", "8", "8.5", "9", "9.5", "10", "10.5", "11", "11.5"]

                    for item in arrayofsizes {
                        let size = json!["options"][item]

                            if size["stockStatus"].stringValue == "IN STOCK" {
                                self.datasku = size["SKU"].stringValue
                                print(self.datasku)
                                instock = true
                                break
                            }

                    }
                }

            case 403:
                print("Banned")
                StockError = .TaskBanned
            case 500...599:
                print("Server issues")
                StockError = .ServerError
            default:
                print("Unknown Error")
                StockError = .InvalidStatusCode
            }
          semaphore.signal()
        }
        }
        semaphore.wait()

        return (instock, StockError)
    }

    func atc() -> (TaskError?, Bool) {
        var semaphore = DispatchSemaphore (value: 0)
        var atcError: TaskError?
        var addedToCart: Bool = false
  
        let url = #"https:\/\/prod.jdgroupmesh.cloud\/stores\/jdsportsuk\/schema\/CartProduct"#
        print(url)
        let parameters = #"{"channel":"iphone-app","contents":[{"$schema":"https:\/\/prod.jdgroupmesh.cloud\/stores\/jdsportsuk\/schema\/CartProduct","SKU":"16143825.4064052528833","quantity":1}]}"#
        let postData = parameters.data(using: .utf8)
        


        let hawkCredentials = Hawk.Credentials(id: self.key, key: self.secret, algoritm: .sha256)
        print(hawkCredentials)

        let nonce = generateNonce()

        let headerResult = try? Hawk.Client.header(uri: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/carts",
                                                   method: "GET",
                                                   credentials: hawkCredentials,
                                                   nonce: nonce)

            var request = URLRequest(url: URL(string: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/carts")!,timeoutInterval: Double.infinity)
        
        
        
        request.addValue("prod.jdgroupmesh.cloud", forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("cart=4", forHTTPHeaderField: "mesh-version")
        request.addValue("iphone-app", forHTTPHeaderField: "mesh-commerce-channel")
//        request.addValue("encoding", forHTTPHeaderField: "gzip, deflate, br")
        request.addValue(self.apikey, forHTTPHeaderField: "x-api-key")
        request.addValue(headerResult!.headerValue, forHTTPHeaderField: "x-request-auth")
        request.addValue("en-gb", forHTTPHeaderField: "accept-language")
        request.addValue("169", forHTTPHeaderField: "content-length")
        request.addValue("jdsportsuk/6.10.0.2353 (iphone-app; iOS 14.4)", forHTTPHeaderField: "user-agent")

        
        

            request.httpMethod = "POST"
            request.httpBody = postData
        
        print(headerResult!.headerValue)

        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                atcError = .RequestError
                semaphore.signal()
                print(error)
                return
            }

            guard let response = response else {
                atcError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                atcError = .NilResponseData
                semaphore.signal()
                return
            }


            if let httpResponse = response as? HTTPURLResponse {
                print(String(data: data, encoding: .utf8))
                switch httpResponse.statusCode {
                case 200...299:
                    let json = try? JSON(data: data)
                    self.deliveryIDCart = json!["delivery"]["deliveryMethodID"].stringValue
                    self.cartID = json!["ID"].stringValue
                    print(self.deliveryIDCart)
                    print(self.productName)
                    print(self.productImage)
                    addedToCart = true
                case 403:
                    print(httpResponse.statusCode)
                    atcError = .TaskBanned
                case 409:
                    atcError = .ProductOOS
                default:
                    print(httpResponse.statusCode)
                    atcError = .InvalidStatusCode
                }

            }

            semaphore.signal()
        }

            semaphore.wait()

            return (atcError, addedToCart)
    }

    // delivery countries
    private func postCustomer() {
        var semaphore = DispatchSemaphore (value: 0)
        var CustomerError:TaskError?
        var CustomerPosted = false
        let parameters = "{\"phone\":\"\(profile.number)\",\"gender\":\"\",\"firstName\":\"\(profile.firstname)\",\"addresses\":[{\"locale\":\"\(profile.countrycode)\",\"county\":\"\(profile.province)\",\"country\":\"United Kingdom\",\"address1\":\"\(profile.address1) \",\"town\":\"\(profile.city)\",\"postcode\":\"'\(profile.zipcode)'\",\"isPrimaryBillingAddress\":true,\"isPrimaryAddress\":true,\"address2\":\"\(profile.address2)\"}],\"title\":\"\",\"email\":\"\(profile.email)\",\"isGuest\":true,\"lastName\":\"\(profile.lastname)\"}"
        let postData = parameters.data(using: .utf8)

        let hawkCredentials = Hawk.Credentials(id: self.key, key: self.secret, algoritm: .sha256)
        print(hawkCredentials)

        let nonce = generateNonce()

        let headerResult = try? Hawk.Client.header(uri: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/customers?expand=loyalty",
                                                   method: "GET",
                                                   credentials: hawkCredentials,
                                                   nonce: nonce)

        var request = URLRequest(url: URL(string: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/customers?expand=loyalty")!)
        request.addValue("prod.jdgroupmesh.cloud", forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("cart=4", forHTTPHeaderField: "mesh-version")
        request.addValue("iphone-app", forHTTPHeaderField: "mesh-commerce-channel")
        request.addValue(self.apikey, forHTTPHeaderField: "x-api-key")
        request.addValue(headerResult!.headerValue, forHTTPHeaderField: "x-request-auth")
        request.addValue("en-gb", forHTTPHeaderField: "accept-language")
        request.addValue("jdsportsuk/6.10.0.2353 (iphone-app; iOS 14.4)", forHTTPHeaderField: "user-agent")

        request.httpMethod = "POST"
        request.httpBody = postData

        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                CustomerError = .RequestError
                semaphore.signal()
                return
            }

            guard let response = response else {
                CustomerError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                CustomerError = .NilResponseData
                semaphore.signal()
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                switch httpResponse.statusCode{
                case 200...299:
                    print(String(data: data, encoding: .utf8)!)
                    print("successDelivery")
                    let json = try? JSON(data: data)
                    self.customersID1 = json!["ID"].stringValue
                    self.customersID2 = json!["id"].stringValue
                    self.addressID = json!["addresses"]["id"].stringValue
                    CustomerPosted = true
                    semaphore.signal()
                case 403:
                    print("banned")
                    print(String(data: data, encoding: .utf8)!)
                    CustomerError = .TaskBanned
                case 500...599:
                    print(data)
                    print(response)
                    print("Session Timed Out")
                    CustomerError = .ServerError
                default:
                    CustomerError = .InvalidStatusCode
                }
            }
            semaphore.signal()
        }
        semaphore.wait()
    }

    private func postDelivery() {

        var semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\"id\":\"https://prod.jdgroupmesh.cloud/stores/jdsportsuk/carts/\(self.cartID)\",\"customer\":{\"id\":\"\(self.customersID2)\"},\"billingAddress\":{\"id\":\"\(self.addressID)\"},\"deliveryAddress\":{\"id\":\"\(self.addressID)\"}}"
        let postData = parameters.data(using: .utf8)

        let hawkCredentials = Hawk.Credentials(id: self.key, key: self.secret, algoritm: .sha256)
        print(hawkCredentials)

        let nonce = generateNonce()

        let headerResult = try? Hawk.Client.header(uri: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/carts/\(self.cartID)",
                                                   method: "GET",
                                                   credentials: hawkCredentials,
                                                   nonce: nonce)

        var request = URLRequest(url: URL(string: "https://prod.jdgroupmesh.cloud/stores/jdsportsuk/carts/\(self.cartID)")!,timeoutInterval: Double.infinity)
        request.addValue("prod.jdgroupmesh.cloud", forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("cart=4", forHTTPHeaderField: "mesh-version")
        request.addValue("iphone-app", forHTTPHeaderField: "mesh-commerce-channel")
        request.addValue("4CE1177BB983470AB15E703EC95E5285", forHTTPHeaderField: "x-api-key")
        request.addValue(headerResult!.headerValue, forHTTPHeaderField: "x-request-auth")
        request.addValue("en-gb", forHTTPHeaderField: "accept-language")
        request.addValue("jdsportsuk/6.10.0.2353 (iphone-app; iOS 14.4)", forHTTPHeaderField: "user-agent")



        request.httpMethod = "PUT"
        request.httpBody = postData

        self.session.doRequest(request: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        semaphore.wait()
    }


   public func startBackendTask()  -> (TaskErrorState?) {
//    self.versionCheck()
    var (inStock, StockError) = self.CheckStock()
     if !inStock {
         if let error = StockError {
             switch error{
             case .TaskBanned:
                 self.rotateProxy()
                 usleep(useconds_t(delay))
                 return TaskErrorState(error: .TaskBanned, state: .StockChecked, taskStatus: "Proxy Banned, Rotating...")
             default:
                 return TaskErrorState(error: error, state: .StockChecked, taskStatus: "Getting Size")
             }
         } else {
             inStock = true
             print("instock")
         }
     }

    self.atc()

    return nil
    
   }
}
