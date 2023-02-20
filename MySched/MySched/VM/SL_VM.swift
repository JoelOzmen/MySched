import Foundation
import CoreLocation
import Combine
import Network

class SL{
    
    // Variabler
    private (set) var outPutContainer : [OutPutContainer] = []
    private (set) var outPutDetails : [OutPutDetails] = []
    
    // Hämtar SL data för koordinater och tid
    func getSLdata(fromlat: String, fromlong: String,tolat: String, tolong: String,strDate: String, strTime: String) {
        var tempID : Int = 0
        var tempDetID : Int = 0
        let session = URLSession.shared
        var arrivalDateTime : String = ""
        var startDateTime: String = ""
        var changeCount : Int = 0
        var firstStep : Bool = true
        
        let url = URL(string: "https://api.resrobot.se/v2/trip?format=json&originCoordLat=\(fromlat)&originCoordLong=\(fromlong)&destCoordLat=\(tolat)&destCoordLong=\(tolong)&showPassingPoints=true&key=41e85488-63eb-4c3d-9115-38281d900d56&date=\(strDate)&time=\(strTime)&searchForArrival=1")!
        
        print("https://api.resrobot.se/v2/trip?format=json&originCoordLat=\(fromlat)&originCoordLong=\(fromlong)&destCoordLat=\(tolat)&destCoordLong=\(tolong)&showPassingPoints=true&key=41e85488-63eb-4c3d-9115-38281d900d56&date=\(strDate)&time=\(strTime)&searchForArrival=1")
        
        let task = session.dataTask(with: url) { [self] data, response, error in
            if let urlContent = data, let _ = String(data: urlContent, encoding: .utf8) {
                if let result = try? JSONDecoder().decode(TripContainer.self, from: data!) {
                    outPutContainer = []
                    for oneRow in result.Trip {
                        outPutDetails = []
                        changeCount = oneRow.LegList.Leg.count
                        firstStep = true
                        for oneRowPart in oneRow.LegList.Leg {
                            addOutPutDetails(_type: oneRowPart.type,
                             _sDT: "\( oneRowPart.Origin.date) \( oneRowPart.Origin.time)",
                             _aDT: "\( oneRowPart.Destination.date) \( oneRowPart.Destination.time)",
                             _tDir: (oneRowPart.direction != nil ? String(oneRowPart.direction!) : ""),
                             _tDur: (oneRowPart.duration != nil ? formatDurationTime(duration: String(oneRowPart.duration!)) : ""),
                             _tO: oneRowPart.Origin.name,
                             _tD: oneRowPart.Destination.name,
                            _id: tempDetID)
                            tempDetID = tempDetID + 1
                            if firstStep {
                                startDateTime = "\( oneRowPart.Origin.date) \( oneRowPart.Origin.time)"
                            }
                            arrivalDateTime = "\( oneRowPart.Destination.date) \( oneRowPart.Destination.time)"
                            firstStep=false
                        }
                        addOutPutContainer(_sDT: startDateTime, _aDT: arrivalDateTime, _tT: formatDurationTime(duration: String(oneRow.duration)), _sC: String(changeCount), _d: outPutDetails, _id: tempID)
                        tempID = tempID + 1
                    }
                }
                else{
                    print("not working")
                }
            }
        }
        task.resume()
    }
    
    // Formatering av hämtad kod i tid
    func formatDurationTime(duration: String) -> String {
        var duration = duration
        if duration.hasPrefix("PT") { duration.removeFirst(2) }
        let hour, minute, second: Double
        if let index = duration.firstIndex(of: "H") {
            hour = Double(duration[..<index]) ?? 0
            duration.removeSubrange(...index)
        }
        else { hour = 0 }
        if let index = duration.firstIndex(of: "M") {
            minute = Double(duration[..<index]) ?? 0
            duration.removeSubrange(...index)
        }
        else { minute = 0 }
        if let index = duration.firstIndex(of: "S") {
            second = Double(duration[..<index]) ?? 0
        }
        else { second = 0 }
        return Formatter.positional.string(from: hour * 3600 + minute * 60 + second) ?? "0:00"
    }
    
    // Lägger till värden i en output array
    func addOutPutContainer(_sDT: String, _aDT: String, _tT: String, _sC: String, _d: [OutPutDetails], _id: Int){
        outPutContainer.append(OutPutContainer(startDateTime: _sDT, arrivalDateTime: _aDT, travelTime: _tT, stopCount: _sC, details: _d, id: _id))
    }
    
    // Lägger till detaljer i en output array
    func addOutPutDetails(_type: String, _sDT: String, _aDT: String, _tDir: String, _tDur: String, _tO: String, _tD: String, _id: Int){
        outPutDetails.append(OutPutDetails(travelType: _type, startDateTime: _sDT, arrivalDateTime: _aDT, travelDuration: _tDur, travelDirection: _tDir, travelOrigin: _tO, travelDestination: _tD, id: _id ))
    }
}

// Formatterar datum
extension Formatter {
    static let positional: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        return formatter}()
}
