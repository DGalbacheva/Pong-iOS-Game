//
//  PongViewController+UIKitDynamics.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import UIKit

extension PongViewController {
    
    // MARK: - UIKitDynamics

    /// This function adjusts the dynamics of interaction between elements
    func enableDynamics() {
        // NOTE: We give the ball, the player's platform and the opponent's platform a special tag for identification
        ballView.tag = Constants.ballTag
        userPaddleView.tag = Constants.userPaddleTag
        enemyPaddleView.tag = Constants.enemyPaddleTag

        let dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        self.dynamicAnimator = dynamicAnimator

        let collisionBehavior = UICollisionBehavior(items: [ballView, userPaddleView, enemyPaddleView])
        collisionBehavior.collisionDelegate = self
        collisionBehavior.collisionMode = .everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        self.collisionBehavior = collisionBehavior
        dynamicAnimator.addBehavior(collisionBehavior)

        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ballView])
        ballDynamicBehavior.allowsRotation = false
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.friction = 0.0
        ballDynamicBehavior.resistance = 0.0
        self.ballDynamicBehavior = ballDynamicBehavior
        dynamicAnimator.addBehavior(ballDynamicBehavior)

        let userPaddleDynamicBehavior = UIDynamicItemBehavior(items: [userPaddleView])
        userPaddleDynamicBehavior.allowsRotation = false
        userPaddleDynamicBehavior.density = 100000
        self.userPaddleDynamicBehavior = userPaddleDynamicBehavior
        dynamicAnimator.addBehavior(userPaddleDynamicBehavior)

        let enemyPaddleDynamicBehavior = UIDynamicItemBehavior(items: [enemyPaddleView])
        enemyPaddleDynamicBehavior.allowsRotation = false
        enemyPaddleDynamicBehavior.density = 100000
        self.enemyPaddleDynamicBehavior = enemyPaddleDynamicBehavior
        dynamicAnimator.addBehavior(enemyPaddleDynamicBehavior)

        let attachmentBehavior = UIAttachmentBehavior.slidingAttachment(
            with: enemyPaddleView,
            attachmentAnchor: .zero,
            axisOfTranslation: CGVector(dx: 1.0, dy: 0.0)
        )
        dynamicAnimator.addBehavior(attachmentBehavior)
    }
}

// NOTE: This extension defines collision handling functions in element dynamics
extension PongViewController: UICollisionBehaviorDelegate {

    // MARK: - UICollisionBehaviorDelegate

    /// This function handles object collisions
    func collisionBehavior(
        _ behavior: UICollisionBehavior,
        beganContactFor item1: UIDynamicItem,
        with item2: UIDynamicItem,
        at p: CGPoint
    ) {
        /// We are trying to determine whether the colliding objects are display elements
        guard
            let view1 = item1 as? UIView,
            let view2 = item2 as? UIView
        else { return }

        /// Getting the names of colliding elements by tag
        let view1Name: String = getNameFromViewTag(view1)
        let view2Name: String = getNameFromViewTag(view2)

        /// Printing the names of colliding elements
        print("\(view1Name) has hit \(view2Name)")

        if let ballDynamicBehavior = self.ballDynamicBehavior {
            ballDynamicBehavior.addLinearVelocity(
                ballDynamicBehavior.linearVelocity(for: self.ballView).multiplied(by: Constants.ballAccelerationFactor),
                for: self.ballView
            )
        }

        if view1.tag == Constants.ballTag || view2.tag == Constants.ballTag {
            animateBallHit(at: p)
            playHitSound(.mid)
            lightImpactFeedbackGenerator.impactOccurred()
        }
    }

    /// This function handles the collision of an object and a frame
    func collisionBehavior(
        _ behavior: UICollisionBehavior,
        beganContactFor item: UIDynamicItem,
        withBoundaryIdentifier identifier: NSCopying?,
        at p: CGPoint
    ) {
        // NOTE: We are trying to determine by tag whether the collision object is a ball
        guard
            identifier == nil,
            let itemView = item as? UIView,
            itemView.tag == Constants.ballTag
        else { return }

        animateBallHit(at: p)

        var shouldResetBall: Bool = false
        if abs(p.y) <= Constants.contactThreshold {
            // NOTE: If the collision location is close to the upper limit,
            // means the ball hit the top edge of the screen
            //
            // Increase the player's score
            userScore += 1
            shouldResetBall = true
            print("Ball has hit enemy side. User score is now: \(userScore)")
        } else if abs(p.y - view.bounds.height) <= Constants.contactThreshold {
            // NOTE: If the collision location is close to the lower limit,
            // means the ball hit the bottom edge of the screen
            //
            // Increase your opponent's score
            enemyScore += 1
            shouldResetBall = true
            print("Ball has hit user side. Enemy score is now: \(enemyScore)")
        }

        if shouldResetBall {
            resetBallWithAnimation()
            playHitSound(.high)
            rigidImpactFeedbackGenerator.impactOccurred()
        } else {
            playHitSound(.low)
            softImpactFeedbackGenerator.impactOccurred()
        }
    }

    // MARK: - Utils

    /// This helper function returns the name of an element, identified by its "tag"
    private func getNameFromViewTag(_ view: UIView) -> String {
        switch view.tag {
        case Constants.ballTag:
            return "Ball"

        case Constants.userPaddleTag:
            return "User Paddle"

        case Constants.enemyPaddleTag:
            return "Enemy Paddle"

        default:
            return "?"
        }
    }
}

// NOTE: This extension defines functions for ball drop
extension PongViewController {

    // MARK: - Reset Ball

    /// This function stops the movement of the ball and resets the ball its position to the middle of the screen
    private func resetBallWithAnimation() {
        // NOTE: adjusting the movement of the ball
        stopBallMovement()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // NOTE: after 1 second we reset the position of the ball and animate its appearance
            self?.resetBallViewPositionAndAnimateBallAppear()
        }
    }

    /// This function stops the ball from moving
    private func stopBallMovement() {
        if let ballPushBehavior = self.ballPushBehavior {
            self.ballPushBehavior = nil
            ballPushBehavior.active = false
            dynamicAnimator?.removeBehavior(ballPushBehavior)
        }

        if let ballDynamicBehavior = self.ballDynamicBehavior {
            ballDynamicBehavior.addLinearVelocity(
                ballDynamicBehavior.linearVelocity(for: self.ballView).inverted(),
                for: self.ballView
            )
        }

        dynamicAnimator?.updateItem(usingCurrentState: self.ballView)
    }

    /// This function resets the ball's position and animates its appearance
    private func resetBallViewPositionAndAnimateBallAppear() {
        // NOTE: reset the ball position
        resetBallViewPosition()
        dynamicAnimator?.updateItem(usingCurrentState: self.ballView)

        // NOTE: set the transparency and size of the ball
        ballView.alpha = 0.0
        ballView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                // Set the transparency and size of the ball returning them to normal
                self.ballView.alpha = 1.0
                self.ballView.transform = .identity
            },
            completion: { [weak self] _ in
                /// At the end of the animation, we enable processing of the next click to launch the ball
                self?.hasLaunchedBall = false
            }
        )
    }

    /// This function resets the ball position to the center of the screen
    private func resetBallViewPosition() {
        // NOTE: reset any transformations of the ball
        ballView.transform = .identity

        // NOTE: Resetting the ball position
        let ballSize: CGSize = ballView.frame.size
        ballView.frame = CGRect(
            origin: CGPoint(
                x: (view.bounds.width - ballSize.width) / 2,
                y: (view.bounds.height - ballSize.height) / 2
            ),
            size: ballSize
        )
    }
}
