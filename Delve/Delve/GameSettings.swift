/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import SpriteKit
//1
enum AnimationState: String {
  case Idle_Down = "Idle_12"
  case Idle_Up = "Idle_4"
  case Idle_Left = "Idle_8"
  case Idle_Right = "Idle_0"
  case Walk_Down = "Walk_12"
  case Walk_Up = "Walk_4"
  case Walk_Left = "Walk_8"
  case Walk_Right = "Walk_0"
  case Die_Down = "Die_0"
}
//2
enum LastDirection {
  case Left
  case Right
  case Up
  case Down
}

enum ColliderType:UInt32 {
  case Player        = 0
  case Enemy         = 0b1
  case Wall          = 0b10
  case Projectile    = 0b100
  case Food          = 0b1000
  case EndLevel      = 0b10000
  case None          = 0b100000
}

enum tapAction {
  case startGame
  case attack
  case dismissPause
  case nextLevel
  case doNothing
}

var gameDifficultyModifier = 1
var gameLoopPaused = true

struct playerSettings {
  //Player
  static let movementSpeed: CGFloat = 320.0
  
  //Enemy
  static let enemyMoveSpeed: CGFloat = 70.0
  static let enemySenseRadius: CGFloat = 300.0
  static let enemyDamagePerHit: CGFloat = 0.55
}