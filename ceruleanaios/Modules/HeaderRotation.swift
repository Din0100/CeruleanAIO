//
//  HeaderRotation.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 11/04/2021.
//

import Foundation

class HeaderRotation{
    
    var mobileURL:String
    var desktopURL:String
    
    init(pid: String){
        mobileURL = "https://m.jdsports.co.uk/product/\(pid)/"
        desktopURL = "https://www.jdsports.co.uk/product/\(pid)/"
    }
    
    
    func returnHeader() {
        
    }
}
