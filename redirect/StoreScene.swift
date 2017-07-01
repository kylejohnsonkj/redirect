//
//  StoreScene.swift
//  redirect
//
//  Created by Kyle Johnson on 1/10/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import SpriteKit
import AVFoundation

class StoreScene: SKScene {
    
    // scene vars
    var bg = SKSpriteNode()
    var coins = SKLabelNode()
    var purchase = SKLabelNode()
    var selectionBox = SKShapeNode()
    
    // all six paddles
    var whitePaddle = SKSpriteNode()
    var greenStitch = SKSpriteNode()
    var polkaDots = SKSpriteNode()
    var yellowTri = SKSpriteNode()
    var diagonal = SKSpriteNode()
    var candyCane = SKSpriteNode()
    
    // has player purchased paddles?
    var paddle2: Int = 0
    var paddle3: Int = 0
    var paddle4: Int = 0
    var paddle5: Int = 0
    var paddle6: Int = 0
    
    // paddle selection
    static var selectedPaddle: Int = 1
    var hoverPaddle: Int = 1
    
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
        
        // Laod game settings
        
        paddle2 = UserDefaults.standard.object(forKey: "paddle2") as! NSInteger
        paddle3 = UserDefaults.standard.object(forKey: "paddle3") as! NSInteger
        paddle4 = UserDefaults.standard.object(forKey: "paddle4") as! NSInteger
        paddle5 = UserDefaults.standard.object(forKey: "paddle5") as! NSInteger
        paddle6 = UserDefaults.standard.object(forKey: "paddle6") as! NSInteger

        GameScene.coins = UserDefaults.standard.object(forKey: "coins") as! NSInteger
        hoverPaddle = StoreScene.selectedPaddle
        
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
        
        let store = SKLabelNode(fontNamed: "Futura Condensed Medium")
        store.text = "STORE"
        store.fontSize = 40
        store.position = CGPoint(x: size.width/2, y: size.height/2 + size.height/4 + 15)
        addChild(store)
        
        coins = SKLabelNode(fontNamed: "Futura Medium")
        coins.text = "$\(GameScene.coins)"
        coins.fontSize = 23
        coins.fontColor = UIColor(red: 252/255, green: 252/255, blue: 98/255, alpha: 1.0)
        coins.position = CGPoint(x: size.width/2, y: size.height/2 + size.height / 6 + 10)
        addChild(coins)
        
        whitePaddle = SKSpriteNode(imageNamed: "whitepaddle-1.png")
        whitePaddle.size = CGSize(width: 70, height: 42.5)
        whitePaddle.position = CGPoint(x: size.width/2 - 100, y: size.height / 2 + 55)
        whitePaddle.name = "whitepaddle"
        addChild(whitePaddle)
        
        greenStitch = SKSpriteNode(imageNamed: "greenstitch-1.png")
        greenStitch.size = CGSize(width: 70, height: 42.5)
        greenStitch.position = CGPoint(x: size.width/2, y: size.height / 2 + 55)
        greenStitch.name = "greenstitch"
        if paddle2 == 0 {
            greenStitch.color = .black
            greenStitch.colorBlendFactor = 0.5
        }
        addChild(greenStitch)
        
        polkaDots = SKSpriteNode(imageNamed: "polkadots-1.png")
        polkaDots.size = CGSize(width: 70, height: 42.5)
        polkaDots.position = CGPoint(x: size.width/2 + 100, y: size.height / 2 + 55)
        polkaDots.name = "polkadots"
        if paddle3 == 0 {
            polkaDots.color = .black
            polkaDots.colorBlendFactor = 0.5
        }
        addChild(polkaDots)
        
        yellowTri = SKSpriteNode(imageNamed: "yellowtri-1.png")
        yellowTri.size = CGSize(width: 70, height: 42.5)
        yellowTri.position = CGPoint(x: size.width/2 - 100, y: size.height / 2 - 15)
        yellowTri.name = "yellowtri"
        if paddle4 == 0 {
            yellowTri.color = .black
            yellowTri.colorBlendFactor = 0.5
        }
        addChild(yellowTri)
        
        diagonal = SKSpriteNode(imageNamed: "diagonal-1.png")
        diagonal.size = CGSize(width: 70, height: 42.5)
        diagonal.position = CGPoint(x: size.width/2, y: size.height / 2 - 15)
        diagonal.name = "diagonal"
        if paddle5 == 0 {
            diagonal.color = .black
            diagonal.colorBlendFactor = 0.5
        }
        addChild(diagonal)
        
