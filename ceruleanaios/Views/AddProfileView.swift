//
//  AddProfileView.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 21/03/2021.
//

import SwiftUI

/*89*/
struct AddProfileView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @State private var ProfileName:String = ""
    @State private var Webhook:String = ""
    @State private var Number:String = ""
    @State private var FirstName:String = ""
    @State private var LastName:String = ""
    @State private var Email:String = ""
    
    @State private var Address1:String = ""
    @State private var Address2:String = ""
    @State private var HouseNumber:String = ""
    @State private var ZipCode:String = ""
    @State private var City:String = ""
    @State private var Province:String = ""
    @State private var Country:String = ""
    @State private var CountryCode:String = ""
    
    @State private var CardNumber:String = ""
    @State private var CardHolder:String = ""
    @State private var CardExpiryMonth:String = ""
    @State private var CardExpiryYear:String = ""
    @State private var CVC:String = ""
    
    @State private var CaptchaMethod:String = ""
    @State private var CaptchaKey:String = ""
    
    var ExpiryYears = ["2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028"]
    
    var CaptchaMethods = ["CapMonster", "2Captcha"]
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Profile Details")){
                    TextField("Profile Name", text: $ProfileName)
                    TextField("First Name", text: $FirstName)
                    TextField("Last Name", text: $LastName)
                    TextField("Number", text: $Number)
                    TextField("Discord Webhook", text: $Webhook)
                    TextField("Email", text: $Email)
                }
                
                Section(header: Text("Delivery/Billing Details")){
                    TextField("Address 1", text: $Address1)
                    TextField("Address 2", text: $Address2)
                    TextField("House Number", text: $HouseNumber)
                    TextField("Zip Code", text: $ZipCode)
                    TextField("City", text: $City)
                    TextField("Province", text: $Province)
                    Picker("Country", selection: $Country){
                        ForEach(countries, id: \.self){
                            Text($0)
                        }
                    }
                    TextField("Country Code", text: $CountryCode)
                }
                
                Section(header: Text("Payment Details")){
                    TextField("Card Number", text: $CardNumber)
                    TextField("Card Holder", text: $CardHolder)
                    Picker("Expiry Month", selection: $CardExpiryMonth){
                        ForEach(1..<13){
                            Text("\($0)")
                        }
                    }
                    Picker("Expiry Year", selection: $CardExpiryYear){
                        ForEach(ExpiryYears, id: \.self){
                            Text("\($0)")
                        }
                    }
                    TextField("CVC", text: $CVC)
                    
                }
                
                Section(header: Text("Captcha Settings")){
                    Picker("Captcha Method", selection: $CaptchaMethod){
                        ForEach(CaptchaMethods, id: \.self){
                            Text("\($0)")
                        }
                    }
                    TextField("Captcha Key", text: $CaptchaKey)
                    
                }
                
                Section{
                    Button("Save"){
                        let newprofile = Profile(context: self.moc)
                        newprofile.profilename = self.ProfileName
                        newprofile.firstname = self.FirstName
                        newprofile.lastname = self.LastName
                        newprofile.number = self.Number
                        newprofile.webhook = self.Webhook
                        newprofile.email = self.Email
                        
                        newprofile.address1 = self.Address1
                        newprofile.address2 = self.Address2
                        newprofile.housenumber = self.HouseNumber
                        newprofile.zipcode = self.ZipCode
                        newprofile.city = self.City
                        newprofile.province = self.Province
                        newprofile.country = self.Country
                        newprofile.countrycode = self.CountryCode
                        
                        newprofile.cardnumber = self.CardNumber
                        newprofile.cardholder = self.CardHolder
                        newprofile.cardexpirymonth = self.CardExpiryMonth
                        newprofile.cardexpiryyear = self.CardExpiryYear
                        newprofile.cardcvc = self.CVC
                        
                        newprofile.capkey = self.CaptchaKey
                        newprofile.capmethod = self.CaptchaMethod
                        
                        try? self.moc.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }.navigationTitle("Add Profile")
        }
    }
}

struct AddProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AddProfileView()
    }
}

