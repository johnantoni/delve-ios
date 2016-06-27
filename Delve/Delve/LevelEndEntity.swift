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

class LevelEndEntity: GKEntity {
  
  var spriteComponent: SpriteComponent!
  
  override init() {
    super.init()
    
    let texture = SKTexture(imageNamed: "Exit")
    spriteComponent = SpriteComponent(entity: self, texture: texture, size: CGSize(width: 32, height: 32))
    addComponent(spriteComponent)
    
    let physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPoint(x: -16, y: -16), size: CGSize(width: 8, height: 8)))
    physicsBody.categoryBitMask = ColliderType.EndLevel.rawValue
    physicsBody.dynamic = true
    spriteComponent.node.physicsBody = physicsBody
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
