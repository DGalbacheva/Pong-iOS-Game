//
//  PongViewController+GestureHandling.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import UIKit

// NOTE: In this extension we configure the logic for processing gestures
extension PongViewController {

    // MARK: - Pan Gesture Handling

    /// This feature configures how the gesture of moving a finger across the screen is processed
    func enabledPanGestureHandling() {
        // NOTE: Create a gesture handler object
        let panGestureRecognizer = UIPanGestureRecognizer()

        // NOTE: Adding a Gesture Handler to the Screen View
        view.addGestureRecognizer(panGestureRecognizer)

        // NOTE: We indicate to the handler which function to call when processing a gesture
        panGestureRecognizer.addTarget(self, action: #selector(self.handlePanGesture(_:)))

        // NOTE: Saving the gesture handler object to a class variable
        self.panGestureRecognizer = panGestureRecognizer
    }

    /// This is a gesture processing function.
    /// It is called every time the user moves or touches the screen.
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        // NOTE: We look at the state of the gesture handler
        switch recognizer.state {
        case .began:
            // NOTE: The gesture has begun to be recognized, we remember the current position of the platform
            // This is the state when the user has just touched the screen
            lastUserPaddleOriginLocation = userPaddleView.frame.origin.x

        case .changed:
            // NOTE: There has been a touch change,
            // calculate the finger offset and update the platform position
            let translation: CGPoint = recognizer.translation(in: view)
            let translatedOriginX: CGFloat = lastUserPaddleOriginLocation + translation.x

            let platformWidthRatio = userPaddleView.frame.width / view.bounds.width
            let minX: CGFloat = 0
            let maxX: CGFloat = view.bounds.width * (1 - platformWidthRatio)
            userPaddleView.frame.origin.x = min(max(translatedOriginX, minX), maxX)
            dynamicAnimator?.updateItem(usingCurrentState: userPaddleView)

        default:
            // NOTE: In any other condition we do nothing
            break
        }
    }
}
