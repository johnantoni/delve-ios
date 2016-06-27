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

class EnemyMoveComponentSystem: GKComponentSystem {
  
  func updateWithDeltaTime(seconds: NSTimeInterval, playerPosition: CGPoint) {
    for component in components {
      if let enemyComp = component as? EnemyMoveComponent {
        enemyComp.updateWithDeltaTime(seconds, playerPosition: playerPosition)
      }
    }
  }
}

class EnemyMoveComponent: GKComponent {
  var isAttacking = false

  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.componentForClass(SpriteComponent.self) else { fatalError("A MovementComponent's entity must have a SpriteComponent") }
    return spriteComponent
  }

  var animationComponent: AnimationComponent {
    guard let animationComponent = entity?.componentForClass(AnimationComponent.self) else { fatalError("A MovementComponent's entity must have an AnimationComponent") }
    return animationComponent
  }

  init(entity: GKEntity) {
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func updateWithDeltaTime(seconds: NSTimeInterval, playerPosition: CGPoint) {
    super.updateWithDeltaTime(seconds)
    
    if spriteComponent.node.position.distanceTo(playerPosition) < playerSettings.enemySenseRadius {
      isAttacking = true
    }
    
    if isAttacking {
      //1
      var direction = (playerPosition - spriteComponent.node.position)
      direction.normalize()
      direction = CGPoint(x: direction.x * (CGFloat(seconds) * playerSettings.enemyMoveSpeed), y: direction.y * (CGFloat(seconds) * playerSettings.enemyMoveSpeed))
      //2
      spriteComponent.node.position += direction
      //3
      switch direction.angle {
      case CGFloat(45).degreesToRadians() ..< CGFloat(135).degreesToRadians():
        animationComponent.requestedAnimationState = .Walk_Up
        break
      case CGFloat(-135).degreesToRadians() ..< CGFloat(-45).degreesToRadians():
        animationComponent.requestedAnimationState = .Walk_Down
        break
      case CGFloat(-45).degreesToRadians() ..< CGFloat(45).degreesToRadians():
        animationComponent.requestedAnimationState = .Walk_Right
        break
      default:
        animationComponent.requestedAnimationState = .Walk_Left
        break
      }
    }
  }
}
