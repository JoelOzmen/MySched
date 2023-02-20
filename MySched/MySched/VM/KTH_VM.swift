import Foundation
import SwiftSoup

class KTH_VM: ObservableObject{
    
    // Variabler
    @Published var courseOne: String = ""
    @Published var courseTwo: String = ""
    @Published var courseThree: String = ""
    @Published var heading: String = "Välkommen"
    
    @Published var disableButton: Bool = true
    @Published var AcademicQuarter: Bool = false
    @Published var errorCatch: Bool = false
    
    @Published var timeInHand: Double = 0
    
    @Published var courseEntries: CourseEntries? //Listan med title, start, end
    @Published var objSL: SL = SL()
    @Published var outPutEntry: [OutPutEntry] = []
    
    var localOutPutEntry : [OutPutEntry] = []
    var localHeading : String = ""
    var timeToChange: Double = 0
    
    // Error enum
    private enum FetchError: Error {
        case runtimeError(String)
    }
    
    // Init
    init(){
        getCourses()
    }
    
    // Sparar inställningar
    func saveCourses(){
        let defaults = UserDefaults.standard
        defaults.set(courseOne, forKey: "course1")
        defaults.set(courseTwo, forKey: "course2")
        defaults.set(courseThree, forKey: "course3")
        defaults.set(AcademicQuarter, forKey: "AcademicQuarter")
        defaults.set(timeInHand, forKey: "timeInHand")
    }
    
    // Hämtar inställningar
    func getCourses(){
        let defaults = UserDefaults.standard
        courseOne = defaults.string(forKey: "course1") ?? ""
        courseTwo = defaults.string(forKey: "course2") ?? ""
        courseThree = defaults.string(forKey: "course3") ?? ""
        AcademicQuarter = defaults.bool(forKey: "AcademicQuarter")
        timeInHand = defaults.double(forKey: "timeInHand")
    }
    
    // Lägger till i en output array till vyn
    func addOutPutEntry(_start: String, _stop: String, _title: String, _url: String, _lat: String, _long: String, _courseCode: String){
        outPutEntry.append(OutPutEntry(start: _start, stop: _stop, title: _title, url: _url, lat: _lat, long: _long, courseCode: _courseCode))
    }
    
    // Laddar in kurser från koordinater in i array och sorterar efter den med närmaste datumet
    func loadCourses(fromLat: String, fromLong: String) {
        localOutPutEntry = []
        Task{
            var ary : [Entry] = []
            var koordinater : GeoKoordinater?
            if courseOne != "" {
                ary = await requestCE(courseString: courseOne)
                koordinater = getHTMLData(myURLString: ary[0].locations[0].url)
                localOutPutEntry.append(OutPutEntry(start: ary[0].start, stop: ary[0].end, title: ary[0].title, url: ary[0].locations[0].url, lat: koordinater?.latitude ?? "", long: koordinater?.longitude ?? "", courseCode: courseOne))
            }
            if courseTwo != "" {
                ary = await requestCE(courseString: courseTwo)
                koordinater = getHTMLData(myURLString: ary[0].locations[0].url)
                localOutPutEntry.append(OutPutEntry(start: ary[0].start, stop: ary[0].end, title: ary[0].title, url: ary[0].locations[0].url, lat: koordinater?.latitude ?? "", long: koordinater?.longitude ?? "", courseCode: courseTwo))
            }
            if courseThree != "" {
                ary = await requestCE(courseString: courseThree)
                koordinater = getHTMLData(myURLString: ary[0].locations[0].url)
                localOutPutEntry.append(OutPutEntry(start: ary[0].start, stop: ary[0].end, title: ary[0].title, url: ary[0].locations[0].url, lat: koordinater?.latitude ?? "", long: koordinater?.longitude ?? "", courseCode: courseThree))
            }
            
            // Sorterar arrayen
            localOutPutEntry.sort {
                $0.start < $1.start
            }
            
            if localOutPutEntry.count > 0 {
                if(AcademicQuarter == true){timeToChange = (15 - timeInHand.rounded())}
                else{timeToChange = timeInHand.rounded()}
                let Strformat: String = String(localOutPutEntry[0].start.suffix(8))
                let str: String = addMinutesToTime(_time: String(Strformat.prefix(5)), _add: -timeToChange)
                
                objSL.getSLdata(fromlat: fromLat, fromlong: fromLong, tolat: localOutPutEntry[0].lat, tolong: localOutPutEntry[0].long, strDate: String(localOutPutEntry[0].start.prefix(10)), strTime: str)
                
                localHeading = "\(localOutPutEntry[0].courseCode.uppercased()) \(localOutPutEntry[0].title) \(localOutPutEntry[0].start)"
            }
            else{
                localHeading = "Inga kurser funna"
            }
           
        }
        heading = localHeading
        outPutEntry = localOutPutEntry
    }
    
