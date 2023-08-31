//
//  DiscordWebhook.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 09/04/2021.
//

import Foundation
import Sword
import SwiftyJSON

struct Webhook {
    var productName: String
    var productImage: String
//    var CheckoutLink: String
    var site: String
}

func DiscordWebhook(hook:Webhook, profile:Profile, PPlink:String, task:Task) {
    let semaphore = DispatchSemaphore(value: 0)
    
//    var messageString: String = PPLink


    guard let url = URL(string: profile.webhook ?? "https://discord.com/api/webhooks/830009069830012969/MXKxOqggCCxOhXKyysbaLPkJRRBkm2kiFgrJ07zofnBOdq_ChxZXsnPd1yBMlh7pkwQa") else { return }
    let messageJson: [String: Any] =
        [
          "username": "CeruleanIOS",
          "avatar_url": "https://pbs.twimg.com/profile_images/1380978546064175107/RZD_c6Hf_400x400.jpg",
          "content": "Checkout",
          "tts": false,
          "embeds": [
            [
              "title": "PayPal Checkout",
              "color": 1394585,
              "description": "Website",
              "timestamp": "",
                "url": PPlink,
              "author": [
                "name": "CeruleanIOS",
                "url": "https://twitter.com/ceruleanios",
                "icon_url": "https://pbs.twimg.com/profile_images/1380978546064175107/RZD_c6Hf_400x400.jpg"
              ],
              "image": [
                "url": ""
              ],
              "thumbnail": [
                "url": hook.productImage
              ],
              "footer": [
                "icon_url": ""
              ],
              "fields": [
                [
                  "name": "Product",
                    "value": hook.productName,
                  "inline": true
                ],
                [
                  "name": "Profile",
                    "value": task.profile
                ],
                [
                  "name": "Size",
                    "value": task.size
                ]
              ]
            ]
          ]
        ]
    let jsonData = try? JSONSerialization.data(withJSONObject: messageJson)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "content-type")
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request){(data, response, error) in
        print(data)
        print(response)
        print(error)
        semaphore.signal()
    }.resume()
    semaphore.wait()
}

func DiscordWebhook2(PPLink:String, profile:Profile) {
    let semaphore = DispatchSemaphore(value: 0)
    
    var messageString: String = PPLink


    guard let url = URL(string: profile.webhook ?? "https://discord.com/api/webhooks/778342718673387530/2aDtwnX02GEp-F-5Z9tFnIxxyXKQqNSSyrevlZltF9DIrHyVR189ykxDHozvdW5EtPYF") else { return }
    let messageJson: [String: Any] =
        [
          "content": PPLink
        ]
    let jsonData = try? JSONSerialization.data(withJSONObject: messageJson)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "content-type")
    request.httpBody = jsonData
//    URLSession.shared.dataTask(with: request){(data, response, error) in
//        print(data)
//        print(response)
//        print(error)
//        semaphore.signal()
//    }.resume()
//    semaphore.wait()
}



