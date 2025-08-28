import SwiftUI

struct ContentView: View {
    @State private var stations = [RadioStation]()
    @State private var searchText = "US"
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var favoritesStore = FavoritesStore()
    
    private let radioService = RadioService()

    var body: some View {
        TabView {
            stationList
                .tabItem { Label("Stations", systemImage: "radio") }
            
            favoritesList
                .tabItem { Label("Favorites", systemImage: "star.fill") }
        }
    }

    private var stationList: some View {
        NavigationView {
            VStack {
                searchBar
                List(stations) { station in
                    stationRow(for: station)
                }
            }
            .navigationTitle("Watch Radio")
            .onAppear(perform: loadStations)
        }
    }
    
    private var favoritesList: some View {
        NavigationView {
            List(favoritesStore.favorites) { station in
                stationRow(for: station)
            }
            .navigationTitle("Favorites")
        }
    }

    private var searchBar: some View {
        HStack {
            // The unavailable .textFieldStyle modifier has been removed.
            TextField("Country Code", text: $searchText)
            
            Button("Search") {
                loadStations()
            }
            .buttonStyle(BorderedButtonStyle(tint: .blue))
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func stationRow(for station: RadioStation) -> some View {
        NavigationLink(destination: PlayerView(audioPlayer: audioPlayer, station: station, favoritesStore: favoritesStore)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(station.name)
                        .font(.headline)
                    Text(station.countrycode)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if favoritesStore.isFavorite(station) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .onTapGesture {
            audioPlayer.play(urlString: station.url_resolved)
        }
    }

    func loadStations() {
        radioService.fetchStations(countryCode: searchText) { result in
            switch result {
            case .success(let fetchedStations):
                self.stations = fetchedStations.map { station in
                    var mutableStation = station
                    if favoritesStore.isFavorite(station) {
                        mutableStation.isFavorite = true
                    }
                    return mutableStation
                }
            case .failure(let error):
                print("🔴 FAILED TO FETCH STATIONS: \(error.localizedDescription)")
            }
        }
    }
}
