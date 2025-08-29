import SwiftUI

struct ContentView: View {
    @State private var stations = [RadioStation]()
    @State private var searchText = ""
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var favoritesStore = FavoritesStore()
    @State private var isLoading = false
    
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
                if isLoading {
                    ProgressView()
                } else {
                    List(filteredStations) { station in
                        stationRow(for: station)
                    }
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
            TextField("Search by name or country", text: $searchText)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var filteredStations: [RadioStation] {
        if searchText.isEmpty {
            return stations
        } else {
            return stations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) || $0.countrycode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @ViewBuilder
    private func stationRow(for station: RadioStation) -> some View {
        // The argument order for PlayerView has been corrected below
        NavigationLink(destination: PlayerView(audioPlayer: audioPlayer, favoritesStore: favoritesStore, station: station)) {
            HStack {
                if let faviconURL = station.favicon, let url = URL(string: faviconURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "radio")
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
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
        isLoading = true
        radioService.fetchAllStations { result in
            isLoading = false
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
