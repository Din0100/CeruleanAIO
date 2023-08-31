//
//  SupremeTask.swift
//  PyroPreme
//
//  Created by Amaan Syed on 16/05/2021.
//

import Foundation
import UIKit
import SwiftUI
import SwiftSoup
import SwiftyJSON
import WebKit

struct SupremeTaskStruct {
    var category: String
    var keyWords: String
    var size: String
    var quantity: String
    var color: String
}

class SupremeTask {
    let hash: String
    let Task: SupremeTaskStruct
    var config: URLSessionConfiguration
    var session: Session
    var keywords: [String] = []
    var productID = ""
    var styleID = ""
    var liveID = ""
    var sizeID = ""
    let EUAPIkey = "186b2c39-6b93-4e07-b575-236a4fec84bb"
    let jar = HTTPCookieStorage.shared

    init(hash: String){
        print("Started Task")
        self.hash = hash
        
        self.Task = SupremeTaskStruct(category: "shirts", keyWords: "Gingham,Shirt", size: "Medium", quantity: "1", color: "black")
        
        self.config = URLSessionConfiguration.ephemeral
        self.config.urlCache = nil
        self.config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.jar.cookieAcceptPolicy = .always
        self.config.httpCookieAcceptPolicy = .always
        //partially configures session
//        self.config.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Safari/605.1.15"]
        self.session = Session(configuration: config)
        
        keywords = self.Task.keyWords.components(separatedBy: ",")
        print(keywords)
    }
    
