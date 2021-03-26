//
//  AVURLAssetExtensions.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.2021.
//

import AVFoundation

extension AVURLAsset {
    func exportVideo(presetName: String = AVAssetExportPresetHighestQuality,
                     outputFileType: AVFileType = .mp4,
                     fileExtension: String = "mp4",
                     then completion: @escaping (URL?) -> Void)
    {
        let filename = url.deletingPathExtension().appendingPathExtension(fileExtension).lastPathComponent
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        if let session = AVAssetExportSession(asset: self, presetName: presetName) {
            session.outputURL = outputURL
            session.outputFileType = outputFileType
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: duration)
            session.timeRange = range
            session.shouldOptimizeForNetworkUse = true
            session.exportAsynchronously {
                switch session.status {
                case .completed:
                    completion(outputURL)
                case .cancelled:
                    debugPrint("Video export cancelled.")
                    completion(nil)
                case .failed:
                    let errorMessage = session.error?.localizedDescription ?? "n/a"
                    debugPrint("Video export failed with error: \(errorMessage)")
                    completion(nil)
                default:
                    break
                }
            }
        } else {
            completion(nil)
        }
    }
}
