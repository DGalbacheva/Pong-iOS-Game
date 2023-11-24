//
//  Constants.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import Foundation
import UIKit

/// This is a list of constants used in this file
enum Constants {

    static let userPaddleTag: Int = 1
    static let enemyPaddleTag: Int = 2
    static let ballTag: Int = 3

    static let enemyPaddleMaxSpeed: CGFloat = 24
    static let ballAccelerationFactor: CGFloat = 0.04

    static let contactThreshold: CGFloat = 5.0

    static let ballHitViewSize: CGSize = CGSize(width: 10, height: 10)
    static let ballHitViewScaleFactor: CGFloat = 10
}