    private func getCategories() -> (Bool, TaskError?) {
        let semaphore = DispatchSemaphore(value: 0)
        let stockURL = URL(string: "https://www.supremenewyork.com/mobile_stock.json")
        var productFound = false
        var request = URLRequest(url:stockURL!)
        var StockError: TaskError?
        
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
                let json = try? JSON(data: data)
                guard let categoryJSON = json?["products_and_categories"] else {
                    print("Could not get Categories")
                    return
                }
                
                var KeyWordCount = 0
                print(self.keywords)
                
                for (key,subJson):(String, JSON) in categoryJSON {
                    if key.lowercased() == self.Task.category.lowercased(){
                        for item in subJson {
                            for keyword in self.keywords {
                                print(keyword)
                                if item.1["name"].stringValue.lowercased().contains(keyword.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                                    print(keyword.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                                    KeyWordCount = KeyWordCount + 1
                                }
                                
                                if KeyWordCount == self.keywords.count {
                                    self.productID = item.1["id"].stringValue
                                    productFound = true
                                }
                            }
                        }
                        
                        if (productFound){
                            print(self.productID)
                            print("Product matching keywords found")
                        } else {
                            print("could not find product matching keywords")
                            StockError = .ProductDoesNotExist
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
        return(productFound, StockError)
    }
    
    private func getStyleID()  -> (Bool, TaskError?){
        let semaphore = DispatchSemaphore(value: 0)
        let stockURL = URL(string: "https://www.supremenewyork.com/shop/\(self.productID).json")
        var styleFound = false
        var request = URLRequest(url:stockURL!)
        var StyleError: TaskError?
        
        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                StyleError = .RequestError
                print(error)
                semaphore.signal()
                return
            }

            guard let response = response else {
                StyleError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                StyleError = .NilResponseData
                semaphore.signal()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                switch httpResponse.statusCode {
            case 200...299:
                let json = try? JSON(data: data)
                guard let stylesJSON = json?["styles"].arrayValue else {
                    print("Could not get Styles")
                    StyleError = .SwiftSoupError
                    return
                }
                
                for style in stylesJSON{
                    print(style["name"])
                    if (style["name"].stringValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == self.Task.color.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
                        for size in style["sizes"].arrayValue {
                            print(size["name"])
                            if size["name"].stringValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == self.Task.size.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                self.styleID = size["id"].stringValue
                                self.sizeID = style["id"].stringValue
                                print("found product")
                                styleFound = true
                                break
                            }
                        }
                    }
                }
                
                if (styleFound){
                    print(self.styleID)
                    print("Style found")
                } else {
                    print("could not find size/color")
                    StyleError = .ProductDoesNotExist
                }
                
            case 403:
                print("Banned")
                StyleError  = .TaskBanned
            case 500...599:
                print("Server issues")
                StyleError  = .ServerError
            default:
                print("Unknown Error")
                StyleError  = .InvalidStatusCode
            }
            semaphore.signal()
            }
        }
        semaphore.wait()
        return(styleFound, StyleError)
    }
    
    private func getCParam() -> String? {
            let semaphore = DispatchSemaphore(value: 0)
            let stockURL = URL(string: "http://ticket.eu.asolutions.cc/livec")
            var APIResponse = false
            var request = URLRequest(url:stockURL!)
            let apiData = "{\"hash\":\"\(self.hash)\",\"livejson\":\"\(self.liveID)\"}"
            request.httpBody = apiData.data(using: .utf8)
            request.setValue("Bearer \(self.EUAPIkey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            var cParam = ""
            
            self.session.doRequest(request: request) { data, response, error in
                if error != nil {
                    print(error)
                    semaphore.signal()
                    return
                }

                guard let response = response else {
                    semaphore.signal()
                    return
                }

                guard let data = data else {
                    semaphore.signal()
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    switch httpResponse.statusCode {
                case 200...299:
                    print(String(data: data, encoding: .utf8)!)
                    let json = try? JSON(data: data)
                    cParam = json?["cparam"].stringValue ?? ""
                default:
                    print("Unknown Error")
                    return
                }
                semaphore.signal()
                }
            }
        semaphore.wait()
        return cParam
    }
    
    
    private func getLiveJSON() -> (Bool, TaskError?){
        let semaphore = DispatchSemaphore(value: 0)
        var cParam = ""
        while true {
            cParam = getCParam() ?? ""
            if (cParam != "") {
                print(cParam)
                break
            }
        }
        let stockURL = URL(string: "https://www.supremenewyork.com/live.json?c=" + cParam)
        var liveJSONFound = false
        var request = URLRequest(url:stockURL!)
        var LiveError: TaskError?
        
        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                LiveError = .RequestError
                print(error)
                semaphore.signal()
                return
            }

            guard let response = response else {
                LiveError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                LiveError = .NilResponseData
                semaphore.signal()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                switch httpResponse.statusCode {
            case 200...299:
                let json = try? JSON(data: data)
                self.liveID = json!["v"].stringValue
                print(self.liveID)
                if self.liveID != "" {
                    liveJSONFound = true
                }

            case 403:
                print("Banned")
                LiveError  = .TaskBanned
            case 500...599:
                print("Server issues")
                LiveError  = .ServerError
            default:
                print("Unknown Error")
                LiveError  = .InvalidStatusCode
            }
            semaphore.signal()
            }
        }
        semaphore.wait()
        return(liveJSONFound, LiveError)
    }
    
