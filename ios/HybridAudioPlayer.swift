import Foundation
import AVFoundation
import NitroModules

class HybridAudioPlayer: HybridAudioPlayerSpec {
    // MARK: - Registry (Cực kỳ quan trọng)
    // Lưu trữ các instance để Native Video View có thể truy vấn thông qua identifier
    static var registry: [String: HybridAudioPlayer] = [:]
    
    // Identifier duy nhất cho mỗi instance
    public let identifier: String = UUID().uuidString
    
    // Đổi thành public để Native View có thể truy cập AVPlayer
    public var player: AVPlayer?

    // MARK: - Init & Deinit
    init() {
        // Đăng ký instance này vào bộ nhớ tạm
        Self.registry[identifier] = self
    }

    // MARK: - Properties
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }

    var volume: Double {
        get { return Double(player?.volume ?? 1.0) }
        set { player?.volume = Float(newValue) }
    }
    
    var playbackRate: Double {
        get { return Double(player?.rate ?? 1.0) }
        set { player?.rate = Float(newValue) }
    }

    var duration: Double {
        let seconds = player?.currentItem?.duration.seconds ?? 0
        return seconds.isNaN ? 0 : seconds
    }

    var currentTime: Double {
        let seconds = player?.currentTime().seconds ?? 0
        return seconds.isNaN ? 0 : seconds
    }

    // MARK: - Core Methods

    func load(url: String) throws {
        guard let urlObj = URL(string: url) else {
            return
        }
        
        let playerItem = AVPlayerItem(url: urlObj)
        
        if player == nil {
            // Cấu hình Audio Session để có thể phát nhạc nền/chế độ im lặng
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default)
            try? session.setActive(true)
            
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
    
    func release() throws {
        // 1. Dừng phát
        player?.pause()
        
        // 2. Xóa khỏi Registry để tránh Memory Leak
        Self.registry.removeValue(forKey: identifier)
        
        // 3. Giải phóng tài nguyên
        player = nil
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