import Foundation

struct RadioStation: Codable, Identifiable, Hashable {
    let id = UUID()
    let stationuuid: String
    let name: String
    let url_resolved: String
    let countrycode: String
    let favicon: String?
    var isFavorite: Bool = false

    private enum CodingKeys: String, CodingKey {
        case stationuuid, name, url_resolved, countrycode, favicon
    }
    
    // Conformance to Hashable
    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        lhs.stationuuid == rhs.stationuuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stationuuid)
    }
}
