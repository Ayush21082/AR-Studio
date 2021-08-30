//
//  FaceMeshViewController.swift
//  AR Guitar
//
//  Created by Ayush Singh on 10/04/21.
//  Copyright © 2021 Tony Morales. All rights reserved.
//
//

import UIKit
import RealityKit
import ARKit
import AVFoundation

@available(iOS 13.0, *)
class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    let headAnchor = AnchorEntity()
    let hipAnchor = AnchorEntity()
    let rightHandAnchor = AnchorEntity()
    let leftHandAnchor = AnchorEntity()
    
    var headBox: Experience.HeadBox!
    var hipBox: Experience.HipsBox!
    var rightHandBox: Experience.RightHandBox!
    var leftHandBox: Experience.LeftHandBox!
    
    var player: AVAudioPlayer?
    var strummed = false
    var label = MessageLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If you get a complaint about ARView not having a member 'session',
        // build to an actual device – not a simulator.
        arView.session.delegate = self
        
        headBox = try! Experience.loadHeadBox()
        hipBox = try! Experience.loadHipsBox()
        rightHandBox = try! Experience.loadRightHandBox()
        leftHandBox = try! Experience.loadLeftHandBox()
        
        arView.scene.addAnchor(headAnchor)
        arView.scene.addAnchor(hipAnchor)
        arView.scene.addAnchor(rightHandAnchor)
        arView.scene.addAnchor(leftHandAnchor)
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        label = MessageLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        label.center = view.center
        label.center.y += 200
        label.textAlignment = .center
        label.text = "Point the camera at someone \na few feet away"
        label.textColor = .white
        label.numberOfLines = 0
        view.addSubview(label)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            guard let headTransform = bodyAnchor.skeleton.modelTransform(for: .head) else { continue }
            guard let hipTransform = bodyAnchor.skeleton.modelTransform(for: .root) else { continue }
            guard let rightHandTransform = bodyAnchor.skeleton.modelTransform(for: .rightHand) else { continue }
            guard let leftHandTransform = bodyAnchor.skeleton.modelTransform(for: .leftHand) else { continue }
            
            let headPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(headTransform.columns.3)
            headAnchor.position = headPosition

            let hipPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(hipTransform.columns.3)
            hipAnchor.position = hipPosition
            
            let rightHandPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(rightHandTransform.columns.3)
            rightHandAnchor.position = rightHandPosition
            
            let leftHandPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(leftHandTransform.columns.3)
            leftHandAnchor.position = leftHandPosition
            
            if headBox.parent == nil {
                headAnchor.addChild(headBox)
                hipAnchor.addChild(hipBox)
                rightHandAnchor.addChild(rightHandBox)
                leftHandAnchor.addChild(leftHandBox)
                
                label.text = """
                Change sounds with left hand placement, strum with right hand
                """
            }
            
            guard leftHandPosition.y - hipPosition.y > 0.1 else { return }
            
            if rightHandPosition.y - hipPosition.y < 0.15 {
                if !strummed {
                    let x = leftHandPosition.x - hipPosition.x
                    if x < 0.13 {
                        playSound(file: "f")
                        label.displayMessage("Playing 8th sound", duration: 2)
                    } else if x < 0.18{
                        playSound(file: "e")
                        label.displayMessage("Playing 7th sound", duration: 2)
                 
                    } else if x < 0.23 {
                        playSound(file: "d")
                        label.displayMessage("Playing 6th sound", duration: 2)
                    } else if x < 0.28{
                        playSound(file: "c")
                        label.displayMessage("Playing 5th sound", duration: 2)
                 
                    } else if x < 0.33 {
                        playSound(file: "4")
                        label.displayMessage("Playing 4th sound", duration: 2)
                    } else if x < 0.38{
                        playSound(file: "3")
                        label.displayMessage("Playing 3rd sound", duration: 2)
                    } else if x < 0.43{
                        playSound(file: "2")
                        label.displayMessage("Playing 2nd sound", duration: 2)
                    } else if x < 0.48{
                        playSound(file: "1")
                        label.displayMessage("Playing 1st sound", duration: 2)
                 
                    }else {
                        playSound(file: "e")
                        label.displayMessage("Playing 0 sound", duration: 2)
                    }

                }
                strummed = true
            } else {
                strummed = false
            }
        }
    }
    
    func playSound(file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else {
            print("Can't grab sound file")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            player?.play()
        } catch {
            print("Whoopsie Doodle")
        }
    }
}
