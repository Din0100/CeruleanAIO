import Foundation
import UIKit
import SwiftUI
import SwiftSoup
import SwiftyJSON
//import SwiftyHawk

class MeshFrontEndTask{
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
    var config: URLSessionConfiguration
    var productImage = ""
    var productName = ""
    var PayPalLink = ""
    var useragentarray = [
       "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
       "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Mobile/15E148 Safari/604.1",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Mobile/15E148 Safari/604.1",
       "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Safari/605.1.15",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36"
    ]
    var UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"
    var hostURL: String = "xyz"
    var SessionHeaders: [String : [String : String]] = ["Headers": ["Headers" : "Headers"]]
    var referer: String
    var delay = 2000000
//    var key: String
//    var secret: String
//    var apikey: String
    
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
        
        self.UserAgent = self.useragentarray.randomElement()!
        
        let countryCode = self.profile.countrycode?.lowercased()
        switch countryCode {
        case "gb" :
            if self.task.site! == "footpatrol"{
                self.hostURL = "www.\(self.task.site!).com"
            } else {
                self.hostURL = "www.\(self.task.site!).co.uk"
            }
        case "fr" :
            self.hostURL = "www.\(self.task.site!).fr"
        case "us" :
            self.hostURL = "www.\(self.task.site!).com"
        case "nl" :
            self.hostURL = "www.\(self.task.site!).nl"
        case "de" :
            self.hostURL = "www.\(self.task.site!).de"
        default:
            self.hostURL = "Error"
        }
        // gets site origin based on region
        
        self.config = URLSessionConfiguration.ephemeral
        self.config.urlCache = nil
        self.config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.httpAdditionalHeaders = ["User-Agent": UserAgent]
        //partially configures session
        
        if (proxies.count == 0){
//            config.httpAdditionalHeaders = ["User-Agent": self.UserAgent]
            self.session = Session(configuration: config)
            print("yah")
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
        
        self.referer = "https://\(hostURL)/product/product/\(self.task.url!)"
//        self.key = "d1bdff50c5"
//        self.secret = "3442497330233aecfe132ddfbbd4d46d"
//        self.apikey = "4CE1177BB983470AB15E703EC95E5285"
//        let hawkCredentials = Hawk.Credentials(id: self.key, key: self.secret, algoritm: .sha256)
//        print(hawkCredentials)
        //creates referer for Headers
        
    }
    
    private func rotateProxy() {
        if let proxy = proxies.randomElement() {
                let host = proxy.ip
                let port = Int((proxy.port)!) ?? 0
                let username = proxy.username
                let password = proxy.password
            let config = Proxy.init(host: host!, port: port, username: username!, password: password!).createSessionConfig(existingSessionConfiguration: session.session.configuration, userAgent: self.UserAgent)
            self.session = Session(configuration: config)
            }
        
        self.UserAgent = self.useragentarray.randomElement()!
        
        }
    
