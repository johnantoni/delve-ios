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
class PlayerEntity: GKEntity {
  
  var spriteComponent: SpriteComponent!
  var animationComponent: AnimationComponent!
  var moveComponent: PlayerMoveComponent!
  
  override init() {
    super.init()
    let texture = SKTexture(imageNamed: "PlayerIdle_12_00.png")
    spriteComponent = SpriteComponent(entity: self, texture: texture,
      size: CGSize(width: 25, height: 30))
    addComponent(spriteComponent)
    animationComponent = AnimationComponent(node: spriteComponent.node,
      textureSize: CGSizeMake(25,30), animations: loadAnimations())
    addComponent(animationComponent)
    moveComponent = PlayerMoveComponent()
    addComponent(moveComponent)
    
    let physicsBody = SKPhysicsBody(circleOfRadius: 15)
    physicsBody.dynamic = true
    physicsBody.allowsRotation = false
    physicsBody.categoryBitMask = ColliderType.Player.rawValue
    physicsBody.collisionBitMask = ColliderType.Wall.rawValue
    physicsBody.contactTestBitMask = ColliderType.Enemy.rawValue |
      ColliderType.Food.rawValue | ColliderType.EndLevel.rawValue
    spriteComponent.node.physicsBody = physicsBody
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func loadAnimations() -> [AnimationState: Animation] {
    let textureAtlas = SKTextureAtlas(named: "player")
    var animations = [AnimationState: Animation]()
    animations[.Walk_Down] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Walk_Down.rawValue,
      forAnimationState: .Walk_Down)
    animations[.Walk_Up] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Walk_Up.rawValue,
      forAnimationState: .Walk_Up)
    animations[.Walk_Left] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Walk_Left.rawValue,
      forAnimationState: .Walk_Left)
    animations[.Walk_Right] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Walk_Right.rawValue,
      forAnimationState: .Walk_Right)
    animations[.Idle_Down] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Idle_Down.rawValue,
      forAnimationState: .Idle_Down)
    animations[.Idle_Up] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Idle_Up.rawValue,
      forAnimationState: .Idle_Up)
    animations[.Idle_Left] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Idle_Left.rawValue,
      forAnimationState: .Idle_Left)
    animations[.Idle_Right] = AnimationComponent.animationFromAtlas(
      textureAtlas,
      withImageIdentifier: AnimationState.Idle_Right.rawValue,
      forAnimationState: .Idle_Right)
    return animations
  }
  
}
