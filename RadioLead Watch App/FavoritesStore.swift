import Foundation

class FavoritesStore: ObservableObject {
    @Published var favorites: [RadioStation] {
        didSet {
            saveFavorites()
        }
    }

    private let favoritesKey = "favorites"

    init() {
        self.favorites = []
        loadFavorites()
    }

    func addFavorite(_ station: RadioStation) {
        if !favorites.contains(where: { $0.stationuuid == station.stationuuid }) {
            var newStation = station
            newStation.isFavorite = true
            favorites.append(newStation)
        }
    }

    func removeFavorite(_ station: RadioStation) {
        favorites.removeAll { $0.stationuuid == station.stationuuid }
    }

    func isFavorite(_ station: RadioStation) -> Bool {
        favorites.contains { $0.stationuuid == station.stationuuid }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            if let decoded = try? JSONDecoder().decode([RadioStation].self, from: data) {
                self.favorites = decoded
                return
            }
        }
        self.favorites = []
    }
}