    private func GetHeaders(){
        let headers = [
            [
                "ProductPage" :
                [
                    self.hostURL : "Host",
                    "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" : "accept",
                    "gzip, deflate, br" : "accept-encoding",
                    "en-gb" : "accept-language",
                    "https://\(self.hostURL)/c/footwear/?max=72" : "referer"
                ],
                
                "StockCheck" :
                [
                    self.hostURL : "Host",
                    "*/*" : "accept",
                    "application/json" : "content-type",
                    "en-gb" : "accept-language",
                    "XMLHttpRequest" : "x-requested-with",
                    self.referer + "/"  : "referer",
                    "gzip, deflate, br" : "accept-encoding"
                ],
                
                "AddToCart" :
                [
                    self.hostURL : "Host",
                    "application/json" : "content-type",
                    "*/*" : "accept",
                    "XMLHttpRequest" : "x-requested-with",
                    "en-gb" : "accept-language",
                    "gzip, deflate, br" : "accept-encoding",
                    "https://\(self.hostURL)" : "origin",
                    self.referer + "/" : "referer",
                    "119" : "content-length"
                ],
                
                "Login" :
                [
                    self.hostURL : "Host",
                    "application/json" : "Content-type",
                    "*/*" : "Accept",
                    "XMLHttpRequest" : "X-requested-with",
                    "en-gb" : "Accept-language",
                    "gzip, deflate, br" : "Accept-encoding",
                    "https://\(self.hostURL)" : "Origin",
                    "35" : "Content-length",
                    "https://\(self.hostURL)/checkout/login/" : "Referer"
                ],
                
                "CartDeliveryPut" :
                [
                    self.hostURL : "Host",
                    "application/x-www-form-urlencoded; charset=UTF-8" : "Content-type",
                    "*/*" : "Accept",
                    "XMLHttpRequest" : "X-requested-with",
                    "en-gb" : "Accept-language",
                    "gzip, deflate, br" : "Accept-encoding",
                    "https://\(self.hostURL)" : "Origin",
                    "79" : "Content-length",
                    "https://\(hostURL)/checkout/delivery/" : "Referer"
                ],
                
                "Delivery" :
                [
                    self.hostURL : "Host",
                    "application/json" : "Content-type",
                    "*/*" : "Accept",
                    "XMLHttpRequest" : "X-requested-with",
                    "en-gb" : "Accept-language",
                    "gzip, deflate, br" : "Accept-encoding",
                    "https://\(self.hostURL)" : "Origin",
                    "308" : "Content-length",
                    "https://\(self.hostURL)/checkout/delivery/" : "Referer"
                ],
                
                "AddressAndMethod" :
                [
                    self.hostURL : "Host",
                    "application/json" : "Content-type",
                    "*/*" : "Accept",
                    "XMLHttpRequest" : "X-requested-with",
                    "en-gb" : "Accept-language",
                    "gzip, deflate, br" : "Accept-encoding",
                    "https://\(self.hostURL)" : "Origin",
                    "112" : "Content-length",
                    "https://\(self.hostURL)/checkout/delivery/" : "Referer"
                ]
                
            ]
            
            
            
            
        ]
        
        self.SessionHeaders = headers.randomElement()!
        
        
        
    }
    
    private func ja3HashCheck(){
        let semaphore = DispatchSemaphore(value: 0)
         var ProductError: TaskError?
         let url = URL(string: "")
         let errorurl = URL(string: "error")
        var request = URLRequest(url: url ?? errorurl!)
         
         self.session.doRequest(request: request) { data, response, error in
             if error != nil {
                 ProductError = .RequestError
                 print(error)
                 semaphore.signal()
                 return
             }

             guard let response = response else {
                 ProductError = .NilResponse
                 semaphore.signal()
                 return
             }

             guard let data = data else {
                 ProductError = .NilResponseData
                 semaphore.signal()
                 return
             }
             
             print(response)
             
             if let httpResponse = response as? HTTPURLResponse {
                 switch httpResponse.statusCode {
             case 200...299:
                 print(String(data: data, encoding: .utf8)!)
             case 403:
                 print("Banned")
                ProductError = .TaskBanned
             case 500...599:
                 print("Server issues")
                 ProductError = .ServerError
             default:
                 print("Unknown Error")
                 ProductError = .InvalidStatusCode
             }
             semaphore.signal()
             }
         }
         semaphore.wait()
    }
    
