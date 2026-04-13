import Foundation
import AVFoundation
import MediaPlayer
import NitroModules

class HybridAudioPlayer: HybridAudioPlayerSpec {
    private var player: AVPlayer?
    private var tracks: [Track] = []
    private var currentIndex: Int = 0
    private var timeObserver: Any?

    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }

    // MARK: - Setup
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
    }

    // MARK: - Playlist Logic
    func setPlaylist(tracks: [Track], index: Double) throws {
        self.tracks = tracks
        self.currentIndex = Int(index)
        try loadCurrentTrack()
    }

    private func loadCurrentTrack() throws {
        guard currentIndex >= 0 && currentIndex < tracks.count else { return }
        let track = tracks[currentIndex]

        // Nếu trackUrl rỗng, chúng ta dừng tại đây để JS xử lý lấy link
        guard let urlString = track.trackUrl, let url = URL(string: urlString) else {
            print("NitroAudio: URL is empty for track \(track.title)")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        
        // Lắng nghe sự kiện kết thúc bài hát
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            setupTimeObserver()
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }

        player?.play()
        updateNowPlayingInfo()
    }

    @objc private func playerItemDidReachEnd() {
        try? next()
    }

    func updateTrackUrl(index: Double, url: String) throws {
        let idx = Int(index)
        if idx >= 0 && idx < tracks.count {
            tracks[idx].trackUrl = url
            // Nếu bài được cập nhật là bài hiện tại và player đang không có nhạc, thì load luôn
            if idx == currentIndex && (player?.currentItem == nil || isPlaying == false) {
                try loadCurrentTrack()
            }
        }
    }

    // MARK: - Remote Control (Màn hình khóa)
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            try? self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            try? self?.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            try? self?.next()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            try? self?.previous()
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard currentIndex < tracks.count else { return }
        let track = tracks[currentIndex]
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        
        // Tải ảnh thumbnail (Async)
        if let url = URL(string: track.trackThumbnailUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }.resume()
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupTimeObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
    }

    private func updatePlaybackProgress() {
        // Cập nhật thời gian trên màn hình khóa định kỳ
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Basic Methods
    func next() throws {
        if currentIndex < tracks.count - 1 {
            currentIndex += 1
            try loadCurrentTrack()
        }
    }

    func previous() throws {
        if currentIndex > 0 {
            currentIndex -= 1
            try loadCurrentTrack()
        }
    }

    func play() throws { 
        player?.play()
        updateNowPlayingInfo()
    }
    
    func pause() throws { 
        player?.pause()
        updateNowPlayingInfo()
    }
    
    func stop() throws {
        player?.pause()
        player?.seek(to: .zero)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func seek(seconds: Double) throws {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    var isPlaying: Bool { player?.rate != 0 && player?.error == nil }
    var duration: Double { player?.currentItem?.duration.seconds ?? 0 }
    var currentTime: Double { player?.currentTime().seconds ?? 0 }
    var currentTrackId: String { currentIndex < tracks.count ? tracks[currentIndex].id : "" }
}