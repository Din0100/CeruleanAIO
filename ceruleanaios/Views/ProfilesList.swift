//
//  ProfilesList.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 21/03/2021.
//

import SwiftUI

struct ProfilesList: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Profile.entity(), sortDescriptors:[]) var profiles: FetchedResults<Profile>
    
    @State private var ShowingAddProfileView = false
    
    var body: some View {
        NavigationView{
            
            List{
                ForEach(profiles, id: \.self){ profile in
                    HStack{
                        
                        VStack(alignment: .leading) {
                            Text(profile.profilename ?? "Could not fetch Profile ")
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
            
                            Text(profile.email ?? "Unknown Profile")
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                        }
                        Spacer()
                        
                    }
                    
                    .padding(.all, 10.0)
                }.onDelete(perform: { indexSet in
                    let deleteProfile = self.profiles[indexSet.first!]
                    self.moc.delete(deleteProfile)
                    
                    do{
                        try self.moc.save()
                    }catch{
                        print("Error")
                    }
                    
                })
            }
            
                .navigationTitle("Profiles")
                .navigationBarItems(trailing:
                                        
                                        
                                            Button(action: {
                                                self.ShowingAddProfileView.toggle()
                                            }) {
                                                Image(systemName: "plus.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                    .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(.black)
                                            }
                                  
                                    
                              
                                        
                    .sheet(isPresented: $ShowingAddProfileView, content: {
                        AddProfileView().environment(\.managedObjectContext, self.moc)
                    })
                                        
                )
            }
        }
    }

struct ProfilesList_Previews: PreviewProvider {
    static var previews: some View {
        ProfilesList()
    }
}
