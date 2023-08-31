//
//  TaskList.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 18/03/2021.
//

import SwiftUI
import Alamofire


struct TaskList: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Task.entity(), sortDescriptors:[]) var Tasks: FetchedResults<Task>
    @FetchRequest(entity: Profile.entity(), sortDescriptors:[]) var Profiles: FetchedResults<Profile>
    @FetchRequest(entity: Proxies.entity(), sortDescriptors:[]) var Proxy: FetchedResults<Proxies>
    @State private var ShowingAddTaskView = false
    var body: some View {
        NavigationView{
            
            List{
                ForEach(Tasks, id: \.self){ task in
                    TaskListItem(task: task)
                }.onDelete(perform: { indexSet in
                    let deleteTask = self.Tasks[indexSet.first!]
                    self.moc.delete(deleteTask)
                    
                    do{
                        try self.moc.save()
                    }catch{
                        print("Error")
                    }
                    
                })

            }
            
                .navigationTitle("Tasks")
 
                                    
                                 
                                      
                                           
                                    
            
                .navigationBarItems(leading:
                                        Button(action: {
                                            for task in Tasks{
                                                self.moc.delete(task)
                                                do{
                                                    try self.moc.save()
                                                }catch{
                                                    print("Error")
                                                }
                                                
                                            }
                                       
                                        }) {
                                            Image(systemName: "minus.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                                .foregroundColor(.black)
                                                
                                        }
                    
                    
                    
                    
                    , trailing:
                        Button(action: {
                        self.ShowingAddTaskView.toggle()
                            print(Locale.current)
                            DispatchQueue.global(qos: .background).async{
                                
                                SupremeTask(hash: "b0052b60ae6d3d6952b79cd2634ef839").StartSupremeTask()
//                                Ticket().startTicket()
                            }
                           
                   
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                            
                    })
                                        
                                     
                                
                                               
                                            
   
                                        
                    .sheet(isPresented: $ShowingAddTaskView, content: {
                        AddTaskView(profiles: Profiles).environment(\.managedObjectContext, self.moc)
                    })
                                        
                
        }
    }
}



