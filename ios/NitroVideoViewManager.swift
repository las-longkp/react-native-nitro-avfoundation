import Foundation

@objc(NitroVideoViewManager)
class NitroVideoViewManager: RCTViewManager {
    override func view() -> UIView! {
        return NitroVideoView()
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}