    // Formatering för datum
    func addMinutesToTime(_time: String,_add: Double)-> String {
        var time : String = _time
        var minutes : Double = 0.0
        var hour : Double = 0.0
        var addMinutes : Double = _add
        
        if time.count == 5{ hour = Double(time.prefix(2))!}
        else{  hour = Double(time.prefix(1))! }
        minutes = Double(time.suffix(2))!
        minutes = minutes / 60
        addMinutes = addMinutes / 60
        hour = hour + minutes + addMinutes
        minutes = hour - floor(hour)
        hour = hour - minutes
        minutes = minutes * 60
        time = String(minutes)
        if time.count == 3 {
            time = "0" + time
        }
        time = String(time.prefix(2))
        time = String(format: "%.0f", hour) + ":" + time
        if time.count == 4 {
            time = "0" + time
        }
        return time
    }

    // Scrapar fram locations från HTML
    func getHTMLData(myURLString: String) -> GeoKoordinater{
        var document: Document = Document.init("")
        
        var foundLat, foundLong : String
        foundLat = ""
        foundLong = ""
        guard let myURL = URL(string: myURLString)
        else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return GeoKoordinater(latitude: "", longitude: "", valid: false)
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            document = try SwiftSoup.parse(myHTMLString)
            
            let price = try document.getElementsByTag("meta")
            for metadata in price {
                let metadataStr = String(describing: metadata)
                if metadataStr.contains("longitude") {
                    foundLong = metadataStr.components(separatedBy: "\"")[3]
                }
                if metadataStr.contains("latitude") {
                    foundLat = metadataStr.components(separatedBy: "\"")[3]
                }
            }
        }
        catch let error {
            print("Error: \(error)")
            return GeoKoordinater(latitude: "", longitude: "", valid: false)
        }
        
        if foundLat != "" && foundLong != "" {
            return GeoKoordinater(latitude: foundLat, longitude: foundLong, valid: true)
        }
        else{
            return GeoKoordinater(latitude: "", longitude: "", valid: false)
        }
    }
    
    // Hämtar KTH kursens schema
    func requestCE(courseString: String) async  -> [Entry]{
        print("Ansluter till \(courseString)")
        var CE_List: [Entry] = []
        let course = Task { () -> CourseEntries in
            let url = URL(string: "https://www.kth.se/social/api/schema/v2/course/\(courseString)?endTime=2022-12-30")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let CE_Data = try JSONDecoder().decode(CourseEntries.self, from: data)
            return CE_Data
        }
        
        do {
            let CE_Data = try await course.value
            for entry in CE_Data.entries {
                let start = entry.start
                let end = entry.end
                let title = entry.title
                let locationList: [Location] = [Location(name: entry.locations[0].name, url: entry.locations[0].url)]
                CE_List.append(Entry(start: start, end: end, title: title, locations: locationList))
            }
        }
        catch {
            print("There was an error loading user data.")
        }
        return CE_List
    }
    
}
