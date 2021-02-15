//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Артур Лутфуллин on 07.01.2020.
//  Copyright © 2020 Артур Лутфуллин. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
 
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel : SKLabelNode!
    var score: Int = 0 {
        didSet{
            scoreLabel.text = "Счёт: \(score)"
        }
    }
    var gameTimer : Timer!
    var alliens = ["alien","alien2","alien3"]
    
    let allienCategory: UInt32 = 0x1 << 1
    let bulletCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: UIScreen.main.bounds.width/2, y: 40)
        
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Счёт: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 100, y:   UIScreen.main.bounds.height - 50)
        score = 0
        
        self.addChild(scoreLabel)
        
        var TimeInterval = 0.75
        if UserDefaults.standard.bool(forKey: "hard") {
            TimeInterval = 0.3
        }
        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval, target: self, selector: #selector(addAllien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error!) in
            if let accelerometrData = data {
                let acceleration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y:player.position.y )
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            secondBody = contact.bodyA
            firstBody = contact.bodyB
        } else {
            secondBody = contact.bodyB
            firstBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & allienCategory) != 0 && (secondBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: secondBody.node as! SKSpriteNode , allienNode: firstBody.node as! SKSpriteNode)
        }
    }
    
    func collisionElements (bulletNode:  SKSpriteNode, allienNode: SKSpriteNode ) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = allienNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        allienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion?.removeFromParent()
        }
        
        score += 5
    }
    
    
    @objc func addAllien(){
        alliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: alliens) as! [String]
        
        let allien = SKSpriteNode(imageNamed: alliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: (Int(UIScreen.main.bounds.size.width - 20)))
        let pos = CGFloat(randomPos.nextInt())
        allien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + allien.size.height)
       
        
        allien.physicsBody = SKPhysicsBody(rectangleOf: allien.size)
        allien.physicsBody?.isDynamic = true
        
        allien.physicsBody?.categoryBitMask = allienCategory
        allien.physicsBody?.contactTestBitMask = bulletCategory
        allien.physicsBody?.collisionBitMask = 0
        
        self.addChild(allien)
        
        let animDuration: TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - allien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        allien.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
       bullet.physicsBody?.isDynamic = true
       
       bullet.physicsBody?.categoryBitMask = bulletCategory
       bullet.physicsBody?.contactTestBitMask = allienCategory
       bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y:  UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
        
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
