import SwiftUI

struct PlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var favoritesStore: FavoritesStore
    var station: RadioStation

    init(audioPlayer: AudioPlayer, station: RadioStation, favoritesStore: FavoritesStore) {
        self.audioPlayer = audioPlayer
        self.station = station
        self.favoritesStore = favoritesStore
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(station.name)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(station.countrycode)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 40) {
                Button(action: {
                    audioPlayer.togglePlayPause()
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    if favoritesStore.isFavorite(station) {
                        favoritesStore.removeFavorite(station)
                    } else {
                        favoritesStore.addFavorite(station)
                    }
                }) {
                    Image(systemName: favoritesStore.isFavorite(station) ? "star.fill" : "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(favoritesStore.isFavorite(station) ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}
