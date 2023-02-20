import SwiftUI

struct TravelView: View {
    @EnvironmentObject var kth_vm: KTH_VM
    var travelTime: String
    var stopCount: String
    var objDetail: [OutPutDetails]
    
    var body: some View {
        VStack{
            Text("Restid: \(travelTime)")
            Text("Antal stopp: \(stopCount)")
            List {
                ForEach(objDetail){ OutPutDetails in
                    Text("Avgång: \(OutPutDetails.startDateTime)")
                    Text("Från: \(OutPutDetails.travelOrigin)")
                    Text("Transportsätt: \(OutPutDetails.travelType)")
                    Text("Destination: \(OutPutDetails.travelDestination)")
                    Text("Ankomst: \(OutPutDetails.arrivalDateTime)")
                    Text("------------------------------------------")
                }
            }
        }
    }
}
