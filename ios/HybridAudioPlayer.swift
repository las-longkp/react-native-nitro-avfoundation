import Foundation
import AVFoundation
import NitroModules

class HybridAudioPlayer: HybridAudioPlayerSpec {
    private var player: AVPlayer?

    // Kiểm tra xem nhạc có đang phát không
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }

    // Quản lý âm lượng
    var volume: Double {
        get { Double(player?.volume ?? 0) }
        set { player?.volume = Float(newValue) }
    }

    func load(url: String) throws {
        guard let urlObj = URL(string: url) else { return }
        let playerItem = AVPlayerItem(url: urlObj)
        player = AVPlayer(playerItem: playerItem)
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
}