    public func PostRecent(){
           var semaphore = DispatchSemaphore (value: 0)

           let parameters = "[{\"SKU\":16134752,\"name\":\"Jordan Air 1 Low\",\"price\":\"95.00\",\"prev\":\"\",\"curr\":\"GBP\",\"rating\":\"r00\",\"reviews\":0,\"image\":\"https://i8.amplience.net/i/jpl/jd_413749_al?qlt=92{&queryParameters*}\",\"slug\":\"white-jordan-air-1-low\",\"im\":\"https://i8.amplience.net/i/jpl/jd_413749_al?qlt=92&w=310&h=310&v=1\",\"rx\":\"\",\"pr\":\"£95.00\",\"pp\":\"\",\"sv\":0}]"
           let postData = parameters.data(using: .utf8)

           var request = URLRequest(url: URL(string: "https://www.jdsports.co.uk/products/recently-viewed/")!,timeoutInterval: Double.infinity)
           request.addValue("www.jdsports.co.uk", forHTTPHeaderField: "Host")
           request.addValue("application/json", forHTTPHeaderField: "content-type")
           request.addValue("*/*", forHTTPHeaderField: "accept")
           request.addValue("XMLHttpRequest", forHTTPHeaderField: "x-requested-with")
           request.addValue("en-gb", forHTTPHeaderField: "accept-language")
           request.addValue("https://www.jdsports.co.uk", forHTTPHeaderField: "origin")
           request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15", forHTTPHeaderField: "user-agent")
        request.addValue(self.referer, forHTTPHeaderField: "referer")

           request.httpMethod = "POST"
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
       
       public func ProductPage() -> (TaskError?){
           
            let semaphore = DispatchSemaphore(value: 0)
            var ProductError: TaskError?
            let url = URL(string: self.referer)
           let errorurl = URL(string: "error")
           var request = URLRequest(url: url ?? errorurl!)
           if request.url == errorurl {
               ProductError = .ProductDoesNotExist
               return ProductError
           }
           
           let ProductHeaders = self.SessionHeaders["ProductPage"]!
   
           for (value, header) in ProductHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }
           
           self.session.doRequest(request: request) { data, response, error in
               if error != nil {
                   ProductError = .RequestError
                   print(error)
                   semaphore.signal()
                   return
               }

               guard let response = response else {
                   ProductError = .NilResponse
                   semaphore.signal()
                   return
               }

               guard let data = data else {
                   ProductError = .NilResponseData
                   semaphore.signal()
                   return
               }
               
               print(response)
               
               if let httpResponse = response as? HTTPURLResponse {
                   switch httpResponse.statusCode {
               case 200...299:
                
                   print(httpResponse)
                self.referer = response.url!.absoluteString
                   print(self.referer)
//                   print(String(data: data, encoding: .utf8)!)
               case 403:
                   print("Banned")
                  ProductError = .TaskBanned
               case 500...599:
                   print("Server issues")
                   ProductError = .ServerError
               default:
                   print("Unknown Error")
                   ProductError = .InvalidStatusCode
               }
               semaphore.signal()
               }
           }
           semaphore.wait()
           return ProductError
       }
       
       public func StockCheck() -> (Bool, TaskError?) {
           var inStock = false
           var StockError: TaskError?
           let semaphore = DispatchSemaphore(value: 0)
           let stockURL = URL(string: "\(self.referer)/stock/?_=")
           print(stockURL)
        let instockarray = [String]()
           
           var request = URLRequest(url:stockURL!)
           let StockCheckHeaders = self.SessionHeaders["StockCheck"]!
           
           for (value, header) in StockCheckHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }
           
           print(StockCheckHeaders)
           
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
                   print(httpResponse.statusCode)
                   switch httpResponse.statusCode {
               case 200...299:
                   let html = String(data: data, encoding: .utf8)!
                   guard let doc: Document = try? SwiftSoup.parse(html) else {
                       StockError = .SwiftSoupError
                       semaphore.signal()
                       return
                   }

                   guard let sizesInStock:Elements = try? doc.getElementsByClass("btn-default") else {
                       StockError = .SwiftSoupError
                       semaphore.signal()
                       return
                   }
                
                if self.task.size?.lowercased() != "random" {
                    for item in sizesInStock{
                        if (try! item.text().trimmingCharacters(in: .whitespacesAndNewlines).contains(self.task.size!) && item.attr("data-stock").trimmingCharacters(in: .whitespacesAndNewlines) == "1" ){
                            self.datasku = try! item.attr("data-sku")
                            print(self.datasku)
                            inStock = true
                            break
                        } else {
                            print("Size Not Found")
                        }
                       
                    }
                    
                } else {
                    for item in sizesInStock {
                        if (try! item.attr("data-stock").trimmingCharacters(in: .whitespacesAndNewlines) == "1" ){
                            self.datasku = try! item.attr("data-sku")
                            inStock = true
                            break
                        }
                    }
                }
                   
            
                   
                   if !inStock {
                       return
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
           return (inStock, StockError)
       }
       
       public func AddToCart() -> (Bool, TaskError?){
           print("Attempting Add To Cart")
           let semaphore = DispatchSemaphore(value: 0)
           let cartURL: String =  "https://\(self.hostURL)/cart/\(self.datasku)/"
           var cartingError: TaskError?
           var addedToCart:Bool = false

           let parameters: String = "{\"customisations\":false,\"cartPosition\":null,\"recaptchaResponse\":false,\"cartProductNotification\":null,\"quantityToAdd\":1}"
           print(parameters)
           let postData = parameters.data(using: .utf8)
           
           var request = URLRequest(url: URL(string: cartURL)!)
           
           let ATCHeaders = self.SessionHeaders["AddToCart"]!
           
           for (value, header) in ATCHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }
           
        print(try! request.asURLRequest())
           
           print(request.headers)
           print(HTTPCookieStorage())
           
           request.httpMethod = "POST"
           request.httpBody = postData
           

           self.session.doRequest(request: request) { data, response, error in
               if error != nil {
                   cartingError = .RequestError
                   semaphore.signal()
                   print(error)
                   return
               }

               guard let response = response else {
                   cartingError = .NilResponse
                   semaphore.signal()
                   return
               }

               guard let data = data else {
                   cartingError = .NilResponseData
                   semaphore.signal()
                   return
               }
               
               print(response)

               if let httpResponse = response as? HTTPURLResponse {
                   switch httpResponse.statusCode {
                   case 200...299:

                       print("Added to cart")
                       let json = try? JSON(data: data)
                       self.deliveryIDCart = json!["delivery"]["deliveryMethodID"].stringValue
                       self.productName = json!["contents"][0]["name"].stringValue
                       self.productImage = json!["contents"][0]["image"]["originalURL"].stringValue
                       print(self.deliveryIDCart)
                       print(self.productName)
                       print(self.productImage)
                       addedToCart = true
                   case 403:
                       print(httpResponse.statusCode)
                       cartingError = .TaskBanned
                   case 409:
                       cartingError = .ProductOOS
                   default:
                       print(httpResponse.statusCode)
                       cartingError = .InvalidStatusCode
                   }
                   
               }
               
               semaphore.signal()
           }
               semaphore.wait()

               return (addedToCart, cartingError)
       }
       
