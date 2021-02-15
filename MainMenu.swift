//
//  MainMenu.swift
//  SpaceShooter
//
//  Created by Артур Лутфуллин on 07.01.2020.
//  Copyright © 2020 Артур Лутфуллин. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    var starField: SKEmitterNode!
    
    var newGameBtnNode: SKSpriteNode!
    var levelBtnNode: SKSpriteNode!
    var labelLevelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
        starField = (self.childNode(withName: "starfield_anim") as! SKEmitterNode)
        starField.advanceSimulationTime(10)
        
        newGameBtnNode = (self.childNode(withName: "newGameButton") as! SKSpriteNode)
        newGameBtnNode.texture = SKTexture(imageNamed: "swift_newGameBtn")
        
        levelBtnNode = (self.childNode(withName: "LevelButtoon") as! SKSpriteNode)
        levelBtnNode.texture = SKTexture(imageNamed: "swift_levelBtn")
        
        labelLevelNode = (self.childNode(withName: "labelLevelButton") as! SKLabelNode)
        
        let userLevel = UserDefaults.standard
        
        if userLevel.bool(forKey: "hard") {
            labelLevelNode.text = "Сложно"
        } else {
            labelLevelNode.text = "Легко"}
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene  = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "LevelButtoon" {
                changeLevel()
            }
        }
    }
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if labelLevelNode.text == "Легко" {
            labelLevelNode.text = "Сложно"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Легко"
            userLevel.set(false, forKey: "hard")
        }
        userLevel.synchronize()
    }
    
}
