import SwiftUI
import Network

struct StartView: View {
    @EnvironmentObject var kth_vm: KTH_VM
    @ObservedObject var monitor = Network()
    @StateObject var locationManager = LocationManager()
    @FocusState private var focused: Bool
    @State private var showAlert = false
    @State private var courseAlert = false
    
    var userLatitude: String {return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"}
    var userLongitude: String {return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"}
    
    var body: some View {
        VStack{
            //Title and connection
            HStack{
                Text("MySched")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .padding(5)
                Spacer()
                Image(systemName: monitor.Connected ? "wifi" : "wifi.slash").font(.system(size: 18))
                Text(monitor.Connected ? "Connected" : "Not connected!")
            }
            .padding([.leading, .bottom, .trailing], 10.0)
            .alert(isPresented: $showAlert, content: {
                return Alert(title: Text("No internet connection"), dismissButton: .default(Text("OK")))
            })
            
            // Välkommen/Lektion
            Text(kth_vm.heading)
            
            //Lista med resor
            NavigationView{
                List {
                    ForEach(kth_vm.objSL.outPutContainer){ OutPutContainer in
                        NavigationLink(destination: TravelView(travelTime: OutPutContainer.travelTime, stopCount: OutPutContainer.stopCount, objDetail: OutPutContainer.details )){
                            VStack{
                                Text("Avgång: \(OutPutContainer.startDateTime)")
                                Text("Restid: \(OutPutContainer.travelTime)")
                                Text("Antal stopp: \(OutPutContainer.stopCount)")
                            }
                        }
                    }
                }
            }
            
            Spacer()
            //Textfields and Buttons
            VStack{
                Button(action: {
                    focused = false
                    checkConnection()
                    checkCourseAlert()
                    kth_vm.saveCourses()
                    kth_vm.loadCourses(fromLat: userLatitude, fromLong: userLongitude)
                }, label: {
                    Text("Sök resa")
                        .padding(8)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .background(Color(.systemGray4))
                })
                .cornerRadius(12)
            }
            .onAppear{
                kth_vm.loadCourses(fromLat: userLatitude, fromLong: userLongitude)
            }
            .alert(isPresented: $courseAlert, content: {
                return Alert(title: Text("No course filled in, please fill in at least one course"), dismissButton: .default(Text("OK")))
            })
            
        }
    }
    
    //Check connection to Wifi or cellular data
    func checkConnection(){
        if(monitor.Connected){
            showAlert = false
        }
        else{
            showAlert = true
        }
    }
    
    //Check if courses are filled in
    func checkCourseAlert(){
        if(kth_vm.courseOne == "" && kth_vm.courseTwo == "" && kth_vm.courseThree == ""){
            courseAlert = true
        }
        else{
            courseAlert = false
        }
    }
    
}
