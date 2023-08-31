//
//  ProxiesView.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 21/03/2021.
//

import SwiftUI
import Foundation
import UIKit

struct ProxiesView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Proxies.entity(), sortDescriptors:[]) var Proxy: FetchedResults<Proxies>
    
    @State private var proxies:String = ""
    
    @State private var saved = false
    
    var body: some View {
        NavigationView{
            Form{
         
                Section(header: Text("Enter Proxies")){
                    TextEditor(text: $proxies)
                        .frame(height: 400)
                    
                    Button("Save"){
                        
                        for item in Proxy{
                            self.moc.delete(item)
                            do{
                                try self.moc.save()
                            } catch {
                                print("Could not delete data")
                            }
                        }
                        
                        print("asdkfhj")
               
                        let lines = proxies.split(whereSeparator: \.isNewline)
                        for item in lines{
                            print("saved!")
                            let splitProxy = item.split(separator: ":")
                            print(splitProxy)
                            let newproxy = Proxies(context: self.moc)
                            newproxy.port = String(splitProxy[1])
                            newproxy.ip = String(splitProxy[0])
                            newproxy.username = String(splitProxy[2])
                            newproxy.password = String(splitProxy[3])
                            do{
                                try self.moc.save()
                            } catch {
                                print("Could not save proxies")
                            }
                           
                            proxies = ""
                            

                        }
                    }
                
                }
                
                
       
            }.navigationTitle("Proxies")
            
            
            
        } .onTapGesture {
            hideKeyboard()
                
        }
      
        
        
    }
}

struct ProxiesView_Previews: PreviewProvider {
    static var previews: some View {
        ProxiesView()
    }
}