        candyCane = SKSpriteNode(imageNamed: "candycane-1.png")
        candyCane.size = CGSize(width: 70, height: 42.5)
        candyCane.position = CGPoint(x: size.width/2 + 100, y: size.height / 2 - 15)
        candyCane.name = "candycane"
        if paddle6 == 0 {
            candyCane.color = .black
            candyCane.colorBlendFactor = 0.5
        }
        addChild(candyCane)
        
        selectionBox = SKShapeNode(rectOf: CGSize(width: 90, height: 40))
        selectionBox.fillColor = .clear
        selectionBox.strokeColor = UIColor(red: 252/255, green: 252/255, blue: 98/255, alpha: 1.0)
        selectionBox.lineWidth = 3
        addChild(selectionBox)
        
        switch StoreScene.selectedPaddle {
        case 1:
            selectionBox.position = whitePaddle.position
        case 2:
            selectionBox.position = greenStitch.position
        case 3:
            selectionBox.position = polkaDots.position
        case 4:
            selectionBox.position = yellowTri.position
        case 5:
            selectionBox.position = diagonal.position
        case 6:
            selectionBox.position = candyCane.position
        default:
            print("Failed to select paddle.")
        }
        
        let purchaseNode = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 8)
        purchaseNode.position = CGPoint(x: size.width/2, y: size.height/3 + 5)
        purchaseNode.fillColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
        purchaseNode.strokeColor = purchaseNode.fillColor
        purchaseNode.name = "purchase"
        addChild(purchaseNode)
        
        purchase = SKLabelNode(fontNamed: "Futura Medium")
        purchase.text = "Use"
        purchase.fontSize = 23
        purchase.fontColor = UIColor(red: 89/255, green: 255/255, blue: 0/255, alpha: 1.0)
        purchase.position = CGPoint(x: 0, y: -8)
        purchase.name = "purchase"
        purchaseNode.addChild(purchase)
        
        let menuNode = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 8)
        menuNode.position = CGPoint(x: size.width/2, y: size.height/4 - 7)
        menuNode.fillColor = UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
        menuNode.strokeColor = menuNode.fillColor
        menuNode.name = "main_menu"
        addChild(menuNode)
        
        let menu = SKLabelNode(fontNamed: "Futura Medium")
        menu.text = "Main Menu"
        menu.fontSize = 23
        menu.fontColor = UIColor(red: 252/255, green: 252/255, blue: 98/255, alpha: 1.0)
        menu.position = CGPoint(x: 0, y: -8)
        menu.name = "main_menu"
        menuNode.addChild(menu)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            UserDefaults.standard.set(StoreScene.selectedPaddle, forKey: "selected_paddle")
            UserDefaults.standard.synchronize()
            
            if node.name == "purchase" && purchase.text == "Use" {
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.up, duration: 0.5)
                    let scene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            if node.name == "main_menu" {
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.up, duration: 0.5)
                    let scene = StartupScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            if node.name == "whitepaddle" {
                hoverPaddle = 1
                selectionBox.position = whitePaddle.position
                coins.text = "$\(GameScene.coins)"
                purchase.text = "Use"
                purchase.alpha = 1.0
                StoreScene.selectedPaddle = 1
            }
            
            if node.name == "greenstitch" {
                hoverPaddle = 2
                selectionBox.position = greenStitch.position
                if paddle2 == 0 && GameScene.coins - 10 >= 0 {
                    purchase.text = "Purchase"
                    coins.text = "$\(GameScene.coins) (Cost: $10)"
                    purchase.alpha = 1.0
                } else {
                    if paddle2 == 0 {
                        purchase.text = "Purchase"
                        purchase.alpha = 0.5
                        coins.text = "$\(GameScene.coins) (Cost: $10)"
                    } else {
                        purchase.text = "Use"
                        StoreScene.selectedPaddle = 2
                        coins.text = "$\(GameScene.coins)"
                        purchase.alpha = 1.0
                    }
                }
            }
            
            if node.name == "polkadots" {
                hoverPaddle = 3
                selectionBox.position = polkaDots.position
                if paddle3 == 0 && GameScene.coins - 20 >= 0 {
                    purchase.text = "Purchase"
                    coins.text = "$\(GameScene.coins) (Cost: $20)"
                    purchase.alpha = 1.0
                } else {
                    if paddle3 == 0 {
                        purchase.text = "Purchase"
                        purchase.alpha = 0.5
                        coins.text = "$\(GameScene.coins) (Cost: $20)"
                    } else {
                        purchase.text = "Use"
                        StoreScene.selectedPaddle = 3
                        coins.text = "$\(GameScene.coins)"
                        purchase.alpha = 1.0
                    }
                }
            }
            
            if node.name == "yellowtri" {
                hoverPaddle = 4
                selectionBox.position = yellowTri.position
                if paddle4 == 0 && GameScene.coins - 30 >= 0 {
                    purchase.text = "Purchase"
                    coins.text = "$\(GameScene.coins) (Cost: $30)"
                    purchase.alpha = 1.0
                } else {
                    if paddle4 == 0 {
                        purchase.text = "Purchase"
                        purchase.alpha = 0.5
                        coins.text = "$\(GameScene.coins) (Cost: $30)"
                    } else {
                        purchase.text = "Use"
                        StoreScene.selectedPaddle = 4
                        coins.text = "$\(GameScene.coins)"
                        purchase.alpha = 1.0
                    }
                }
            }
            
            if node.name == "diagonal" {
                hoverPaddle = 5
                selectionBox.position = diagonal.position
                if paddle5 == 0 && GameScene.coins - 40 >= 0 {
                    purchase.text = "Purchase"
                    coins.text = "$\(GameScene.coins) (Cost: $40)"
                    purchase.alpha = 1.0
                } else {
                    if paddle5 == 0 {
                        purchase.text = "Purchase"
                        purchase.alpha = 0.5
                        coins.text = "$\(GameScene.coins) (Cost: $40)"
                    } else {
                        purchase.text = "Use"
                        StoreScene.selectedPaddle = 5
                        coins.text = "$\(GameScene.coins)"
                        purchase.alpha = 1.0
                    }
                }
            }
            
            if node.name == "candycane" {
                hoverPaddle = 6
                selectionBox.position = candyCane.position
                if paddle6 == 0 && GameScene.coins - 50 >= 0 {
                    purchase.text = "Purchase"
                    coins.text = "$\(GameScene.coins) (Cost: $50)"
                    purchase.alpha = 1.0
                } else {
                    if paddle6 == 0 {
                        purchase.text = "Purchase"
                        purchase.alpha = 0.5
                        coins.text = "$\(GameScene.coins) (Cost: $50)"
                    } else {
                        purchase.text = "Use"
                        StoreScene.selectedPaddle = 6
                        coins.text = "$\(GameScene.coins)"
                        purchase.alpha = 1.0
                    }
                }
            }
            
            if node.name == "purchase" && purchase.text == "Purchase" && purchase.alpha == 1.0 {
                
                if hoverPaddle == 2 {
                    GameScene.coins = GameScene.coins - 10
                    coins.text = "$\(GameScene.coins)"
                    UserDefaults.standard.set(1, forKey: "paddle2")
                    paddle2 = 1
                    greenStitch.colorBlendFactor = 0
                } else if hoverPaddle == 3 {
                    GameScene.coins = GameScene.coins - 20
                    coins.text = "$\(GameScene.coins)"
                    UserDefaults.standard.set(1, forKey: "paddle3")
                    paddle3 = 1
                    polkaDots.colorBlendFactor = 0
                } else if hoverPaddle == 4 {
                    GameScene.coins = GameScene.coins - 30
                    coins.text = "$\(GameScene.coins)"
                    UserDefaults.standard.set(1, forKey: "paddle4")
                    paddle4 = 1
                    yellowTri.colorBlendFactor = 0
                } else if hoverPaddle == 5 {
                    GameScene.coins = GameScene.coins - 40
                    coins.text = "$\(GameScene.coins)"
                    UserDefaults.standard.set(1, forKey: "paddle5")
                    paddle5 = 1
                    diagonal.colorBlendFactor = 0
                } else if hoverPaddle == 6 {
                    GameScene.coins = GameScene.coins - 50
                    coins.text = "$\(GameScene.coins)"
                    UserDefaults.standard.set(1, forKey: "paddle6")
                    paddle6 = 1
                    candyCane.colorBlendFactor = 0
                }
                
                let purchaseSound = SKAction.playSoundFileNamed("purchase.mp3", waitForCompletion: false)
                if !AppDelegate.muteSounds { run(purchaseSound) }
                UserDefaults.standard.set(GameScene.coins, forKey: "coins")
                
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node.name == "purchase" && purchase.text == "Purchase" && purchase.alpha == 1.0 {
                purchase.text = "Use"
                
                if hoverPaddle == 2 {
                    StoreScene.selectedPaddle = 2
                } else if hoverPaddle == 3 {
                    StoreScene.selectedPaddle = 3
                } else if hoverPaddle == 4 {
                    StoreScene.selectedPaddle = 4
                } else if hoverPaddle == 5 {
                    StoreScene.selectedPaddle = 5
                } else if hoverPaddle == 6 {
                    StoreScene.selectedPaddle = 6
                }
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
