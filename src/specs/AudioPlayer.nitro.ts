import { type HybridObject } from 'react-native-nitro-modules'

export interface AudioPlayer extends HybridObject<{
  ios: 'swift'
  android: 'kotlin'
}> {
  // --- Điều khiển phát ---
  load(url: string): void
  play(): void
  pause(): void
  stop(): void

  /**
   * Giải phóng hoàn toàn tài nguyên player và gỡ bỏ khỏi Registry ở Native.
   * Cần gọi khi component unmount.
   */
  release(): void

  // --- Trạng thái (Readonly) ---
  readonly isPlaying: boolean
  readonly duration: number
  readonly currentTime: number

  // --- Cấu hình ---
  /**
   * Âm lượng từ 0.0 đến 1.0
   */
  volume: number

  /**
   * Tốc độ phát (mặc định 1.0)
   */
  playbackRate: number

  // --- Điều hướng thời gian ---
  seek(seconds: number): void
  skip(seconds: number): void

  // --- Video Rendering (New Architecture) ---
  /**
   * Identifier duy nhất của instance player này.
   * Dùng để truyền vào prop của Native Video View giúp kết nối mà không cần viewTag.
   */
  readonly identifier: string
}
