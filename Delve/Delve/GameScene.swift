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
#if os(iOS)
  import CoreMotion
#endif

class GameScene: SKScene, tileMapDelegate, SKPhysicsContactDelegate, SKTGameControllerDelegate {
  
  var health = 1000
  var tapState = tapAction.startGame
  
  //World generator
  var worldGen = tileMap()
  let textureStrings = ["Floor4","Floor1","Floor2","Floor3","Floor5","Floor6","Floor7","Floor8"]
  var randomFloorTile:GKRandomDistribution!
  
  //Layers
  var worldLayer = SKNode()
  var guiLayer = SKNode()
  var enemyLayer = SKNode()
  var overlayLayer = SKNode()
  
  //State Machine
  lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
    GameSceneInitialState(scene: self),
    GameSceneActiveState(scene: self),
    GameScenePausedState(scene: self),
    GameSceneLimboState(scene: self),
    GameSceneWinState(scene: self),
    GameSceneLoseState(scene: self)
    ])
  
  //ECS
  var entities = Set<GKEntity>()
  //1
  var lastUpdateTimeInterval: NSTimeInterval = 0
  let maximumUpdateDeltaTime: NSTimeInterval = 1.0 / 60.0
  var lastDeltaTime: NSTimeInterval = 0
  //2
  lazy var componentSystems: [GKComponentSystem] = {
    let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
    let projMoveSystem = GKComponentSystem(componentClass: ProjMoveComponent.self)
    let playerMoveSystem = GKComponentSystem(componentClass: PlayerMoveComponent.self)
    return [animationSystem, projMoveSystem, playerMoveSystem]
  }()
  let enemyMoveSystem = EnemyMoveComponentSystem(componentClass: EnemyMoveComponent.self)
  
  //Controls
  #if os(iOS)
  lazy var motionManager: CMMotionManager = {
    let motion = CMMotionManager()
    motion.accelerometerUpdateInterval = 1.0/10.0
    return motion
  }()
  #endif
  var movement = CGPointZero
  var playerAttack = CGPointZero
  
  //Timers
  var lastHealthDrop: NSTimeInterval = 0
  var lastHurt: CFTimeInterval = 5.0
  var lastThrow: NSTimeInterval = 0
  
  //Sounds
  let sndEnergy = SKAction.playSoundFileNamed("delve_energy", waitForCompletion: false)
  let sndHit = SKAction.playSoundFileNamed("delve_hit", waitForCompletion: false)
  let sndKill = SKAction.playSoundFileNamed("delve_kill", waitForCompletion: false)
  let sndShoot = SKAction.playSoundFileNamed("delve_shoot", waitForCompletion: false)
  let sndDamage = SKAction.playSoundFileNamed("delve_take_damage", waitForCompletion: false)
  let sndWin = SKAction.playSoundFileNamed("delve_win", waitForCompletion: false)
  
  override func didMoveToView(view: SKView) {
    
    //Delegates
    worldGen.delegate = self
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector.zero
    
    //Setup Camera
    let myCamera = SKCameraNode()
    camera = myCamera
    addChild(myCamera)
    updateCameraScale()
    
    //Config World
    addChild(worldLayer)
    camera!.addChild(guiLayer)
    guiLayer.addChild(overlayLayer)
    worldLayer.addChild(enemyLayer)
    
    //Gamestate
    stateMachine.enterState(GameSceneInitialState.self)
    
    //Game Controllers
    SKTGameController.sharedInstance.delegate = self
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    switch tapState {
  case .startGame:
      stateMachine.enterState(GameSceneActiveState.self)
    break
  case .attack:
    for touch in touches {
      let location = touch.locationInNode(self)
      if let player = worldLayer.childNodeWithName("playerNode") {
        playerAttack = location - player.position
      }
    }
    break
  case .dismissPause:
      stateMachine.enterState(GameSceneActiveState.self)
    break
  case .nextLevel:
      if let scene = GameScene(fileNamed:"GameScene") {
    scene.scaleMode = (self.scene?.scaleMode)!
    let transition = SKTransition.fadeWithDuration(0.6)
    view!.presentScene(scene, transition: transition)
  }
    break
  default:
      
    break
    }
  }
  
  override func update(currentTime: CFTimeInterval) {
    
    if gameLoopPaused { return }
    
    //Calculate delta time
    var deltaTime = currentTime - lastUpdateTimeInterval
    deltaTime = deltaTime > maximumUpdateDeltaTime ?
      maximumUpdateDeltaTime : deltaTime
    lastUpdateTimeInterval = currentTime
    
    //Motion
    #if os(iOS)
      if (self.motionManager.accelerometerData != nil) {
        //1
        var motion = CGPointZero
        if self.motionManager.accelerometerData!.acceleration.x > 0.02 || self.motionManager.accelerometerData!.acceleration.x < -0.02 {
          motion.y = CGFloat(self.motionManager.accelerometerData!.acceleration.x)
        }
        if self.motionManager.accelerometerData!.acceleration.y > 0.02 || self.motionManager.accelerometerData!.acceleration.y < -0.02 {
          motion.x = CGFloat((self.motionManager.accelerometerData!.acceleration.y) * -1)
        }
        //2
        if (SKTGameController.sharedInstance.gameControllerConnected == true) {
          //3
          if (SKTGameController.sharedInstance.gameControllerType == .standard) {
            self.playerAttack = motion
          }
        } else {
          self.movement = motion
        }
      }
    #endif
    
    //player controls
    if let player = worldLayer.childNodeWithName("playerNode") as?
      EntityNode,
      let playerEntity = player.entity as? PlayerEntity {
        if !(movement == CGPointZero) {
          playerEntity.moveComponent.movement = movement
        }
    }
    
    //Periodically change health and report
    //1
    if currentTime > (lastHealthDrop + 2.0) {
      health = health - 5
      lastHealthDrop = currentTime
    }
    
    //2
    if health < 1 {
      stateMachine.enterState(GameSceneLoseState.self)
    }
    
    //Update all components
    for componentSystem in componentSystems {
      componentSystem.updateWithDeltaTime(deltaTime)
    }
    
    //Update player after components
    if let player = worldLayer.childNodeWithName("playerNode") as? EntityNode,
      let playerEntity = player.entity as? PlayerEntity {
        //1
        enemyMoveSystem.updateWithDeltaTime(deltaTime, playerPosition: player.position)
        //2
        centerCameraOnPoint(player.position)
        //3
        if (lastHurt > 1.2) {
          playerEntity.animationComponent.node.shader = nil
        } else {
          lastHurt = lastHurt + deltaTime
        }
    }
    
    if playerAttack != CGPointZero {
      if lastUpdateTimeInterval > (lastThrow + 0.3) {
        if let player = worldLayer.childNodeWithName("playerNode") {
          let atlasTiles = SKTextureAtlas(named: "Tiles")
          let node = SKSpriteNode(texture: atlasTiles.textureNamed("Projectile"))
          node.size = CGSize(width: 18, height: 24)
          node.zPosition = 65
          let projEntity = ProjectileEntity(withNode: node, origin: player.position, direction: playerAttack)
          addEntity(projEntity)
          lastThrow = lastUpdateTimeInterval
          runAction(sndShoot)
        }
      }
    }
  }
  
  override func didFinishUpdate() {
    if let label = guiLayer.childNodeWithName("healthLabel") as? SKLabelNode {
    label.text = "\(health)"
    }
  }
  
  func setupLevel() {
    randomFloorTile = GKRandomDistribution(forDieWithSideCount: textureStrings.count)
    //Update
    worldGen.generateLevel(1)
    //Add
    worldGen.generateMap()
    worldGen.presentLayerViaDelegate()
  }
  
  func createNodeOf(type type:tileType, location:CGPoint) {
    let atlasTiles = SKTextureAtlas(named: "Tiles")
    
    switch type {
    case .tileGround:
      let node = SKSpriteNode(texture: atlasTiles.textureNamed(textureStrings[randomFloorTile.nextInt() - 1]))
      node.size = CGSize(width: 32, height: 32)
      node.position = location
      node.zPosition = 1
      addChild(node)
      break
    case .tileWall:
      let node = SKSpriteNode(texture: atlasTiles.textureNamed("Wall1"))
      node.size = CGSize(width: 32, height: 32)
      node.position = location
      node.zPosition = 1
      node.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin:
        CGPoint(x: -16, y: -16), size: CGSize(width: 32, height: 32)))
      node.physicsBody?.categoryBitMask = ColliderType.Wall.rawValue
      node.name = "wall"
      worldLayer.addChild(node)
      break
    case .tileWallLit:
      let node = SKSpriteNode(texture: atlasTiles.textureNamed("Wall2"))
      node.size = CGSize(width: 32, height: 32)
      node.position = location
      node.zPosition = 1
      node.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(
        origin: CGPoint(x: -16, y: -16),
        size: CGSize(width: 32, height: 32)))
      node.physicsBody?.categoryBitMask = ColliderType.Wall.rawValue
      node.name = "wall"
      worldLayer.addChild(node)
      break
    case .tileStart:
      //1
      let node = SKSpriteNode(texture: atlasTiles.textureNamed(textureStrings[randomFloorTile.nextInt() - 1]))
      node.size = CGSize(width: 32, height: 32)
      node.position = location
      node.zPosition = 1
      worldLayer.addChild(node)
      //2
      let playerEntity = PlayerEntity()
      let playerNode = playerEntity.spriteComponent.node
      playerNode.position = location
      playerNode.name = "playerNode"
      playerNode.zPosition = 50
      playerNode.anchorPoint = CGPointMake(0.5, 0.2)
      //3
      playerEntity.animationComponent.requestedAnimationState = .Walk_Down
      addEntity(playerEntity)
      centerCameraOnPoint(location)
      break
    case .tileEnemy:
      let node = SKSpriteNode(texture: atlasTiles.textureNamed(textureStrings[randomFloorTile.nextInt() - 1]))
      node.size = CGSize(width: 32, height: 32)
      node.position = location
      node.zPosition = 1
      worldLayer.addChild(node)
      
      let enemyEntity = EnemyEntity()
      let enemyNode = enemyEntity.spriteComponent.node
      enemyNode.position = location
      enemyNode.name = "enemySprite"
      enemyNode.zPosition = 55
      enemyEntity.spriteComponent.node.name = "enemyNode"
      enemyEntity.animationComponent.requestedAnimationState = .Walk_Down
      addEntity(enemyEntity)
      break
    case .tileEnd:
      let levelEndEntity = LevelEndEntity()
      let levelEndNode = levelEndEntity.spriteComponent.node
      levelEndNode.name = "levelEnd"
      levelEndNode.position = location
      levelEndNode.zPosition = 1
      addEntity(levelEndEntity)
      break
    case .tileFood:
      //1
      let node = SKSpriteNode(texture: atlasTiles.textureNamed(textureStrings[randomFloorTile.nextInt() - 1]))
      node.size = CGSize(width: 32, height: 32)
      node.position = location
      node.zPosition = 1
      worldLayer.addChild(node)
      //2
      let food = FoodEntity()
      food.spriteComponent.node.name = "foodNode"
      food.spriteComponent.node.position = location
      food.spriteComponent.node.zPosition = 5
      addEntity(food)
      break
    default:
      break
    }
  }
  
  func addEntity(entity: GKEntity) {
    entities.insert(entity)
    
    for componentSystem in self.componentSystems {
      componentSystem.addComponentWithEntity(entity)
    }
    enemyMoveSystem.addComponentWithEntity(entity)
    
    if let spriteNode = entity.componentForClass(SpriteComponent.self)?.node {
      if spriteNode.name == "enemyNode" {
        enemyLayer.addChild(spriteNode)
      } else {
        worldLayer.addChild(spriteNode)
      }
    }
    
    if let projNode = entity.componentForClass(ProjMoveComponent.self)?.node {
      worldLayer.addChild(projNode)
    }
  }
  
  //MARK: camera controls
  
  func centerCameraOnPoint(point: CGPoint) {
    if let camera = camera {
      camera.position = point
    }
  }
  func updateCameraScale() {
    if let camera = camera {
      camera.setScale(0.44)
    }
  }
  
  //MARK: physics contact
  
  func didBeginContact(contact: SKPhysicsContact) {
    let bodyA = contact.bodyA.node
    let bodyB = contact.bodyB.node
    
    if bodyA?.name == "levelEnd" && bodyB?.name == "playerNode" {
      stateMachine.enterState(GameSceneLimboState.self)
      movement = CGPointZero
      
      for enemyNode in enemyLayer.children {
        if let enemy = enemyNode as? EntityNode,
          let enemyEnt = enemy.entity as? EnemyEntity {
            enemyMoveSystem.removeComponentWithEntity(enemyEnt)
            enemyEnt.animationComponent.requestedAnimationState = .Die_Down
            enemy.physicsBody = nil
        }
      }
      
      SKTAudio.sharedInstance().pauseBackgroundMusic()
      self.runAction(SKAction.sequence([sndWin,SKAction.waitForDuration(2),SKAction.runBlock({ () -> Void in
        SKTAudio.sharedInstance().resumeBackgroundMusic()
        self.stateMachine.enterState(GameSceneWinState.self)
      })]))
    }
    if bodyA?.name == "enemyNode" {
      if bodyB?.name == "playerNode" {
        //1
        bodyA?.removeFromParent()
        runAction(sndDamage)
        //2
        health = health - 50
        if let player = worldLayer.childNodeWithName("playerNode") as? EntityNode,
          let playerEntity = player.entity as? PlayerEntity {
            
            playerEntity.spriteComponent.node.removeActionForKey("flash")
            playerEntity.spriteComponent.node.runAction(SKAction.sequence([
              SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5),
              SKAction.colorizeWithColor(SKColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.5),
              ]), withKey: "flash")
            lastHurt = 0.0
        }
      }
    }
    if bodyA?.name == "foodNode" {
      if bodyB?.name == "playerNode" {
        bodyA?.removeFromParent()
        health = health + 40
        runAction(sndEnergy)
      }
    }
    
    //1
    if bodyA?.name == "wall" {
      if bodyB?.name == "projectile" {
        bodyB?.removeFromParent()
      }
    }
    
    //2
    if bodyA?.name == "projectile" {
      if bodyB?.name == "enemyNode" {
        damageEnemy(bodyA!, enemyNode: bodyB!)
      }
    }
    
    if bodyA?.name == "enemyNode" {
      if bodyB?.name == "projectile" {
        damageEnemy(bodyB!, enemyNode: bodyA!)
      }
    }
    
  }
  
  func damageEnemy(projectile:SKNode, enemyNode:SKNode) {
    //1
    projectile.removeFromParent()
    if let enemy = enemyNode as? EntityNode,
      let enemyEnt = enemy.entity as? EnemyEntity {
        //2 Enemy takes damange
        enemyEnt.enemyHealth = enemyEnt.enemyHealth - playerSettings.enemyDamagePerHit
        //3 Kill enemy if damage is significant
        if enemyEnt.enemyHealth <= 0.0 {
          runAction(sndKill)
          enemyMoveSystem.removeComponentWithEntity(enemyEnt)
          enemyEnt.animationComponent.requestedAnimationState = .Die_Down
          //4
          enemy.runAction(SKAction.sequence([SKAction.runBlock({ () -> Void in
            enemy.physicsBody = nil
          }),SKAction.waitForDuration(2.5),SKAction.fadeOutWithDuration(0.5),SKAction.removeFromParent()]))
        } else {
          //Damaged but not killed
          runAction(sndHit)
        }
    }
  }
  
  //MARK: SKTGameController Delegate
  
  func buttonEvent(event:String,velocity:Float,pushedOn:Bool) {
    switch tapState {
    case .startGame:
      if event == "buttonA" {
        stateMachine.enterState(GameSceneActiveState.self)
      }
      break
    case .dismissPause:
      if event == "buttonA" {
        stateMachine.enterState(GameSceneActiveState.self)
      }
      break
    case .nextLevel:
      if event == "buttonA" {
        if let scene = GameScene(fileNamed:"GameScene") {
          scene.scaleMode = (self.scene?.scaleMode)!
          let transition = SKTransition.fadeWithDuration(0.6)
          view!.presentScene(scene, transition: transition)
        }
      }
      break
    case .attack:
      if event == "dpad_up" {
        movement.y = CGFloat(velocity)
      }
      if event == "dpad_down" {
        movement.y = CGFloat(velocity) * -1
      }
      if event == "dpad_left" {
        movement.x = CGFloat(velocity) * -1
      }
      if event == "dpad_right" {
        movement.x = CGFloat(velocity)
      }
      break
    default:
      break
    }
  }
  
  //1
  func stickEvent(event:String, point:CGPoint) {
    switch tapState {
    case .attack:
      if event == "leftstick" {
        //2
        var myPoint = point
        movement = myPoint.normalize() * 0.5
      }
      if event == "rightstick" {
        playerAttack = point
      }
      break
    default:
      break
    }
  }
  
}
