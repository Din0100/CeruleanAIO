//
//  TaskListItem.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 09/04/2021.
//

import SwiftUI


struct TaskListItem: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Profile.entity(), sortDescriptors:[]) var Profiles: FetchedResults<Profile>
    @FetchRequest(entity: Proxies.entity(), sortDescriptors:[]) var Proxy: FetchedResults<Proxies>
    let task:Task
    
    @State var TaskState = "idle"
    
    var body: some View {
        HStack{
            
            VStack(alignment: .leading) {
                Text(task.taskname ?? "Could not fetch Task Name")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                Text(task.profile ?? "Unknown Profile")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                
                Text(TaskState)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundColor(.green)
                
            
            }
            Spacer()
            
            
            Button(action: {
                print("button clicked")
                TaskState = "Starting Task"
                
                switch task.siteType{
                case "frontend":
                    DispatchQueue.global(qos: .background).async {
                        var setupError = MeshFrontEndTask(taskdata: task, proxies: Proxy, profiles: Profiles).StartMeshTask()
                        while setupError != nil {
                            if let error = setupError {
                                DispatchQueue.main.async {
                                    TaskState = error.taskStatus
                                
                                print("Setup Error - \(error.error) in \(error.state)")
                                }
                            }
                            setupError = MeshFrontEndTask(taskdata: task, proxies: Proxy, profiles: Profiles).StartMeshTask()
    //                                    usleep(UInt32(5) * 1000)
                            
                            TaskState = "Checked Out"
                        }
                    }
                case "backend":
                    DispatchQueue.global(qos: .background).async {
                        var setupError = MeshBackEndTask(taskdata: task, proxies: Proxy, profiles: Profiles).startBackendTask()
                        while setupError != nil {
                            if let error = setupError {
                                DispatchQueue.main.async {
                                    TaskState = error.taskStatus

                                print("Setup Error - \(error.error) in \(error.state)")
                                }
                            }
                            setupError = MeshBackEndTask(taskdata: task, proxies: Proxy, profiles: Profiles).startBackendTask()

                            TaskState = "Checked Out"
                        }
                    }
                    
                default:
                    print("error")
                }
 
            }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.green)
                    
                    
            }
        }
        
        .padding(.all, 10.0)
    }
}

//struct TaskListItem_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
