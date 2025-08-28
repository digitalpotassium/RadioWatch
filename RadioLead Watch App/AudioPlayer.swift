//
//  AudioPlayer.swift
//  RadioLead Watch App
//
//  Created by Evan Mass on 8/28/25.
//

import Foundation
import AVFoundation

// Making this an 'ObservableObject' allows our SwiftUI views to watch it for changes.
class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    
    // We'll use the '@Published' property wrapper to notify any listening views
    // when the playback state changes (e.g., from paused to playing).
    @Published var isPlaying = false
    
    // This function takes a URL string, creates a player item, and starts playback.
    func play(urlString: String) {
        // Ensure the URL is valid.
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        
        // Stop any currently playing audio before starting a new stream.
        if let player = player {
            player.pause()
        }
        
        // Create a new AVPlayer instance with the station's URL.
        player = AVPlayer(url: url)
        
        // Start playback.
        player?.play()
        
        // Update our published property.
        isPlaying = true
    }
    
    // This function pauses the audio.
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    // This function toggles between play and pause.
    func togglePlayPause() {
        guard player != nil else { return }
        
        if isPlaying {
            pause()
        } else {
            // We need a proper play function here that can resume.
            // For now, let's just show the concept.
            player?.play()
            isPlaying = true
        }
    }
}
