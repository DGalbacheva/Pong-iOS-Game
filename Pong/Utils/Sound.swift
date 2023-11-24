//
//  Sound.swift
//  Pong
//
//  Created by Timofey on 18.05.2022.
//

import Foundation
import AVFoundation

enum HitSound {

    case low
    case mid
    case high

    // MARK: - Internal Properties
    
    var fileName: String {
        switch self {
        case .low:
            return "hit-sound-low"

        case .mid:
            return "hit-sound-mid"

        case .high:
            return "hit-sound-high"
        }
    }

    var fileURL: URL? {
        Bundle.main.url(forResource: self.fileName, withExtension: "wav")
    }
}
