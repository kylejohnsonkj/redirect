//
//  StartScene.swift
//  redirect
//
//  Created by Kyle Johnson on 1/9/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class StartupScene: SKScene, GKGameCenterControllerDelegate {
    
    var bg = SKSpriteNode()
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.0
            AppDelegate.muteSounds = true
        } else {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 1.0
            AppDelegate.muteSounds = false
        }
        
        makeBg()
        buildScene()
    }
    
    func makeBg() {
        
        let bgTexture = SKTexture(imageNamed: "bg.png")

        let movebg = SKAction.moveBy(x: -self.frame.height, y: 0, duration: 15)
        let replacebg = SKAction.moveBy(x: self.frame.height, y: 0, duration: 0)
        let movebgForever = SKAction.repeatForever(SKAction.sequence([movebg, replacebg]))
        
        for i in 0 ..< 3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.size.height = self.frame.height
            bg.size.width = self.frame.height
            bg.position = CGPoint(x: self.frame.height / 2 + self.frame.height * CGFloat(i), y: self.frame.midY)
            bg.zPosition = 0
            
            bg.run(movebgForever)
            
            self.addChild(bg)
        }
    }
    
    func buildScene() {
        
        let credits = SKLabelNode(fontNamed: "Futura Condensed Medium")
        credits.text = "Created by Kyle Johnson, © 2017"
        credits.fontSize = 15
        credits.fontColor = .gray
        credits.position = CGPoint(x: size.width/2, y: size.height - 30)
        addChild(credits)
        
        let icon = SKSpriteNode(imageNamed: "icon.png")
        icon.position = CGPoint(x: size.width/2, y: size.height/2 + size.height/6 + 2)
        icon.size = CGSize(width: 120, height: 120)
        addChild(icon)
        
        let title = SKLabelNode(fontNamed: "Futura Medium")
        title.text = "redirect"
        title.fontSize = 40
        title.fontColor = .white
        title.position = CGPoint(x: size.width/2, y: size.height/2 - 15)
        addChild(title)
        
        let scale1 = SKAction.scale(by: 1.4, duration: 1.0)
        let scale2 = SKAction.scale(by: 1/1.4, duration: 1.0)
        title.run(SKAction.repeatForever(SKAction.sequence([scale1, scale2])))
        
        let playNode = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 8)
        playNode.position = CGPoint(x: size.width/2, y: size.height/3 + 5)
        playNode.fillColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
        playNode.strokeColor = playNode.fillColor
        playNode.name = "play"
        addChild(playNode)
        
        let play = SKLabelNode(fontNamed: "Futura Medium")
        play.text = "Tap to Play"
        play.fontSize = 23
        play.fontColor = .white
        play.position = CGPoint(x: 0, y: -8)
        play.name = "play"
        playNode.addChild(play)
        
        let storeNode = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 8)
        storeNode.position = CGPoint(x: size.width/2, y: size.height/4 - 7)
        storeNode.fillColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
        storeNode.strokeColor = storeNode.fillColor
        storeNode.name = "store"
        addChild(storeNode)
        
        let store = SKLabelNode(fontNamed: "Futura Medium")
        store.text = "Store"
        store.fontSize = 23
        store.fontColor = UIColor(red: 252/255, green: 252/255, blue: 98/255, alpha: 1.0)
        store.position = CGPoint(x: 0, y: -8)
        store.name = "store"
        storeNode.addChild(store)
        
        let gamecenter = SKSpriteNode(imageNamed: "game-center.png")
        gamecenter.position = CGPoint(x: size.width - 40, y: size.height - 40)
        gamecenter.size = CGSize(width: 50, height: 50)
        gamecenter.name = "gamecenter"
        addChild(gamecenter)
        
        let share = SKSpriteNode(imageNamed: "share.png")
        share.position = CGPoint(x: 40, y: size.height - 40)
        share.size = CGSize(width: 50, height: 50)
        share.name = "share"
        addChild(share)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node.name == "play" {
                print("Game started.")
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.up, duration: 0.5)
                    let scene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            if node.name == "store" {
                print("Store selected.")
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                    let scene = StoreScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            if node.name == "share" {
                let activityViewController = UIActivityViewController(activityItems: ["Check out the game redirect on the App Store! My top score is \(GameScene.highscore). https://appsto.re/us/XUhShb.i" as NSString], applicationActivities: nil)
                let vc: UIViewController? = self.view?.window?.rootViewController
                vc?.present(activityViewController, animated: true, completion: {})
            }
            
            if node.name == "gamecenter" {
                showGameCenter()
            }
        }
    }
    
    func showGameCenter() {
        let rootViewController = self.view?.window?.rootViewController
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        rootViewController?.present(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
