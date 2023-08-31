//
//  PostTicket.swift
//  PyroPreme
//
//  Created by Amaan Syed on 16/05/2021.
//

import Foundation
import Foundation
import UIKit
import SwiftUI
import SwiftSoup
import SwiftyJSON

class Ticket{
    var Hash = ""
    var TicketBody = ""
    
    init(){
        print("getting ticket")
    }
    
    private func getHash() -> Void {
        let semaphore = DispatchSemaphore(value: 0)
        let url = URL(string: "https://www.supremenewyork.com/ticket.js")
        let request = URLRequest(url:url!)
        
        URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil{
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
            
//            print(String(data: data, encoding: .utf8)!)
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                switch httpResponse.statusCode {
                case 200...299:
                    print("got body")
                    self.TicketBody = String(data: data, encoding: .utf8)!
//                    print(self.TicketBody)
                    semaphore.signal()
                default:
                    semaphore.signal()
                    return
                }
            }
        }.resume()
        semaphore.wait()
    }
    
    private func postTicket(){
        print("posting ticket")
        let semaphore = DispatchSemaphore(value: 0)
        let url = URL(string: "http://ticket.eu.asolutions.cc/ticket")
        var request = URLRequest(url:url!)
        let hash = self.TicketBody.data(using: .utf8)?.base64EncodedString()
        let params: String = "{\"rawscript\":\"\(hash!)\",\"agent\":\"mobile\"}"
//        print(params)
        let postData = params.data(using: .utf8)
        let EUAPIkey = "186b2c39-6b93-4e07-b575-236a4fec84bb"
        
        request.httpBody = postData
        request.setValue("Bearer \(EUAPIkey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil{
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
                print(String(data: data, encoding: .utf8)!)
                switch httpResponse.statusCode {
                case 200...299:
                    let json = try? JSON(data:data)
                    self.Hash = json!["hash"].stringValue
                    print(self.Hash)
                    semaphore.signal()
                default:
                    semaphore.signal()
                    return
                }
            }
            
        }.resume()
        }
    
    public func startTicket() -> String {
        while true{
            var response = self.getHash()
            if TicketBody != "" {
                break
            }
            Thread.sleep(forTimeInterval: 4)
            }
        while true{
            var response = self.postTicket()
            if self.Hash != "" {
                break
            }
            Thread.sleep(forTimeInterval: 10)
            }
        
//        print(self.Hash)
        return self.Hash
        }
    
}
    
    

