//
//  ContentView.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 18/03/2021.
//

import SwiftUI
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



struct ContentView: View {
    var body: some View {
        TabView{
            TaskList()
                .tabItem { Image(systemName: "list.dash") }
            ProfilesList()
                .tabItem { Image(systemName: "person.crop.circle.fill") }
            ProxiesView()
                .tabItem { Image(systemName: "network") }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
