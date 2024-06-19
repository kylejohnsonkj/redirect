//
//  ContinueScene.swift
//  redirect
//
//  Created by Kyle Johnson on 2/21/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import SpriteKit
import AVFoundation
import GoogleMobileAds

class ContinueScene: SKScene {
    
    static var score = 0
    static var watchingVideo = false
    static var rewardGiven = false
    
    var bg = SKSpriteNode()
    
    var count = 3
    var runCountdown = true
    var countdownLabel = SKLabelNode(fontNamed: "Futura Medium")
    let beepSound = SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.0
            AppDelegate.muteSounds = true
        } else {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.33
            AppDelegate.muteSounds = false
        }
        
        makeBg()
        buildScene()
        countdown(count: count)
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
        
        let medal = SKSpriteNode(imageNamed: "hidden")
        medal.position = CGPoint(x: size.width/2, y: size.height/2 + size.height/4 + 2)
        medal.setScale(0.45)
        medal.name = "medal"
        addChild(medal)
        
        let continueText = SKLabelNode(fontNamed: "Futura Condensed Medium")
        continueText.text = "CONTINUE?"
        continueText.fontSize = 40
        continueText.fontColor = .white
        continueText.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(continueText)
        
        let scores = SKLabelNode(fontNamed: "Futura Condensed Medium")
        scores.text = "SCORE: \(GameScene.score)  TOP: \(GameScene.highscore)"
        scores.fontSize = 22
        scores.fontColor = UIColor(red: 89/255, green: 255/255, blue: 0/255, alpha: 1.0)
        scores.position = CGPoint(x: size.width/2, y: size.height/2 - 35)
        addChild(scores)
        
        let spend = SKSpriteNode(imageNamed: "spend.png")
        spend.position = CGPoint(x: size.width/2, y: size.height/4 + 15)
        spend.size = CGSize(width: 100, height: 87.5)
        spend.name = "spend"
        spend.color = .black
        addChild(spend)
        
//        if GameScene.coins < 5 {
//            spend.colorBlendFactor = 0.5
//        } else {
//            spend.colorBlendFactor = 0
//        }
//
//        let watch = SKSpriteNode(imageNamed: "watch.png")
//        watch.position = CGPoint(x: size.width/2 + 60, y: size.height/4 + 15)
//        watch.size = CGSize(width: 100, height: 87.5)
//        watch.name = "watch"
//        addChild(watch)
    }
    
    func countdown(count: Int) {
        
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .baseline
        countdownLabel.position = CGPoint(x: size.width/2 - 2, y: size.height/2 + size.height/4 - 20)
        countdownLabel.fontColor = .white
        countdownLabel.fontSize = 80
        countdownLabel.text = "\(count)"
        
        addChild(countdownLabel)
        
        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.25),
                                                  SKAction.run(countdownAction)])
        
        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: count),
                                     SKAction.run(endCountdown)]))
        
    }
    
    func countdownAction() {
        if runCountdown {
            count -= 1
            if !AppDelegate.muteSounds { run(beepSound) }
            countdownLabel.text = "\(count)"
        }
    }
    
    func endCountdown() {
        if runCountdown {
            run(SKAction.run() {
                let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                let scene = GameOverScene(size: self.size)
                self.view?.presentScene(scene, transition:reveal)
            })
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node.name == "spend" {
                
                if GameScene.coins >= 5 {
                
                    GameScene.coins = GameScene.coins - 5
                    GameScene.isContinued = true
                    
                    let purchaseSound = SKAction.playSoundFileNamed("purchase.mp3", waitForCompletion: false)
                    if !AppDelegate.muteSounds { run(purchaseSound) }
                    UserDefaults.standard.set(GameScene.coins, forKey: "coins")
                    
                    UserDefaults.standard.synchronize()
                    
                    run(SKAction.run() {
                        let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                        let scene = GameScene(size: self.size)
                        self.view?.presentScene(scene, transition:reveal)
                    })
                }
//            } else if node.name == "watch" {
//                
//                runCountdown = false
//                Chartboost.showRewardedVideo(CBLocationMainMenu)
//                
//                let when = DispatchTime.now() + 1
//                DispatchQueue.main.asyncAfter(deadline: when) {
//                    ContinueScene.watchingVideo = true
//                }
//                
//                GameViewController.MusicHelper.sharedHelper.pauseBackgroundMusic()
            } else {
                
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                    let scene = GameOverScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
        }
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        
//        // when ad finishes playing, continue game
//        if ContinueScene.rewardGiven && !Chartboost.isAnyViewVisible() {
//            run(SKAction.run() {
//                let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
//                let scene = GameScene(size: self.size)
//                self.view?.presentScene(scene, transition:reveal)
//            })
//        }
//        
//        // if ad is cancelled, redirect to game over screen
//        if ContinueScene.watchingVideo && !Chartboost.isAnyViewVisible() {
//            GameViewController.MusicHelper.sharedHelper.resumeBackgroundMusic()
//            run(SKAction.run() {
//                let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
//                let scene = GameOverScene(size: self.size)
//                self.view?.presentScene(scene, transition:reveal)
//            })
//        }
//    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