       public func Login() -> (Bool, TaskError?) {
           let semaphore = DispatchSemaphore (value: 0)
           var loginError: TaskError?
           var isLoggedIn = false
           let email = (profile.email?.lowercased())!
           let parameters = "{\"email\":" + "\"" + email + "\"" + "}"
           let postData = parameters.data(using: .utf8)

           var request = URLRequest(url: URL(string: "https://\(self.hostURL)/checkout/guest/")!,timeoutInterval: Double.infinity)
           
           let LoginHeaders = self.SessionHeaders["Login"]!
           
           for (value, header) in LoginHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }

           request.httpMethod = "POST"
           request.httpBody = postData

           
           self.session.doRequest(request: request) { data, response, error in
               if error != nil {
                   loginError = .RequestError
                   semaphore.signal()
                   return
               }

               guard let response = response else {
                   loginError = .NilResponse
                   semaphore.signal()
                   return
               }

               guard let data = data else {
                   loginError = .NilResponseData
                   semaphore.signal()
                   return
               }
               

               if let httpResponse = response as? HTTPURLResponse {
                   switch httpResponse.statusCode {
                   case 200...299:
                       isLoggedIn = true
                       print(String(data: data, encoding: .utf8)!)
                       semaphore.signal()
                       isLoggedIn = true
                   case 403:
                       loginError = .TaskBanned
                   case 422:
                       loginError = .InvalidCredentials
                   default:
                       print(httpResponse.statusCode)
                       loginError = .InvalidStatusCode
                   }
                   
               }
     
               semaphore.signal()
           }
           semaphore.wait()
           print("LoginCookies")
           print(HTTPCookieStorage())
           return (isLoggedIn, loginError)
       }
       
       public func CartDeliveryPUT() -> (Bool, TaskError?){
           let semaphore = DispatchSemaphore (value: 0)
           let CC = (profile.countrycode?.lowercased())!
           let parameters = "{\"deliveryMethodID\":\"\(self.deliveryIDCart)\",\"deliveryLocation\":\"\(CC)\"}"
           print(parameters)
           let postData = parameters.data(using: .utf8)
           var CartPutError:TaskError?
           var CartDelivery = false

           var request = URLRequest(url: URL(string: "https://\(self.hostURL)/cart/")!,timeoutInterval: Double.infinity)
           
           let CartDeliveryPutHeaders = self.SessionHeaders["CartDeliveryPut"]!
           
           for (value, header) in CartDeliveryPutHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }
           
           request.httpMethod = "PUT"
           request.httpBody = postData
           
           self.session.doRequest(request: request) { data, response, error in
                   if error != nil {
                       CartPutError = .RequestError
                       semaphore.signal()
                       return
                   }

                   guard let response = response else {
                       CartPutError = .NilResponse
                       semaphore.signal()
                       return
                   }

                   guard let data = data else {
                       CartPutError = .NilResponseData
                       semaphore.signal()
                       return
                   }
                   
                   if let httpResponse = response as? HTTPURLResponse {
                       switch httpResponse.statusCode {
                       case 200...299:
                           print("CART PUT")
   //                        print(String(data: data, encoding: .utf8)!)
                           CartDelivery = true
                           semaphore.signal()
                       case 403:
                           print("banned")
                           print(String(data: data, encoding: .utf8)!)
                           CartPutError = .TaskBanned
   //                        self.configureSession()
                       case 500...599:
                           print("Session Timed Out")
                           CartPutError = .ServerError
                       default:
                           print(String(data: data, encoding: .utf8)!)
                           CartPutError = .InvalidStatusCode
                       }
                   
                   
               }
               semaphore.signal()
           }
           semaphore.wait()
           print("CartPutCookies")
           print(HTTPCookieStorage())
           return(CartDelivery, CartPutError)
       }
       
       public func Delivery() -> (Bool, TaskError?) {
           let semaphore = DispatchSemaphore (value: 0)
           var DeliveryPosted = false
           var DeliveryError:TaskError?
           let parameters = "{\"useDeliveryAsBilling\":true,\"country\":\"United Kingdom|gb\",\"locale\":\"\",\"firstName\":\"\(self.profile.firstname!)\",\"lastName\":\"\(self.profile.lastname!)\",\"phone\":\"\(self.profile.number!)\",\"address1\":\"\(self.profile.address1!)\",\"address2\":\"\(self.profile.address2!)\",\"town\":\"\(self.profile.city!)\",\"county\":\"\(self.profile.province!)\",\"postcode\":\"\(self.profile.zipcode!)\",\"addressPredict\":\"\",\"setOnCart\":\"deliveryAddressID\",\"addressPredictflag\":\"false\"}"
           let postData = parameters.data(using: .utf8)
           print(parameters)

           var request = URLRequest(url: URL(string: "https://\(self.hostURL)/myaccount/addressbook/add/")!,timeoutInterval: Double.infinity)
           
           let DeliveryHeaders = self.SessionHeaders["Delivery"]!
           
           for (value, header) in DeliveryHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }

           request.httpMethod = "POST"
           request.httpBody = postData
           
           self.session.doRequest(request: request) { data, response, error in
               if error != nil {
                   DeliveryError = .RequestError
                   semaphore.signal()
                   return
               }

               guard let response = response else {
                   DeliveryError = .NilResponse
                   semaphore.signal()
                   return
               }

               guard let data = data else {
                   DeliveryError = .NilResponseData
                   semaphore.signal()
                   return
               }
               
               if let httpResponse = response as? HTTPURLResponse {
                   print(httpResponse.statusCode)
                   switch httpResponse.statusCode{
                   case 200...299:
                       print(String(data: data, encoding: .utf8)!)
                       print("successDelivery")
                       DeliveryPosted = true
                       let json = try? JSON(data: data)
                       self.deliveryIDPut = json!["ID"].stringValue
                       semaphore.signal()
                   case 403:
                       print("banned")
                       print(String(data: data, encoding: .utf8)!)
                       DeliveryError = .TaskBanned
                   case 500...599:
                       print(data)
                       print(response)
                       print("Session Timed Out")
                       DeliveryError = .ServerError
                   default:
                       DeliveryError = .InvalidStatusCode
                   }
               }
               semaphore.signal()
           }
           semaphore.wait()
           return (DeliveryPosted, DeliveryError)
       }
       
       public func AddressAndMethod() -> (Bool, TaskError?) {
           let semaphore = DispatchSemaphore (value: 0)
           var JDAddressError:TaskError?
           let parameters = "{\"addressId\":\"\(self.deliveryIDPut)\",\"methodId\":\"\(self.deliveryIDCart)\",\"deliverySlot\":{}}"
           let postData = parameters.data(using: .utf8)
           var AddressPosted = false

           var request = URLRequest(url: URL(string: "https://\(self.hostURL)/checkout/updateDeliveryAddressAndMethod/ajax/")!,timeoutInterval: Double.infinity)
           
           let AddressAndMethodHeaders = self.SessionHeaders["AddressAndMethod"]!
           
           for (value, header) in AddressAndMethodHeaders {
               request.addValue(value, forHTTPHeaderField: header)
           }

           request.httpMethod = "POST"
           request.httpBody = postData
           
           self.session.doRequest(request: request) { data, response, error in
               if error != nil {
                   JDAddressError = .RequestError
                   semaphore.signal()
                   return
               }

               guard let response = response else {
                   JDAddressError = .NilResponse
                   semaphore.signal()
                   return
               }

               guard let data = data else {
                   JDAddressError = .NilResponseData
                   semaphore.signal()
                   return
               }
               
               if let httpResponse = response as? HTTPURLResponse {
                   print(httpResponse.statusCode)
                   switch httpResponse.statusCode{
                   case 200...299:
                       print("address success")
                       print(String(data: data, encoding: .utf8)!)
                       AddressPosted = true
                       print(data)
                       semaphore.signal()
                   case 403:
                       print("banned")
                       print(String(data: data, encoding: .utf8)!)
                       JDAddressError = .TaskBanned
                   case 500...599:
                       print("Session Timed Out")
                       JDAddressError = .ServerError
                   default:
                       JDAddressError = .InvalidStatusCode
                   }
               }
               semaphore.signal()
           }
           semaphore.wait()
           return (AddressPosted, JDAddressError)
       }
       
       public func GetPayPal() -> (Bool, TaskError?){
           let semaphore = DispatchSemaphore (value: 0)
           var PayPalLink = false
           var PayPalError:TaskError?
           var request = URLRequest(url: URL(string: "https://\(self.hostURL)/checkout/payment/?paySelect=paypalViaHosted")!,timeoutInterval: Double.infinity)
       
           let useragent = self.UserAgent
           request.addValue(useragent, forHTTPHeaderField: "user-agent")

           request.httpMethod = "GET"
           
    
           print("GETTING PAYPAL")
           self.session.doRequest(request: request, followRedirects: false) { data, response, error in
               if error != nil {
                   PayPalError = .RequestError
                   semaphore.signal()
                   return
               }

               guard let response = response else {
                   PayPalError = .NilResponse
                   semaphore.signal()
                   return
               }

               guard let data = data else {
                   PayPalError = .NilResponseData
                   semaphore.signal()
                   return
               }
               
               print(response)
               print(data)

               
               if let httpResponse = response as? HTTPURLResponse {
                   print(httpResponse.statusCode)
                   print(String(data: data, encoding: .utf8)!)
                   switch httpResponse.statusCode{
                   case 200...303:
                       print(String(data: data, encoding: .utf8)!)
                       PayPalLink = true
                       print(data)
                       print(response)
                       self.PayPalLink = response.allHeaderFields["Location"] as! String
                       print(response.url!.absoluteString)
                       
                       let hook:Webhook = Webhook(productName: self.productName, productImage: self.productImage, site: self.task.site!)

                    DiscordWebhook(hook: hook, profile:self.profile, PPlink:self.PayPalLink, task: self.task)
                       DiscordWebhook2(PPLink: self.PayPalLink, profile: self.profile)
                       // create the alert
                       semaphore.signal()
                   case 403:
                       print("banned")
                       print(String(data: data, encoding: .utf8)!)
                       PayPalError = .TaskBanned
                   case 500...599:
                       print("Session Timed Out")
                       PayPalError = .ServerError
                   default:
                       PayPalError = .InvalidStatusCode
                   }
               }
               
               semaphore.signal()
           }
           semaphore.wait()
           
           return (PayPalLink, PayPalError)
       }
       
       public func StartMeshTask() -> (TaskErrorState?){
           GetHeaders()
        ja3HashCheck()
           sleep(2)
           let ProductError = self.ProductPage()
           if let error = ProductError {
               switch error {
               case .TaskBanned:
                   self.rotateProxy()
                   usleep(useconds_t(delay))
                   return TaskErrorState(error: .TaskBanned, state: .StockChecked, taskStatus: "Proxy Banned, Rotating...")
               default:
                   return TaskErrorState(error: error, state: .StockChecked, taskStatus: "Starting Task")
               }
           } else {
               print("Product Found")
           }
           
           sleep(2)
   
//           self.PostRecent()
//        ja3HashCheck()
   
          var (inStock, StockError) = self.StockCheck()
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

           sleep(2)

           let (addedToCart, cartingError) = self.AddToCart()
           if !addedToCart {
               if let cartError = cartingError{
                   switch cartError {
                   case .TaskBanned:
                       print("Banned")
                       self.rotateProxy()
                       usleep(useconds_t(delay))
                       return TaskErrorState(error: .TaskBanned, state: .AttemptingToCart, taskStatus: "Proxy Banned, Rotating...")
                   default:
                       return TaskErrorState(error: cartError, state: .AttemptingToCart, taskStatus: "Added To Cart")
                   }
               } else {
                   return TaskErrorState(error: .ProductOOS, state: .StockChecked, taskStatus: "Out Of Stock")
               }
           }

           sleep(2)


           let (isLoggedIn, loginError) = self.Login()
           if !isLoggedIn {
               if let logError = loginError{
                   switch logError {
                   case .TaskBanned:
                       self.rotateProxy()
                       usleep(useconds_t(delay))
                       return TaskErrorState(error: .TaskBanned, state: .AttemptingLogin, taskStatus: "Proxy Banned, Rotating...")
                   default:
                       return TaskErrorState(error: logError, state: .AttemptingLogin, taskStatus: "Logged In")
                   }
               }
           }



           let  (cartPut, cartPutError) = self.CartDeliveryPUT()
           if !cartPut {
               if let CartErrorPUT = cartPutError {
                   switch CartErrorPUT {
                   case .TaskBanned:
                       self.rotateProxy()
                       usleep(useconds_t(delay))
                       return TaskErrorState(error: .TaskBanned, state: .AttemptingObtainingCart, taskStatus: "Proxy Banned, Rotating...")
                   default:
                       return TaskErrorState(error: CartErrorPUT, state: .AttemptingObtainingCart, taskStatus: "Obtained Cart")
                   }
               }
           }



           let (DeliveryPosted, DeliveryError) = self.Delivery()
           if !DeliveryPosted {
               if let DeliveryPostError = DeliveryError {
                   switch DeliveryPostError {
                   case .TaskBanned:
                       self.rotateProxy()
                       usleep(useconds_t(delay))
                       return TaskErrorState(error: .TaskBanned, state: .CheckoutAdvanced, taskStatus: "Proxy Banned, Rotating...")
                   default:
                       return TaskErrorState(error: DeliveryPostError, state: .CheckoutAdvanced, taskStatus: "Delivery Posted")
                   }

               }
           }



           let (AddressPosted, JDAddressError) = self.AddressAndMethod()
           if !AddressPosted {
               if let AddressError = JDAddressError {
                   switch AddressError {
                   case .TaskBanned:
                       self.rotateProxy()
                       usleep(useconds_t(delay))
                       return TaskErrorState(error: .TaskBanned, state: .AttemptingAddressAndMethod, taskStatus: "Proxy Banned, Rotating...")
                   default:
                       return TaskErrorState(error: AddressError, state: .PostedAddressAndMethod, taskStatus: "Address Posted")
                   }
               }
           }



           let (PayPalLink, PayPalError) = self.GetPayPal()
           if !PayPalLink {
               if let PayPalLinkError = PayPalError {
                   switch PayPalLinkError {
                   case .TaskBanned:
                       self.rotateProxy()
                       usleep(useconds_t(delay))
                       return TaskErrorState(error: .TaskBanned, state: .AttemptingAddressAndMethod, taskStatus: "Proxy Banned, Rotating...")

                   default:

                       let hook:Webhook = Webhook(productName: self.productName, productImage: self.productImage, site: self.task.site!)

                    DiscordWebhook(hook: hook, profile:self.profile, PPlink:self.PayPalLink, task: self.task)
                       DiscordWebhook2(PPLink: self.PayPalLink, profile: self.profile)

   //                    return nil

                       return TaskErrorState(error: .InvalidAPIKey, state: .ObtainedPayPalLink, taskStatus: self.PayPalLink)
                   }

               }
               let hook:Webhook = Webhook(productName: self.productName, productImage: self.productImage, site: self.task.site!)

            DiscordWebhook(hook: hook, profile:self.profile, PPlink:self.PayPalLink, task: self.task)
           }
           
           return nil
       }
    
}
