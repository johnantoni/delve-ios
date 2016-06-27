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
import GameplayKit
import SpriteKit
//1
class GameSceneState: GKState {
  unowned let levelScene: GameScene
  init(scene: GameScene) {
    self.levelScene = scene
  }
}
//2
class GameSceneInitialState: GameSceneState {
  override func didEnterWithPreviousState(previousState: GKState?) {
    SKTAudio.sharedInstance().playBackgroundMusic("delve_bg.mp3")
    SKTAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.4
    
    levelScene.setupLevel()
    
    levelScene.health = 1000
    
    // One of many things you could do
    switch gameDifficultyModifier {
    case 2...8:
      levelScene.health = (1000 - (100 * gameDifficultyModifier))
      break
    case 8...100000:
      levelScene.health = 200
      break
    default:
      levelScene.health = 1000
      break
    }
    
    #if os(iOS)
      levelScene.motionManager.startAccelerometerUpdates()
    #endif
    //Scene Activity
    levelScene.paused = true
    gameLoopPaused = true
    levelScene.tapState = .startGame
    
    let healthBackground = SKSpriteNode(imageNamed: "HealthUI")
    healthBackground.zPosition = 999
    healthBackground.position = CGPoint(x: 0,
      y: (levelScene.scene?.size.height)!*0.455)
    healthBackground.alpha = 0.4
    levelScene.guiLayer.addChild(healthBackground)
    
    let healthLabel = SKLabelNode(fontNamed: "Avenir-Black")
    healthLabel.position = CGPoint(
      x: (levelScene.scene?.size.width)!*0.01,
      y: (levelScene.scene?.size.height)!*0.449)
    healthLabel.name = "healthLabel"
    healthLabel.zPosition = 1000
    levelScene.guiLayer.addChild(healthLabel)
    
    let announce = SKSpriteNode(imageNamed: "TapToStart")
    announce.size = CGSize(width: 2046, height: 116)
    announce.xScale = 0.5
    announce.yScale = 0.5
    announce.position = CGPointZero
    announce.zPosition = 120
    announce.alpha = 0.6
    levelScene.overlayLayer.addChild(announce)
    
    let announcelevel = SKLabelNode(fontNamed: "Avenir-Black")
    announcelevel.position = CGPoint(x: 0, y: -100)
    announcelevel.color = SKColor.grayColor()
    announcelevel.fontSize = 40
    announcelevel.zPosition = 120
    announcelevel.text = "Level \(gameDifficultyModifier)"
    levelScene.overlayLayer.addChild(announcelevel)
  }
  override func willExitWithNextState(nextState: GKState) {
    for node in levelScene.overlayLayer.children {
      node.removeFromParent()
    }
  }
  
}
class GameSceneActiveState: GameSceneState {
  override func didEnterWithPreviousState(previousState: GKState?) {
    levelScene.paused = false
    gameLoopPaused = false
    levelScene.tapState = .attack
  }
}

class GameScenePausedState: GameSceneState {
  override func didEnterWithPreviousState(previousState: GKState?) {
    levelScene.paused = true
    gameLoopPaused = true
    levelScene.tapState = .dismissPause
  }
}

class GameSceneLimboState: GameSceneState {
  override func didEnterWithPreviousState(previousState: GKState?) {
    levelScene.tapState = .doNothing
    levelScene.health = levelScene.health + 30
  }
}
class GameSceneWinState: GameSceneState {
  override func didEnterWithPreviousState(previousState: GKState?) {
    levelScene.paused = true
    gameLoopPaused = true
    
    levelScene.tapState = .nextLevel
    
    let announce = SKLabelNode(fontNamed: "Avenir-Black")
    announce.position = CGPointZero
    announce.fontSize = 80
    announce.zPosition = 120
    announce.text = "You Won!!!"
    levelScene.overlayLayer.addChild(announce)
  }
  
  override func willExitWithNextState(nextState: GKState) {
    gameDifficultyModifier += 1
    for node in levelScene.overlayLayer.children {
      node.removeFromParent()
    }
  }
}

class GameSceneLoseState: GameSceneState {
  override func didEnterWithPreviousState(previousState: GKState?) {
    levelScene.paused = true
    gameLoopPaused = true
    
    levelScene.tapState = .nextLevel
    
    let announce = SKLabelNode(fontNamed: "Avenir-Black")
    announce.position = CGPointZero
    announce.fontSize = 80
    announce.zPosition = 120
    announce.text = "You Died!"
    levelScene.overlayLayer.addChild(announce)
  }
  
  override func willExitWithNextState(nextState: GKState) {
    for node in levelScene.overlayLayer.children {
      node.removeFromParent()
    }
  }
}