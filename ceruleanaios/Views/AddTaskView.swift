//
//  AddTaskView.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 18/03/2021.
//

import SwiftUI
import CoreData



struct AddTaskView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
   
    
    @State private var TaskName:String = ""
    @State private var Profile:String = ""
    @State private var Url:String = ""
    @State private var Quantity:String = "1"
    @State private var Delay:Int32 = 1
    @State private var PaymentMethod:String = ""
    @State private var Size:String = ""
    @State private var Site:String = ""
    @State private var siteType: String = ""
    
    let paymentMethods = ["Card", "PayPal"]
    let profiles1 = ["dino", "amaan"]
    let sites = ["jdsports", "footpatrol","Size"]
    var allprofiles = [String]()
    let siteTypeArray = ["frontend", "backend"]
    
   
    
    
    init(profiles: FetchedResults<Profile>) {
        let profile = profiles
        for item in profile{
            allprofiles.append(item.profilename ?? "")
        }
        
    }
    
    
    var body: some View {
        NavigationView{
            Form{
                
            
                Section{
                    TextField("Task Name", text: $TaskName)
                    TextField("PID", text:$Url)
                }
                
                Section{
                    Picker("Profile", selection: $Profile){
                        ForEach(allprofiles, id: \.self){
                            Text($0)
                        }
                    }
                    
                    Picker("Payment Method", selection: $PaymentMethod){
                        ForEach(paymentMethods, id: \.self){
                            Text($0)
                        }
                    }
                    
                }
                
                Section{
                    
                    Picker("Site", selection: $Site){
                        ForEach(sites, id: \.self){
                            Text($0)
                        }
                    }
                    
                    Picker("Site Type", selection: $siteType) {
                        ForEach(siteTypeArray, id: \.self){
                            Text($0)
                        }
                    }
                    
                    Picker("Delay", selection: $Delay) {
                        ForEach(0..<11){
                            Text("\($0)")
                        }
                    }
                    
                    TextField("Quantity", text: $Quantity)
                    
                    TextField("Size", text: $Size)
                }
                
                Section{
                    Button("Save") {
                       
                       
                        for _ in 1...Int(self.Quantity)! {
                            let newtask = Task(context: self.moc)
                            newtask.taskname = self.TaskName
                            newtask.profile = self.Profile
                            newtask.url = self.Url
                            newtask.qty = Int16(self.Quantity) ?? 1
                            newtask.delay = Int32(self.Delay)
                            newtask.paymentmethod = self.PaymentMethod
                            newtask.size = self.Size
                            newtask.id = UUID()
                            newtask.site = self.Site
                            newtask.siteType = self.siteType
                            
                            
                            try? self.moc.save()
                        }
                           
                        
            
                        self.presentationMode.wrappedValue.dismiss()
                    }.disabled(TaskName.isEmpty || Profile.isEmpty || Url.isEmpty || Quantity.isEmpty || Size.isEmpty || Site.isEmpty ||  siteType.isEmpty)
                }
            }.navigationTitle("Add Task")
        
        }
    }
}

//struct AddTaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTaskView()
//    }
//}
