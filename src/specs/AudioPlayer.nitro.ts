import { type HybridObject } from 'react-native-nitro-modules'

export interface AudioPlayer extends HybridObject<{
  ios: 'swift'
  android: 'kotlin'
}> {
  // Điều khiển phát
  load(url: string): void
  play(): void
  pause(): void
  stop(): void
  release(): void // Giải phóng tài nguyên

  // Trạng thái (Readonly)
  readonly isPlaying: boolean
  readonly duration: number
  readonly currentTime: number

  // Cấu hình
  volume: number // 0.0 đến 1.0
  playbackRate: number // Tốc độ phát (mặc định 1.0)

  // Điều hướng thời gian
  seek(seconds: number): void
  skip(seconds: number): void

  // Video Rendering
  /**
   * @param viewTag ID của View lấy từ findNodeHandle
   */
  render(viewTag: number): void
}
