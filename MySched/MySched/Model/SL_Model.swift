import Foundation

// MARK: - DayRow
struct TripContainer: Codable {
    let Trip: [Trip]
}

// MARK: - Trip
struct Trip: Codable {
    var LegList: LegList
    var duration: String
}

struct GeoKoordinater{
    var latitude : String
    var longitude: String
    var valid: Bool
}

// MARK: - LegList
struct LegList: Codable {
    var Leg: [Leg]
}

// MARK: - Leg
struct Leg: Codable {
    var Origin, Destination: Destination
    var name: String
    var type: String
    var duration: String?
    var dist: Int?
    var Product: Product?
    var direction: String?
}

// MARK: - Destination
struct Destination: Codable {
    var name: String
    let type: String
    let lon, lat: Double
    let time, date: String
}

// MARK: - Product
struct Product: Codable {
    let name: String
}

// MARK: - OutPutContainer
struct OutPutContainer: Identifiable{
    var startDateTime: String
    var arrivalDateTime: String
    var travelTime: String
    var stopCount: String
    var details: [OutPutDetails]
    var id: Int
}

// MARK: - OutPutDetails
struct OutPutDetails : Identifiable{
    var travelType: String
    var startDateTime: String
    var arrivalDateTime: String
    var travelDuration: String
    var travelDirection: String
    var travelOrigin: String
    var travelDestination: String
    var id: Int
}


