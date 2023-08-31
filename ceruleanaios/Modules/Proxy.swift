//
//  Proxy.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 28/03/2021.
//

import Foundation

var Proxies0: [Proxy] = []
var ProxyStates: [String: ProxyState] = [:]

enum ProxyState: Int, Codable {
    case Free = 0
    case Banned = 1
}

class Proxy: CustomStringConvertible {
    var host: String
    var port: Int
    var authorisation: String?
    init(host:String, port:Int, username: String? = nil, password: String? = nil) {
        self.host = host
        self.port = port

        if let username = username, let password = password {
            authorisation = "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
        }
    }
    
    func createSessionConfig(existingSessionConfiguration: URLSessionConfiguration?, userAgent: String) -> URLSessionConfiguration {
        var sessionConfiguration = existingSessionConfiguration
        
        if sessionConfiguration == nil {
            sessionConfiguration = URLSessionConfiguration.ephemeral
            if userAgent != "" {
                sessionConfiguration!.httpAdditionalHeaders = ["User-Agent": userAgent]
            }
        }
        
        sessionConfiguration?.connectionProxyDictionary = [AnyHashable: Any]()
        sessionConfiguration!.connectionProxyDictionary?[kCFNetworkProxiesHTTPEnable as String] = 1
        sessionConfiguration!.connectionProxyDictionary?[kCFNetworkProxiesHTTPProxy as String] = self.host
        sessionConfiguration!.connectionProxyDictionary?[kCFNetworkProxiesHTTPPort as String] = self.port
        sessionConfiguration!.connectionProxyDictionary?[kCFProxyTypeKey as String] = kCFProxyTypeHTTPS
        sessionConfiguration!.connectionProxyDictionary?[kCFStreamPropertyHTTPSProxyHost as String] = self.host
        sessionConfiguration!.connectionProxyDictionary?[kCFStreamPropertyHTTPSProxyPort as String] = self.port
        print(sessionConfiguration)


        if authorisation != nil {
            if (sessionConfiguration!.httpAdditionalHeaders) != nil {
                sessionConfiguration!.httpAdditionalHeaders!["Proxy-Authorization"] = authorisation!
            } else {
                if userAgent != "" {
                    sessionConfiguration!.httpAdditionalHeaders = [
                        "User-Agent": userAgent,
                        "Proxy-Authorization": "Basic \(self.authorisation!)"]
                } else {
                    sessionConfiguration!.httpAdditionalHeaders =  [ "Proxy-Authorization": "Basic \(self.authorisation!)"]
                }
    
            }
        }

        return sessionConfiguration!
    }
    
    var description: String {
        return "http://\(host):\(port)"
    }
}
