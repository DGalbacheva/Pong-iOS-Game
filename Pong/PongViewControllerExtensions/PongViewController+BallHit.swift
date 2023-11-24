//
//  PongViewController+BallHit.swift
//  Pong
//
//  Created by Timofey on 18.05.2022.
//

import Foundation
import UIKit
import AVFoundation

// NOTE:
extension PongViewController {

    // MARK: - Ball Hit

    func animateBallHit(at point: CGPoint) {
        let ballHitView = UIView()
        ballHitView.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        view.addSubview(ballHitView)
        view.sendSubviewToBack(ballHitView)
        ballHitView.frame = CGRect(
            origin: CGPoint(
                x: point.x - Constants.ballHitViewSize.width / 2,
                y: point.y - Constants.ballHitViewSize.height / 2
            ),
            size: Constants.ballHitViewSize
        )
        ballHitView.layer.cornerRadius = Constants.ballHitViewSize.height / 2
        ballHitView.alpha = 1

        let scale: CGFloat = Constants.ballHitViewScaleFactor * .random(in: 0.5...3)
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                ballHitView.alpha = 0
                ballHitView.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                ballHitView.removeFromSuperview()
            }
        )
    }

    /// This feature plays collision sound
    func playHitSound(_ hitSound: HitSound) {
        guard let hitSoundURL = hitSound.fileURL else {
            print("Failed to get sound url for sound \(hitSound.fileName)")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: hitSoundURL)
                audioPlayer.delegate = self

                self.audioPlayersLock.lock()
                self.audioPlayers.append(audioPlayer)
                self.audioPlayersLock.unlock()

                audioPlayer.volume = Float.random(in: 0.2...1)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }
}

// NOTE: This extension allows you to monitor audio player events
extension PongViewController: AVAudioPlayerDelegate {

    /// This function is called when the player has finished playing audio
    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        audioPlayersLock.lock()
        self.audioPlayers = self.audioPlayers.filter { $0 !== player }
        audioPlayersLock.unlock()
    }
}
