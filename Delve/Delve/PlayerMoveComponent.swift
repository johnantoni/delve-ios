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

import SpriteKit
import GameplayKit

class PlayerMoveComponent: GKComponent {
  //1
  var movement = CGPointZero
  //2
  var lastDirection = LastDirection.Down
  //3
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.componentForClass(SpriteComponent.self) else { fatalError("A MovementComponent's entity must have a spriteComponent") }
    return spriteComponent
  }
  //4
  var animationComponent: AnimationComponent {
    guard let animationComponent = entity?.componentForClass(AnimationComponent.self) else { fatalError("A MovementComponent's entity must have an animationComponent") }
    return animationComponent
  }
  
  override func updateWithDeltaTime(seconds: NSTimeInterval) {
    super.updateWithDeltaTime(seconds)
    
    //Update player position
    let xMovement = ((movement.x * CGFloat(seconds)) * playerSettings.movementSpeed)
    let yMovement = ((movement.y * CGFloat(seconds)) * playerSettings.movementSpeed)
    spriteComponent.node.position = CGPoint(x: spriteComponent.node.position.x + xMovement,y: spriteComponent.node.position.y + yMovement)
    
    switch movement.angle {
    case 0:
      //Left empty on purpose to break switch if there is no angle
      break
    case CGFloat(45).degreesToRadians() ..<
      CGFloat(135).degreesToRadians():
      animationComponent.requestedAnimationState = .Walk_Up
      lastDirection = .Up
      break
    case CGFloat(-135).degreesToRadians() ..<
      CGFloat(-45).degreesToRadians():
      animationComponent.requestedAnimationState = .Walk_Down
      lastDirection = .Down
      break
    case CGFloat(-45).degreesToRadians() ..<
      CGFloat(45).degreesToRadians():
      animationComponent.requestedAnimationState = .Walk_Right
      lastDirection = .Right
      break
    case CGFloat(-180).degreesToRadians() ..<
      CGFloat(-135).degreesToRadians():
      animationComponent.requestedAnimationState = .Walk_Left
      lastDirection = .Left
      break
    case CGFloat(135).degreesToRadians() ..<
      CGFloat(180).degreesToRadians():
      animationComponent.requestedAnimationState = .Walk_Left
      lastDirection = .Left
      break
    default:
      break
    }
    
    if xMovement == 0 && yMovement == 0 {
      switch lastDirection {
      case .Up:
        animationComponent.requestedAnimationState = .Idle_Up
        break
      case .Down:
        animationComponent.requestedAnimationState = .Idle_Down
        break
      case .Right:
        animationComponent.requestedAnimationState = .Idle_Right
        break
      case .Left:
        animationComponent.requestedAnimationState = .Idle_Left
        break
      } }
    movement = CGPointZero
  }
  
}