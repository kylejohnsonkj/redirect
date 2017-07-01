//
//  GameViewController.swift
//  redirect
//
//  Created by Kyle Johnson on 1/2/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import SpriteKit
import GoogleMobileAds
import AVFoundation
import GameKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = StartupScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        
        let skView = view as! SKView
        
        /* DEBUG */
        // skView.showsFPS = true
        // skView.showsNodeCount = true
        // skView.showsPhysics = true
        
        skView.ignoresSiblingOrder = false
        skView.presentScene(scene)
        
        // load data from persistent storage
        loadUserDefaults()
        
        // admob banner ads
        let request = GADRequest()
        bannerView.adUnitID = "ca-app-pub-4550171981441359/8671951621"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        // authenticate player with game center
        authenticateLocalPlayer()
        
        // play background music
        MusicHelper.sharedHelper.playBackgroundMusic()
    }
    
    func loadUserDefaults() {
        
        // show tutorial if first play or update 1.1/1.1.1
        if (((UserDefaults.standard.object(forKey: "tutorial") as? NSInteger) == nil) || ((UserDefaults.standard.object(forKey: "reset1") as? NSInteger) == nil)) {
            GameScene.showTutorial = 0
            UserDefaults.standard.set(GameScene.showTutorial, forKey: "tutorial")
        } else {
            GameScene.showTutorial = 1
            UserDefaults.standard.set(GameScene.showTutorial, forKey: "tutorial")
        }
        
        // version 1.1 top score reset
        if (UserDefaults.standard.object(forKey: "reset1") as? NSInteger) == nil {
            UserDefaults.standard.set(GameScene.highscore, forKey: "highscore")
            UserDefaults.standard.set(1, forKey: "reset1")
        }
        
        // get highscore
        if (UserDefaults.standard.object(forKey: "highscore") as? NSInteger) != nil {
            GameScene.highscore = UserDefaults.standard.object(forKey: "highscore") as! NSInteger
        } else {
            UserDefaults.standard.set(0, forKey: "highscore")
        }
        
        // get coins
        if (UserDefaults.standard.object(forKey: "coins") as? NSInteger) != nil {
            GameScene.coins = UserDefaults.standard.object(forKey: "coins") as! NSInteger
        } else {
            UserDefaults.standard.set(0, forKey: "coins")
        }
        
        // get current paddle
        if (UserDefaults.standard.object(forKey: "selected_paddle") as? NSInteger) != nil {
            StoreScene.selectedPaddle = UserDefaults.standard.object(forKey: "selected_paddle") as! NSInteger
        } else {
            UserDefaults.standard.set(1, forKey: "selected_paddle")
        }
        
        // purchased paddles
        if (UserDefaults.standard.object(forKey: "paddle2") as? NSInteger) == nil {
            UserDefaults.standard.set(0, forKey: "paddle2")
        }
        if (UserDefaults.standard.object(forKey: "paddle3") as? NSInteger) == nil {
            UserDefaults.standard.set(0, forKey: "paddle3")
        }
        if (UserDefaults.standard.object(forKey: "paddle4") as? NSInteger) == nil {
            UserDefaults.standard.set(0, forKey: "paddle4")
        }
        if (UserDefaults.standard.object(forKey: "paddle5") as? NSInteger) == nil {
            UserDefaults.standard.set(0, forKey: "paddle5")
        }
        if (UserDefaults.standard.object(forKey: "paddle6") as? NSInteger) == nil {
            UserDefaults.standard.set(0, forKey: "paddle6")
        }
        
        // sync data
        UserDefaults.standard.synchronize()
    }
    
    func authenticateLocalPlayer() {
        
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            
            if((ViewController) != nil) {
                // show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
                
            } else if (localPlayer.isAuthenticated) {
                // get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboard_id, error) in
                })
                
            } else {
                // game center is not enabled on the users device
                print("Game center disabled.")
            }
        }
    }
    
    class MusicHelper {
        
        static let sharedHelper = MusicHelper()
        var audioPlayer: AVAudioPlayer?
        
        func playBackgroundMusic() {
            let music = NSURL(fileURLWithPath: Bundle.main.path(forResource: "music", ofType: "mp3")!)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                try AVAudioSession.sharedInstance().setActive(true)
                
            } catch let error as NSError {
                print("Problem loading bg music: \(error).")
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: music as URL)
                audioPlayer!.numberOfLoops = -1
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                
            } catch {
                print("Cannot play bg music file.")
            }
        }
        
        func pauseBackgroundMusic() {
            audioPlayer!.stop()
        }
        
        func resumeBackgroundMusic() {
            audioPlayer!.play()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