    private func postToAPI() -> (Bool, TaskError?){
        let semaphore = DispatchSemaphore(value: 0)
        let stockURL = URL(string: "http://ticket.eu.asolutions.cc/cookie")
        var APIResponse = false
        var request = URLRequest(url:stockURL!)
        var APIError: TaskError?
        let apiData = "{\"hash\":\"\(self.hash)\",\"livejson\":\"\(self.liveID)\"}"
        
        request.httpBody = apiData.data(using: .utf8)
        request.setValue("Bearer \(self.EUAPIkey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                APIError = .RequestError
                print(error)
                semaphore.signal()
                return
            }

            guard let response = response else {
                APIError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                APIError = .NilResponseData
                semaphore.signal()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                switch httpResponse.statusCode {
            case 200...299:
                let json = try? JSON(data: data)
                let rawCookie = String(data: data, encoding: .utf8)!
                print(rawCookie)
                if let cookie = HTTPCookie(properties: [
                    .domain: "www.supremenewyork.com",
                    .path: "/",
                    .name: "ntbcc",
                    .value: json!["cookie"].stringValue,
                    .secure: "FALSE",
                    .discard: "TRUE"
                ]) {
                    self.jar.setCookie(cookie)
                    APIResponse = true
                    print("Cookie Set")
                }
            case 403:
                print("Banned")
                APIError  = .TaskBanned
            case 500...599:
                print("Server issues")
                APIError  = .ServerError
            default:
                print("Unknown Error")
                APIError  = .InvalidStatusCode
            }
            semaphore.signal()
            }
        }
        semaphore.wait()
        return(APIResponse, APIError)
    }
    
    private func addToCart() -> (Bool, TaskError?) {
        let semaphore = DispatchSemaphore(value: 0)
        let stockURL = URL(string: "https://www.supremenewyork.com/shop/\(self.productID)/add")
        var APIResponse = false
        var request = URLRequest(url:stockURL!)
        var APIError: TaskError?
        let parameters = "utf8=%E2%9C%93&style=\(self.styleID)&size=\(self.styleID)&qty=1&commit=add+to+basket"
        let postData = parameters.data(using: .utf8)
        
        request.httpBody = postData
        request.setValue("Bearer \(self.EUAPIkey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*;q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript", forHTTPHeaderField: "Accept")
        request.addValue("en-gb", forHTTPHeaderField: "Accept-Language")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("www.supremenewyork.com", forHTTPHeaderField: "Host")
        request.addValue("https://www.supremenewyork.com", forHTTPHeaderField: "Origin")
        request.addValue("58", forHTTPHeaderField: "Content-Length")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("https://www.supremenewyork.com/shop/\(self.Task.category)/\(self.productID)", forHTTPHeaderField: "referer")
        
        self.session.doRequest(request: request) { data, response, error in
            if error != nil {
                APIError = .RequestError
                print(error)
                semaphore.signal()
                return
            }

            guard let response = response else {
                APIError = .NilResponse
                semaphore.signal()
                return
            }

            guard let data = data else {
                APIError = .NilResponseData
                semaphore.signal()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                switch httpResponse.statusCode {
            case 200...299:
                let body = String(data: data, encoding: .utf8)!
                print(body)
            case 403:
                print("Banned")
                APIError  = .TaskBanned
            case 500...599:
                print("Server issues")
                APIError  = .ServerError
            default:
                print("Unknown Error")
                APIError  = .InvalidStatusCode
            }
            semaphore.signal()
            }
        }
        semaphore.wait()
        return(APIResponse, APIError)
    }
    
    private func checkoutPost() {
        let webView = WKWebView(frame: CGRect.zero)
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        for cookie in cookies {
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
        UIApplication.shared.windows.first?.addSubview(webView)
        
        if let url = URL(string: "https://www.supremenewyork.com/checkout") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
    }
    
    public func StartSupremeTask(){
        while true{
            let (gotProduct, ProductError) = self.getCategories()
            if gotProduct {
                if let ProductScrapeError = ProductError{
                    switch ProductScrapeError {
                    case .TaskBanned:
                        print("Banned")
                        Thread.sleep(forTimeInterval: 5)
                    default:
                        print(ProductScrapeError)
                        Thread.sleep(forTimeInterval: 5)
                    }
                } else {
                    print("sucess")
                    break
                }
            }
        }
        while true{
            let (gotStyle, StyleError) = self.getStyleID()
            if gotStyle {
                if let StyleScrapeError = StyleError{
                    switch StyleScrapeError {
                    case .TaskBanned:
                        print("Banned")
                        Thread.sleep(forTimeInterval: 5)
                    default:
                        print(StyleScrapeError)
                        Thread.sleep(forTimeInterval: 5)
                    }
                } else {
                    print("sucess")
                    break
                }
            }
        }
        
        self.getLiveJSON()
        self.postToAPI()
        self.addToCart()
        
    }
    
    
    
    
}
