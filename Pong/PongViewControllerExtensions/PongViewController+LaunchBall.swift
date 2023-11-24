//
//  PongViewController+LaunchBall.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import Foundation
import UIKit

// NOTE: This extension defines the function used to launch the ball
extension PongViewController {

    /// Ball launch function. Generates a random ball speed vector and launches the ball along this vector
    func launchBall() {
        let ballPusher = UIPushBehavior(items: [ballView], mode: .instantaneous)
        self.ballPushBehavior = ballPusher

        ballPusher.pushDirection = makeRandomVelocityVector()
        ballPusher.active = true

        self.dynamicAnimator?.addBehavior(ballPusher)
    }

    /// Function for generating a ball launch speed vector with an almost random direction
    private func makeRandomVelocityVector() -> CGVector {
        // NOTE: Generating a random number from 0 to 1
        let randomSeed = Double(arc4random_uniform(1000)) / 1000

        // NOTE: Create a random angle approximately between Pi/6 (30 degrees) and Pi/3 (60 degrees)
        let angle = Double.pi * (0.16 + 0.16 * randomSeed)

        // NOTE: We take 1.5 screen pixels as the amplitude (force) of launching the ball
        let amplitude = 1.5 / UIScreen.main.scale

        // NOTE: decomposition of the velocity vector on the X and Y axes
        let x = amplitude * cos(angle)
        let y = amplitude * sin(angle)

        // NOTE: using the generated angle, return it in one of 4 variations
        switch arc4random() % 4 {
        case 0:
            // right, down
            return CGVector(dx: x, dy: y)

        case 1:
            // right, up
            return CGVector(dx: x, dy: -y)

        case 2:
            // left, down
            return CGVector(dx: -x, dy: y)

        default:
            // left, up
            return CGVector(dx: -x, dy: -y)
        }
    }
}
