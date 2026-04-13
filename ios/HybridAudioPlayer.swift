import Foundation
import AVFoundation
import NitroModules
import UIKit

class HybridAudioPlayer: HybridAudioPlayerSpec {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer? 

    // MARK: - Properties
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }

    var volume: Double {
        get { return Double(player?.volume ?? 1.0) }
        set { player?.volume = Float(newValue) }
    }
    
    // Thêm thuộc tính tốc độ phát
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
            print("NitroAudio: Invalid URL string")
            return
        }
        
        let playerItem = AVPlayerItem(url: urlObj)
        
        if player == nil {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default)
            try? session.setActive(true)
            
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        // Cập nhật player cho layer nếu layer đã tồn tại từ trước (khi chuyển bài)
        if let layer = playerLayer {
            layer.player = player
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
    
    // Giải phóng bộ nhớ khi đóng màn hình Player
    func release() throws {
        DispatchQueue.main.async { [weak self] in
            self?.player?.pause()
            self?.playerLayer?.removeFromSuperlayer()
            self?.playerLayer = nil
            self?.player = nil
        }
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

    // MARK: - Video Rendering

    func render(viewTag: Double) throws {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Tìm view của React Native thông qua tag
            guard let window = UIApplication.shared.windows.first,
                  let targetView = window.viewWithTag(Int(viewTag)) else {
                print("NitroAudio: Không tìm thấy View với tag \(viewTag)")
                return
            }

            if self.playerLayer == nil {
                self.playerLayer = AVPlayerLayer(player: self.player)
            }
            
            // Cập nhật frame của layer theo bounds của view chứa
            self.playerLayer?.frame = targetView.bounds
            self.playerLayer?.videoGravity = .resizeAspect
            
            // Đảm bảo không add trùng layer
            if self.playerLayer?.superlayer != targetView.layer {
                targetView.layer.sublayers?.forEach { if $0 is AVPlayerLayer { $0.removeFromSuperlayer() } }
                targetView.layer.addSublayer(self.playerLayer!)
            }
        }
    }
}