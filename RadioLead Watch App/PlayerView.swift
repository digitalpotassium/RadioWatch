import SwiftUI

struct PlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var favoritesStore: FavoritesStore
    var station: RadioStation

    var body: some View {
        VStack(spacing: 20) {
            if let faviconURL = station.favicon, let url = URL(string: faviconURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "radio")
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 10)
            }
            
            Text(station.name)
                .font(.title2)
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
                        .scaleEffect(audioPlayer.isPlaying ? 1.0 : 1.1)
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
                        .scaleEffect(favoritesStore.isFavorite(station) ? 1.2 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .animation(.easeInOut, value: audioPlayer.isPlaying)
        .animation(.bouncy, value: favoritesStore.isFavorite(station))
    }
}
