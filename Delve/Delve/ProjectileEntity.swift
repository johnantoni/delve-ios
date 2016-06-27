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

class ProjectileEntity: GKEntity {

  var projComponent: ProjMoveComponent!

  init(withNode node: SKSpriteNode, origin: CGPoint, direction: CGPoint) {
    super.init()
    
    projComponent = ProjMoveComponent(entity: self, origin:origin, direction:direction)
    addComponent(projComponent)
    
    let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 10, height: 20))
    
    node.position = CGPointZero
    
    physicsBody.categoryBitMask = ColliderType.Projectile.rawValue
    physicsBody.collisionBitMask = ColliderType.None.rawValue
    physicsBody.contactTestBitMask = ColliderType.Wall.rawValue | ColliderType.Enemy.rawValue
    
    physicsBody.dynamic = true
    
    projComponent.node.physicsBody = physicsBody
    projComponent.node.name = "projectile"
    projComponent.node.addChild(node)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
