import { type HybridObject } from 'react-native-nitro-modules'
export interface AudioPlayer extends HybridObject<{
  ios: 'swift'
  android: 'kotlin'
}> {
  load(url: string): void
  play(): void
  pause(): void
  stop(): void
  readonly isPlaying: boolean
  volume: number
  readonly duration: number
  readonly currentTime: number
  seek(seconds: number): void
  skip(seconds: number): void
}
