import Foundation

// MARK: - CourseEntries
class CourseEntries: Identifiable, Codable {
    var entries: [Entry]
    
    init(_ entries: [Entry]) {
        self.entries = entries
    }
}

// MARK: - outPutEntry
struct OutPutEntry{
    var start, stop, title, url, lat, long, courseCode: String
}

// MARK: - Entry
class Entry: Identifiable, Codable {
    let start, end, title: String
    let locations: [Location]
    
    init(start: String, end: String, title: String, locations: [Location]){
        self.start = start
        self.end = end
        self.title = title
        self.locations = locations
    }
}

// MARK: - Location
class Location: Identifiable, Codable {
    let name: String
    let url: String
    
    init(name: String, url: String){
        self.name = name
        self.url = url
    }
}

// MARK: - appSettings
class AppSettings {
    var course1: String
    var course2: String
    var course3: String
    var academic: Bool
    var minAhead: Double
    
    init(course1: String, course2: String, course3: String, academic: Bool, minAhead: Double){
        self.course1 = course1
        self.course2 = course2
        self.course3 = course3
        self.academic = academic
        self.minAhead = minAhead
    }
    
}
