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
import UIKit
import SpriteKit
import GameplayKit

class EnemyEntity: GKEntity {
  
  var spriteComponent: SpriteComponent!
  var animationComponent: AnimationComponent!
  var enemyHealth:CGFloat = 1.0
  
  override init() {
    super.init()
    
    let atlas = SKTextureAtlas(named: "enemy")
    let texture = atlas.textureNamed("EnemyWalk_0_00.png")
    let textureSize = CGSize(width: 40, height: 42)
    spriteComponent = SpriteComponent(entity: self, texture: texture, size: textureSize)
    addComponent(spriteComponent)
    let moveComponent = EnemyMoveComponent(entity: self)
    addComponent(moveComponent)
    animationComponent = AnimationComponent(node: spriteComponent.node, textureSize: textureSize, animations: loadAnimations())
    addComponent(animationComponent)
    
    let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 32, height: 32))
    
    physicsBody.categoryBitMask = ColliderType.Enemy.rawValue
    physicsBody.collisionBitMask = ColliderType.Wall.rawValue
    physicsBody.contactTestBitMask = ColliderType.Player.rawValue
    physicsBody.allowsRotation = false
    
    spriteComponent.node.physicsBody = physicsBody
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func loadAnimations() -> [AnimationState: Animation] {
    let textureAtlas = SKTextureAtlas(named: "enemy")
    var animations = [AnimationState: Animation]()
    //1
    animations[.Walk_Down] = AnimationComponent.animationFromAtlas(textureAtlas,
      withImageIdentifier: AnimationState.Walk_Down.rawValue,
      forAnimationState: .Walk_Down)
    animations[.Walk_Up] = AnimationComponent.animationFromAtlas(textureAtlas,
      withImageIdentifier: AnimationState.Walk_Up.rawValue,
      forAnimationState: .Walk_Up)
    animations[.Walk_Left] = AnimationComponent.animationFromAtlas(textureAtlas,
      withImageIdentifier: AnimationState.Walk_Left.rawValue,
      forAnimationState: .Walk_Left)
    animations[.Walk_Right] = AnimationComponent.animationFromAtlas(textureAtlas,
      withImageIdentifier: AnimationState.Walk_Right.rawValue,
      forAnimationState: .Walk_Right)
    //2
    animations[.Die_Down] = AnimationComponent.animationFromAtlas(textureAtlas,
      withImageIdentifier: AnimationState.Die_Down.rawValue,
      forAnimationState: .Die_Down,repeatTexturesForever: false)
    
    return animations
  }
  
}
