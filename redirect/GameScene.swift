//
//  GameScene.swift
//  redirect
//
//  Created by Kyle Johnson on 1/2/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Paddle: UInt32 = 1
    static let Ball: UInt32 = 2
    static let Target: UInt32 = 4
    static let Boundary: UInt32 = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // game values
    static var score = 0
    static var highscore = 0
    static var coins = 0
    static var showTutorial = 0
    static var isContinued = false
    
    // main sprites
    var paddle = SKSpriteNode()
    var ball = SKSpriteNode()
    var target = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var pausePanel = SKSpriteNode()
    var pausedLabel = SKLabelNode()
    var tutorial = SKSpriteNode()
    let trailNode = SKNode()
    
    // fonts
    let score = SKLabelNode(fontNamed: "Futura Condensed Medium")
    let highscore = SKLabelNode(fontNamed: "Futura Condensed Medium")
    let coins = SKLabelNode(fontNamed: "Futura Medium")
    var countdownLabel = SKLabelNode(fontNamed: "Futura Medium")
    
    // sounds
    let paddleSound = SKAction.playSoundFileNamed("paddle.wav", waitForCompletion: false)
    let targetSound = SKAction.playSoundFileNamed("target.wav", waitForCompletion: false)
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game_over.wav", waitForCompletion: false)
    let beepSound = SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false)
    
    // internal settings
    var ballSpeed = 3.0
    var sizeEquality: CGFloat = 1.0
    var ballSize: CGFloat = 10
    var targetSize: CGFloat = 20
    var paddleSpeed = 1.5
    var rotationStatus = 0
    var coinChance = 0
    var coinPer10 = 0
    var lastPoint: CGPoint = CGPoint(x: 0, y: 0)
    var ballHasHitPaddle = false
    var isCoin = false
    var count = 3
    var continueUsed = false
    
    override func didMove(to view: SKView) {
        
        // lower music volume in-game
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.0
            AppDelegate.muteSounds = true
        } else {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.33
            AppDelegate.muteSounds = false
        }
        
        makeBg()
        
        // reset and load values for new game
        GameScene.score = 0
        GameScene.highscore = UserDefaults.standard.object(forKey: "highscore") as! NSInteger
        GameScene.coins = UserDefaults.standard.object(forKey: "coins") as! NSInteger
        
        // adjust fairness of game in respect to device size
        let screenHeight = self.size.height
        
        if screenHeight < 667 {
            // iPhone 5
            sizeEquality = 0.85
        } else if screenHeight == 667 {
            // iPhone 6/7
            sizeEquality = 1.0
        } else if screenHeight > 667 {
            // iPhone 6+/7+
            sizeEquality = 1.15
        }
        
        setupBoundsAndPhysics()
        addCountdownLabel()
        
        if GameScene.isContinued {
            GameViewController.MusicHelper.sharedHelper.resumeBackgroundMusic()
            GameScene.score = ContinueScene.score
            countdown(count: count)
        }
        
        // continue fail-safe
        if GameScene.score == 0 {
            GameScene.isContinued = false
            ContinueScene.rewardGiven = false
            ContinueScene.watchingVideo = false
        }
        
        setupPaddle()
        spawnRandomBallAndTarget()
        buildScene()
        showTutorialIfNoob()
        
        if GameScene.isContinued {
            pausePanel.isHidden = false
            pauseButton.zPosition = 99
            paddle.removeAllActions()
            countdownLabel.isHidden = false
        }
        
        trailNode.zPosition = 1
        addChild(trailNode)
    }
    
    func addCountdownLabel() {
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .baseline
        countdownLabel.position = CGPoint(x: size.width/2 - 2, y: size.height/2 + size.height/4 - 20)
        countdownLabel.fontColor = .white
        countdownLabel.fontSize = 80
        countdownLabel.text = "\(count)"
        countdownLabel.zPosition = 200
        
        addChild(countdownLabel)
        countdownLabel.isHidden = true
    }
    
    func countdown(count: Int) {
        
        self.physicsWorld.speed = 0
        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                                  SKAction.run(countdownAction)])
        
        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: count),
                               SKAction.run(endCountdown)]))
        
    }
    
    func countdownAction() {
        count -= 1
        if !AppDelegate.muteSounds { run(beepSound) }
        countdownLabel.text = "\(count)"
    }
    
    func endCountdown() {
        self.physicsWorld.speed = 1.0
        countdownLabel.isHidden = true
        pausePanel.isHidden = true
        pauseButton.zPosition = 101
        count = 3
        countdownLabel.text = "\(count)"
    }
    
    func makeBg() {
        
        let background = SKSpriteNode(imageNamed: "bg.png")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size.width = frame.height
        background.size.height = frame.height
        background.zPosition = -1
        addChild(background)
    }
    
    func setupBoundsAndPhysics() {
        
        let bounds = SKPhysicsBody(edgeLoopFrom: self.frame)
        bounds.friction = 0
        bounds.restitution = 0
        bounds.linearDamping = 0
        bounds.angularDamping = 0
        bounds.categoryBitMask = PhysicsCategory.Boundary
        bounds.collisionBitMask = PhysicsCategory.None
        
        self.physicsBody = bounds
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 1.0
    }
    
    func setupPaddle() {
        
        let paddleSize = CGSize(width: 70 * sizeEquality, height: 15 * sizeEquality)
        var selectedPaddle: String? = nil
        
        switch StoreScene.selectedPaddle {
            case 1: selectedPaddle = "whitepaddle"
            case 2: selectedPaddle = "greenstitch"
            case 3: selectedPaddle = "polkadots"
            case 4: selectedPaddle = "yellowtri"
            case 5: selectedPaddle = "diagonal"
            case 6: selectedPaddle = "candycane"
            
            default: print("Failed to read selected paddle.")
        }
        
        paddle = SKSpriteNode(imageNamed: "\(selectedPaddle!).png")
        paddle.position = CGPoint(x: frame.midX, y: frame.midY)
        paddle.size = paddleSize
        paddle.zPosition = 2
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1
        paddle.physicsBody?.linearDamping = 0
        paddle.physicsBody?.angularDamping = 0
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        paddle.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        paddle.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        
        addChild(paddle)
    }
    
    func spawnRandomBallAndTarget() {
        
        var topOrBottom = Int(arc4random_uniform(2))
        ballHasHitPaddle = false
        
        // always spawn ball from top first time
        if GameScene.score < 1 || (GameScene.isContinued == true && !continueUsed) {
            topOrBottom = 0
            continueUsed = true
        }
        
        // coin spawning logic
        if GameScene.score % 10 == 0 {
            coinPer10 = 0
        }
        
        if GameScene.score >= 5 {
            if coinPer10 == 0 {
                coinChance = Int(arc4random_uniform(8))
            } else if coinPer10 == 1 {
                coinChance = Int(arc4random_uniform(10))
            } else {
                coinChance = 0
            }
        } else {
            coinChance = 0
        }
        
        // size calculations for ball and target
        if GameScene.score < 10 {
            ballSize = (12.5 - (CGFloat(GameScene.score) / 4.0)) * sizeEquality
            targetSize = (25.0 - (CGFloat(GameScene.score) / 2.0)) * sizeEquality
        } else {
            ballSize = 10 * sizeEquality
            targetSize = 20 * sizeEquality
        }
        
        if GameScene.score > 100 {
            ballSpeed = 5.5 * Double(sizeEquality)
        } else {
            ballSpeed = (3.0 + (Double(GameScene.score) / 40.0)) * Double(sizeEquality)
        }
        
        switch topOrBottom {
        case 0:
            spawnBallFromTop()
            spawnTargetForTop()
        case 1:
            spawnBallFromBottom()
            spawnTargetForBottom()
        default:
            print("Could not fire ball.")
        }
    }
    
    func spawnBallFromTop() {
        
        ball = SKSpriteNode(imageNamed: "ball.png")
        ball.size = CGSize(width: ballSize * 2, height: ballSize * 2)
        ball.position = CGPoint(x: frame.midX, y: frame.maxY - (ballSize * 2))
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballSize)
        ball.physicsBody?.mass = 0.0139626357704401
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Target | PhysicsCategory.Boundary
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Paddle
        
        addChild(ball)
        
        // shoot ball down
        ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -ballSpeed))
        
        let trail = SKEmitterNode(fileNamed: "BallTrail.sks")!
        trail.targetNode = trailNode
        trail.particleSize = CGSize(width: ballSize * 10, height: ballSize * 10)
        ball.addChild(trail)
    }
    
    func spawnBallFromBottom() {
        
        ball = SKSpriteNode(imageNamed: "ball.png")
        ball.size = CGSize(width: ballSize * 2, height: ballSize * 2)
        ball.position = CGPoint(x: frame.midX, y: frame.minY + (ballSize * 2))
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballSize)
        ball.physicsBody?.mass = 0.0139626357704401
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Target | PhysicsCategory.Boundary
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Paddle
        
        addChild(ball)
        
        // shoot ball up
        ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: ballSpeed))
        
        let trail = SKEmitterNode(fileNamed: "BallTrail.sks")!
        trail.targetNode = trailNode
        trail.particleSize = CGSize(width: ballSize * 10, height: ballSize * 10)
        ball.addChild(trail)
    }
    
    func spawnTargetForTop() {
        
        // coin?
        if coinChance == 1 {
            target = SKSpriteNode(imageNamed: "coin.png")
            isCoin = true
            coinPer10 = coinPer10 + 1
        } else {
            target = SKSpriteNode(imageNamed: "target.png")
            isCoin = false
        }
        
        target.size = CGSize(width: targetSize * 2, height: targetSize * 2)
        target.physicsBody = SKPhysicsBody(circleOfRadius: targetSize)
        target.physicsBody?.friction = 0
        target.physicsBody?.restitution = 1
        target.physicsBody?.linearDamping = 0
        target.physicsBody?.angularDamping = 0
        target.physicsBody?.isDynamic = false
        target.physicsBody?.affectedByGravity = false
        target.physicsBody?.categoryBitMask = PhysicsCategory.Target
        target.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        target.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        
        target.position = randomPointOnUpperCircle(radius: Float(self.size.width / 2 - targetSize * 2), center: CGPoint(x: frame.midX, y: frame.midY))
        
        // keeps target from spawning too close to the previous target
        while (target.position.distanceToPoint(p: lastPoint) < 60 * sizeEquality) || (target.position.x > self.frame.midX - 3 * targetSize && target.position.x < self.frame.midX + 3 * targetSize) {
            target.position = randomPointOnUpperCircle(radius: Float(self.size.width / 2 - targetSize * 2), center: CGPoint(x: frame.midX, y: frame.midY))
        }
//        target.refreshPhysicsBodyAndSetPosition(target.position)
        
        // prints target position when spawned
        if (!isCoin) {
            print(target.position)
        } else {
            print("\(target.position) - COIN")
        }
        
        addChild(target)
        lastPoint = target.position
    }
    
    func spawnTargetForBottom() {
        
        // coin?
        if coinChance == 1 {
            target = SKSpriteNode(imageNamed: "coin.png")
            isCoin = true
            coinPer10 = coinPer10 + 1
        } else {
            target = SKSpriteNode(imageNamed: "target.png")
            isCoin = false
        }
        
        target.size = CGSize(width: targetSize * 2, height: targetSize * 2)
        target.physicsBody = SKPhysicsBody(circleOfRadius: targetSize)
        target.physicsBody?.friction = 0
        target.physicsBody?.restitution = 1
        target.physicsBody?.linearDamping = 0
        target.physicsBody?.angularDamping = 0
        target.physicsBody?.isDynamic = false
        target.physicsBody?.affectedByGravity = false
        target.physicsBody?.categoryBitMask = PhysicsCategory.Target
        target.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        target.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        
        target.position = randomPointOnLowerCircle(radius: Float(self.size.width / 2 - targetSize * 2), center: CGPoint(x: frame.midX, y: frame.midY))
        
        // keeps target from spawning too close to the previous target
        while (target.position.distanceToPoint(p: lastPoint) < 60 * sizeEquality) || (target.position.x > self.frame.midX - 3 * targetSize && target.position.x < self.frame.midX + 3 * targetSize) {
            target.position = randomPointOnLowerCircle(radius: Float(self.size.width / 2 - targetSize * 2), center: CGPoint(x: frame.midX, y: frame.midY))
        }
//        target.refreshPhysicsBodyAndSetPosition(target.position)
        
        // prints target position when spawned
        if (!isCoin) {
            print(target.position)
        } else {
            print("\(target.position) - COIN")
        }
        
        addChild(target)
        lastPoint = target.position
    }
    
    func buildScene() {
        
        score.position = CGPoint(x: frame.minX + 55, y: frame.maxY - 80)
        score.fontColor = .white
        score.fontSize = 70
        score.text = "\(GameScene.score)"
        addChild(score)
        
        highscore.position = CGPoint(x: frame.minX + 55, y: frame.maxY - 117)
        highscore.fontColor = UIColor(red: 89/255, green: 255/255, blue: 0/255, alpha: 1.0)
        highscore.fontSize = 22
        highscore.text = "TOP: \(GameScene.highscore)"
        addChild(highscore)
        
        coins.position = CGPoint(x: frame.maxX - 48, y: frame.maxY - 52)
        coins.fontColor = UIColor(red: 252/255, green: 252/255, blue: 98/255, alpha: 1.0)
        coins.fontSize = 23
        coins.text = "$\(GameScene.coins)"
        addChild(coins)
        
        // setup pause screen
        
        pausePanel = SKSpriteNode(color: .black, size: self.size)
        pausePanel.alpha = 0.55
        pausePanel.zPosition = 100
        pausePanel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(pausePanel)
        
        pausePanel.isHidden = true
        
        pausedLabel = SKLabelNode(fontNamed: "Futura Condensed Medium")
        pausedLabel.position = CGPoint(x: frame.width/2, y: frame.height/2)
        pausedLabel.fontColor = .white
        pausedLabel.fontSize = 50
        pausedLabel.text = "paused"
        pausedLabel.zPosition = 101
        addChild(pausedLabel)
        
        pausedLabel.isHidden = true
        
        pauseButton = SKSpriteNode(imageNamed: "pause.png")
        pauseButton.zPosition = 101
        pauseButton.size = CGSize(width: 50, height: 50)
        pauseButton.position = CGPoint(x: frame.maxX - 47, y: frame.maxY - 98)
        pauseButton.name = "pause"
        addChild(pauseButton)
    }
    
    func showTutorialIfNoob() {
        
        if GameScene.showTutorial == 0  {
            self.physicsWorld.speed = 0
            paddle.removeAllActions()
            tutorial = SKSpriteNode(imageNamed: "tutorial.png")
            tutorial.size.width = self.size.width - 22
            tutorial.size.height = tutorial.size.width * (4/3)
            tutorial.position = CGPoint(x: frame.midX, y: frame.midY)
            tutorial.zPosition = 200
            addChild(tutorial)
            pauseButton.zPosition = 99
            pausePanel.isHidden = false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // ball hits paddle
        if ((firstBody.categoryBitMask & PhysicsCategory.Paddle != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Ball != 0)) {
            ballHasHitPaddle = true
            if !AppDelegate.muteSounds { run(paddleSound) }
        }
        
        // ball hits target (after hitting paddle)
        if (ballHasHitPaddle && (firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Target != 0)) {
            
            if let ball = firstBody.node as? SKSpriteNode {
                if let target = secondBody.node as? SKSpriteNode {

                    GameScene.score = GameScene.score + 1
                    score.text = "\(GameScene.score)"
                    
                    if GameScene.score > GameScene.highscore {
                        highscore.text = "TOP: \(GameScene.score)"
                    }

                    // if target is a coin
                    if isCoin == true {
                        GameScene.coins = GameScene.coins + 1
                        coins.text = "$\(GameScene.coins)"
                        if !AppDelegate.muteSounds { run(coinSound) }
                        
                    } else {
                        if !AppDelegate.muteSounds { run(targetSound) }
                    }

                    // re-draw scene
                    ball.removeFromParent()
                    target.removeFromParent()
                    paddle.removeFromParent()
                    
                    setupPaddle()
                    spawnRandomBallAndTarget()
                }
            }
        }
        
        // ball hits boundary
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Boundary != 0)) {
            
            if !AppDelegate.muteSounds { run(gameOverSound) }
            
            if GameScene.isContinued == false && GameScene.score >= 10 && GameScene.score <= GameScene.highscore && 
                GameScene.coins >= 5 /* only option now */ {
                
                if GameScene.score > GameScene.highscore {
                    GameScene.highscore = GameScene.score
                }

                print("You Lose! Continue?")
                run(SKAction.run() {
                    ContinueScene.score = GameScene.score
                    let reveal = SKTransition.crossFade(withDuration: 0.5)
                    let scene = ContinueScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            } else {
                
                if GameScene.score > GameScene.highscore {
                    GameScene.highscore = GameScene.score
                }
                
                print("You Lose!")
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                    let scene = GameOverScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if GameScene.score > 100 {
                paddleSpeed = 1.2
            } else {
                paddleSpeed = 1.6 - (Double(GameScene.score) / 250.0)
            }
            
            let rotation = SKAction.rotate(byAngle: .pi, duration: paddleSpeed)
            paddle.removeAllActions()
            
            if countdownLabel.isHidden {
                if location.x > self.frame.midX {
                    paddle.run(SKAction.repeatForever(rotation.reversed()))
                } else {
                    paddle.run(SKAction.repeatForever(rotation))
                }
            }

            // check if player taps pause button
            if node.name == "pause" && pausedLabel.isHidden == true {
                self.physicsWorld.speed = 0
                paddle.removeAllActions()
                pausePanel.isHidden = false
                pausedLabel.isHidden = false
            } else if pausedLabel.isHidden == false {
                paddle.removeAllActions()
                countdownLabel.isHidden = false
                pausedLabel.isHidden = true
                pauseButton.zPosition = 99
                countdown(count: count)
            }
            
            if node.name == "main_menu" {
                run(SKAction.run() {
                    let reveal = SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.5)
                    let scene = StartupScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
            
            // hide tutorial when tapped
            if GameScene.showTutorial == 0 {
                GameScene.showTutorial = 1
                UserDefaults.standard.set(GameScene.showTutorial, forKey: "tutorial")
                UserDefaults.standard.synchronize()
                tutorial.removeFromParent()
                paddle.removeAllActions()
                self.physicsWorld.speed = 1.0
                pausePanel.isHidden = true
                pauseButton.zPosition = 101
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // freeze paddle if no more than 1 finger was touching screen
        if (event?.allTouches?.count)! < 2 {
            paddle.removeAllActions()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // silence bg music if user plays own music
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.0
        } else {
            GameViewController.MusicHelper.sharedHelper.audioPlayer?.volume = 0.33
        }
    }
    
    // confusing math
    
    func randomPointOnUpperCircle(radius: Float, center: CGPoint) -> CGPoint {
        // Random angle in [0, 2*pi]
        let theta = Float(arc4random_uniform(UInt32.max))/Float(UInt32.max-1) * .pi
        // Convert polar to cartesian
        let x = radius * cosf(theta)
        let y = radius * sinf(theta)
        return CGPoint(x: Int(CGFloat(x) + center.x), y: Int(CGFloat(y) + center.y))
    }
    
    func randomPointOnLowerCircle(radius: Float, center: CGPoint) -> CGPoint {
        // Random angle in [0, 2*pi]
        let theta = Float(arc4random_uniform(UInt32.max))/Float(UInt32.max-1) * .pi + .pi
        // Convert polar to cartesian
        let x = radius * cosf(theta)
        let y = radius * sinf(theta)
        return CGPoint(x: Int(CGFloat(x) + center.x), y: Int(CGFloat(y) + center.y))
    }
}

extension CGPoint {
    func distanceToPoint(p:CGPoint) -> CGFloat {
        // Equation to get distance between two points.
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}

extension SKSpriteNode {
    func refreshPhysicsBodyAndSetPosition(_ position: CGPoint) {
        /*
         * Weird thing here: if I just set the position of these nodes, they
         * end up at position (0,0). However, if I remove the physics body, set
         * the position, and then re-add the physics body, the nodes are
         * placed correctly.
         */
        let tempPhysicsBody: SKPhysicsBody? = self.physicsBody
        self.physicsBody = nil
        // Position and re-add physics body
        self.position = position
        self.physicsBody = tempPhysicsBody
    }
}
