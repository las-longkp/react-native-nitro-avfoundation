import Foundation
import AVFoundation
import NitroModules

class HybridAudioPlayer: HybridAudioPlayerSpec {
    private var player: AVPlayer?

    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }

    var volume: Double {
        get { return Double(player?.volume ?? 1.0) }
        set { player?.volume = Float(newValue) }
    }

    var duration: Double {
        let seconds = player?.currentItem?.duration.seconds ?? 0
        return seconds.isNaN ? 0 : seconds
    }

    // 4. Lấy thời gian hiện tại
    var currentTime: Double {
        let seconds = player?.currentTime().seconds ?? 0
        return seconds.isNaN ? 0 : seconds
    }

    func load(url: String) throws {
        guard let urlObj = URL(string: url) else {
            print("NitroAudio: Invalid URL string")
            return
        }
        let playerItem = AVPlayerItem(url: urlObj)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
    }

    func play() throws {
        player?.play()
    }

    func pause() throws {
        player?.pause()
    }

    func stop() throws {
        player?.pause()
        player?.seek(to: .zero)
    }

    func seek(seconds: Double) throws {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func skip(seconds: Double) throws {
        let current = player?.currentTime().seconds ?? 0
        let newTime = current + seconds
        let cmTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}