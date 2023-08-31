//
//  SettingView.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 21/03/2021.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var CaptchaMethod:String = ""
    @State private var CaptchaKey:String = ""
    
    var CaptchaMethods = ["2captcha", "Capmonster"]
    
    var body: some View {
        NavigationView{
            
            }.navigationTitle("Settings")
        }
    }


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
