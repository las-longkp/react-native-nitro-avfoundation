import { type HybridObject } from 'react-native-nitro-modules'

export interface AudioPlayer extends HybridObject<{
  ios: 'swift'
  android: 'kotlin'
}> {
  load(url: string): void
  play(): void
  pause(): void
  stop(): void
  release(): void

  readonly isPlaying: boolean
  readonly duration: number
  readonly currentTime: number

  volume: number
  playbackRate: number

  seek(seconds: number): void
  skip(seconds: number): void

  /**
   * @param viewTag
   */
  render(viewTag: number): void
  unrender(): void
}
