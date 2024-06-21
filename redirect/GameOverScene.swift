//
//  GameOverScene.swift
//  redirect
//
//  Created by Kyle Johnson on 1/9/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class GameOverScene: SKScene, GKGameCenterControllerDelegate {
    
    // scene vars
    var bg = SKSpriteNode()
    var medal = SKSpriteNode()
    let winSound = SKAction.playSoundFileNamed("tada.mp3", waitForCompletion: false)
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.0
            AppDelegate.muteSounds = true
        } else {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 1.0
            AppDelegate.muteSounds = false
        }
        
        GameScene.isContinued = false
        
        makeBg()
        buildScene()
        submitHighscore()
        updateAchievements()
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
        
        // show medal
        
        var shouldRotate = false;
        
        if GameScene.score >= 100 {
            medal = SKSpriteNode(imageNamed: "diamond.png")
            shouldRotate = true
        } else if GameScene.score >= 50 {
            medal = SKSpriteNode(imageNamed: "ruby.png")
            shouldRotate = true
        } else if GameScene.score >= 30 {
            medal = SKSpriteNode(imageNamed: "gold.png")
        } else if GameScene.score >= 20 {
            medal = SKSpriteNode(imageNamed: "silver.png")
        } else if GameScene.score >= 10 {
            medal = SKSpriteNode(imageNamed: "bronze.png")
        } else {
            medal = SKSpriteNode(imageNamed: "fail.png")
        }
        
        medal.position = CGPoint(x: size.width/2, y: size.height/2 + size.height/4 + 2)
        medal.setScale(0.45)
        medal.name = "medal"
        addChild(medal)
        
        let scale1 = SKAction.scale(by: 1.2, duration: 0.0)
        let scale2 = SKAction.scale(by: 1/1.2, duration: 0.25)
        medal.run(SKAction.sequence([scale1, scale2]))
        
        let rotation = SKAction.rotate(byAngle: .pi, duration: 2.0)
        if shouldRotate == true {
            medal.run(SKAction.repeatForever(rotation.reversed()))
        }
        
        
        // display score
        
        let score = SKLabelNode(fontNamed: "Futura Condensed Medium")
        score.text = "YOU SCORED \(GameScene.score)"
        score.fontSize = 40
        score.fontColor = .white
        score.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(score)
        
        let scale3 = SKAction.scale(by: 1.6, duration: 0.0)
        let scale4 = SKAction.scale(by: 1/1.6, duration: 0.25)
        score.run(SKAction.sequence([scale3, scale4]))
        
        let playWinSound = SKAction.run {
            self.run(self.winSound)
        }
        
        if !AppDelegate.muteSounds {
            if GameScene.score >= 10 {
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), playWinSound]))
            }
        }
        
        
        // top score
        
        let highscore = SKLabelNode(fontNamed: "Futura Condensed Medium")
        highscore.text = "TOP: \(GameScene.highscore)"
        highscore.fontSize = 22
        highscore.fontColor = UIColor(red: 89/255, green: 255/255, blue: 0/255, alpha: 1.0)
        highscore.position = CGPoint(x: size.width/2, y: size.height/2 - 35)
        addChild(highscore)
        
        if GameScene.score > (UserDefaults.standard.object(forKey: "highscore") as? NSInteger)! {
            
            UserDefaults.standard.set(GameScene.score, forKey: "highscore")
        }
        
        UserDefaults.standard.set(GameScene.coins, forKey: "coins")
        UserDefaults.standard.synchronize()
        
        
        // add buttons
        
        let gamecenter = SKSpriteNode(imageNamed: "game-center.png")
        gamecenter.position = CGPoint(x: size.width - 50, y: size.height - 50)
        gamecenter.size = CGSize(width: 50, height: 50)
        gamecenter.name = "gamecenter"
        addChild(gamecenter)
        
        let share = SKSpriteNode(imageNamed: "share.png")
        share.position = CGPoint(x: 50, y: size.height - 50)
        share.size = CGSize(width: 50, height: 50)
        share.name = "share"
        addChild(share)
        
        let playNode = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 8)
        playNode.position = CGPoint(x: size.width/2, y: size.height/3 + 5)
        playNode.fillColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
        playNode.strokeColor = playNode.fillColor
        playNode.name = "play"
        addChild(playNode)
        
        let play = SKLabelNode(fontNamed: "Futura")
        play.text = "Play Again?"
        play.fontSize = 23
        play.fontColor = .white
        play.position = CGPoint(x: 0, y: -8)
        play.name = "play"
        playNode.addChild(play)
        
        let storeNode = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 8)
        storeNode.position = CGPoint(x: size.width/2, y: size.height/4 - 7)
        storeNode.fillColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
        storeNode.strokeColor = storeNode.fillColor
        storeNode.name = "main_menu"
        addChild(storeNode)
        
        let menu = SKLabelNode(fontNamed: "Futura")
        menu.text = "Main Menu"
        menu.fontSize = 23
        menu.fontColor = UIColor(red: 252/255, green: 252/255, blue: 98/255, alpha: 1.0)
        menu.position = CGPoint(x: 0, y: -8)
        menu.name = "main_menu"
        storeNode.addChild(menu)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node.name == "play" {
                // replay game
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.up, duration: 0.5)
                    let scene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            if node.name == "main_menu" {
                // go to main menu
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                    let scene = StartupScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            if node.name == "medal" {
                let scale1 = SKAction.scale(by: 1.25, duration: 0.25)
                let scale2 = SKAction.scale(by: 1/1.25, duration: 0.25)
                medal.run(SKAction.sequence([scale1, scale2]))
                
                if GameScene.score >= 10 {
                    if !AppDelegate.muteSounds { medal.run(winSound) }
                }
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
    
    // submits the highscore to Game Center
    func submitHighscore() {
        
        if GKLocalPlayer.local.isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "redirect_top_score")
            scoreReporter.value = Int64(GameScene.highscore)
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {error -> Void in
            })
        }
    }
    
    // updates achievements on Game Center
    func updateAchievements() {
        
        if GKLocalPlayer.local.isAuthenticated {
            
            let achievement_ids = ["redirect_bronze_medal", "redirect_silver_medal", "redirect_gold_medal", "redirect_ruby_achievement", "redirect_diamond_achievement"]
            
            for achievement_id in achievement_ids {
                
                let achievement = GKAchievement(identifier: achievement_id)
                
                var percentComplete = 0.0
                
                if achievement_id == "redirect_bronze_medal" {
                    percentComplete = (Double(GameScene.highscore) / 10.0) * 100
                } else if achievement_id == "redirect_silver_medal" {
                    percentComplete = (Double(GameScene.highscore) / 20.0) * 100
                } else if achievement_id == "redirect_gold_medal" {
                    percentComplete = (Double(GameScene.highscore) / 30.0) * 100
                } else if achievement_id == "redirect_ruby_achievement" {
                    if GameScene.highscore >= 50 {
                        percentComplete = 100
                    } else {
                        percentComplete = 0
                    }
                } else if achievement_id == "redirect_diamond_achievement" {
                    if GameScene.highscore >= 100 {
                        percentComplete = 100
                    } else {
                        percentComplete = 0
                    }
                }
                
                if percentComplete >= 100 {
                    percentComplete = 100
                }
                
                if percentComplete != 0.0 {
                    achievement.percentComplete = percentComplete
                    achievement.showsCompletionBanner = true  // use Game Center's UI
                    GKAchievement.report([achievement], withCompletionHandler: nil)
                }
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
