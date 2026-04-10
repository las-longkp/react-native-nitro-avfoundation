// TODO: Export specs that extend HybridObject<...> here
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
}
