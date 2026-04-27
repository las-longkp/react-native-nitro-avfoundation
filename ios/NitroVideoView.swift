import UIKit
import AVFoundation

@objc(NitroVideoView)
class NitroVideoView: UIView {
    private let playerLayer = AVPlayerLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        playerLayer.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Đảm bảo video luôn khít với kích thước View từ React Native
        playerLayer.frame = self.bounds
    }

    // React Native sẽ truyền identifier vào đây
    @objc var playerIdentifier: String? {
        didSet {
            guard let id = playerIdentifier else { 
                playerLayer.player = nil
                return 
            }
            
            // Tìm player trong Registry mà bạn đã tạo ở HybridAudioPlayer
            if let hybridInstance = HybridAudioPlayer.registry[id] {
                playerLayer.player = hybridInstance.player
            }
        }
    }
}