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

class ProjMoveComponent: GKComponent {
  //1
  var node = EntityNode()
  var nodeDirection = CGPointZero
  //2
  let projSpeed = CGFloat(235.5)
  let projRotationSpeed = CGFloat(15.5)
  //3
  init(entity: GKEntity, origin:CGPoint, direction:CGPoint) {
    
    node.entity = entity
    node.position = origin
    nodeDirection = direction
    //4
    nodeDirection.normalize()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func updateWithDeltaTime(seconds: NSTimeInterval) {
    super.updateWithDeltaTime(seconds)
    //5
    node.zRotation = node.zRotation + (CGFloat(seconds) * projRotationSpeed)
    //6
    node.position = CGPoint(x: (node.position.x + (nodeDirection.x * (projSpeed * CGFloat(seconds)))), y: (node.position.y + (nodeDirection.y * (projSpeed * CGFloat(seconds)))))
  }
}
