import { type HybridObject } from 'react-native-nitro-modules'

export interface Track {
  id: string
  trackId: string
  title: string
  artist: string
  trackThumbnailUrl: string
  trackUrl: string
  type: number // 0: Online, 1: Offline
}

export interface AudioPlayer extends HybridObject<{
  ios: 'swift'
  android: 'kotlin'
}> {
  setPlaylist(tracks: Track[], index: number): void
  next(): void
  previous(): void

  play(): void
  pause(): void
  stop(): void
  seek(seconds: number): void

  readonly isPlaying: boolean
  readonly duration: number
  readonly currentTime: number
  readonly currentTrackId: string

  updateTrackUrl(index: number, url: string): void
}
