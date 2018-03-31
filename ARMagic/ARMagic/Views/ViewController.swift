//
//  ViewController.swift
//  ARMagic
//
//  Created by Chirag Ramani on 31/03/18.
//  Copyright © 2018 Chirag Ramani. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    /// IBOutlets.
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var magicButton: UIButton!
    @IBOutlet weak var infoLabel: ARInfoLabel!
    @IBOutlet weak var throwBallButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    private var dispatchWorkItem: DispatchWorkItem?
    private var isMagicHatPlaced = false
    private enum MessageType {
        case moveTheDevice
        case sessionInterrupted
        case featureNotSupported
        case tapThrowBall
        case sessionInterruptionEnded
        case sessionFailed(error: Error)
        
        /// Message to be displayed in the info label.
        var displayMessage: String {
            switch self {
            case .moveTheDevice:
                return "Hey, Welcome! 👋🏻 \nLets start by aiming the camera at the floor.👇🏻"
            case .sessionInterruptionEnded:
                return "Session interruption ended"
            case .sessionFailed(let error):
                return "Session failed: \(error.localizedDescription)"
            case .sessionInterrupted:
                return "Session was interrupted"
            case .tapThrowBall:
                return "Tap on \"Throw Ball\" to throw ball in the hat."
            case .featureNotSupported:
                return "Sorry 😔, \nThis feature is not supported on your device."
            }
        }
    }
    
    private enum InfoDisplayType {
        case `static`
        case hideAfterSeconds(TimeInterval)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSceneView()
        if !isMagicHatPlaced && ARWorldTrackingConfiguration.isSupported {
            displayMessage(type: .moveTheDevice, displayType: .static)
        }
    }
    
    private func configureButtons() {
        throwBallButton.layer.cornerRadius = 6
        magicButton.layer.cornerRadius = 6
    }
    
    private func configureSceneView() {
        // Since we want plane detection which is only supported for ARWorldTrackingConfiguration.
        guard ARWorldTrackingConfiguration.isSupported else {
            displayMessage(type: .featureNotSupported, displayType: .static)
            return
        }
        
        // Setting scene view's delegate.
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [])
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func displayMessage(type: MessageType, displayType: InfoDisplayType) {
        dispatchWorkItem?.cancel()
        infoLabel.text = type.displayMessage
        infoLabel.isHidden = false
        switch displayType {
        case .static: break
        case .hideAfterSeconds(let seconds):
            dispatchWorkItem = DispatchWorkItem(block: {
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
                    self?.infoLabel.isHidden = true
                })
            })
            dispatchWorkItem?.perform()
        }
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func didTapOnMagicButton(_ sender: Any) {
    }
    
    
    @IBAction func didTapOnThrowButton(_ sender: Any) {
        guard let scene = SCNScene(named: "Ball.scn", inDirectory: "art.scnassets"),
        let ballNode = scene.rootNode.childNode(withName: "ball", recursively: false),
        let currentTransform = sceneView.session.currentFrame?.camera.transform else { return }
        ballNode.simdTransform = currentTransform
        sceneView.scene.rootNode.addChildNode(ballNode)
        let force = simd_mul(currentTransform, simd_make_float4(0, 0, -2, 0))
        /// Applying force.
        ballNode.physicsBody?.applyForce(SCNVector3Make(force.x, force.y, force.z), asImpulse: true)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        displayMessage(type: .sessionFailed(error: error), displayType: .hideAfterSeconds(5))
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        displayMessage(type: .sessionInterrupted, displayType: .hideAfterSeconds(3))
        resetTracking()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        displayMessage(type: .sessionInterruptionEnded, displayType: .hideAfterSeconds(3))
        resetTracking()
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor, let hatNode = hatNodeForAnchor(anchor)  else { return }
        node.addChildNode(hatNode)
        /// Showing Magic and Throw ball options.
        DispatchQueue.main.async { [weak self] in
            self?.buttonsStackView.isHidden = false
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate,
            let node = sceneView.scene.rootNode.childNode(withName: "omni", recursively: true) else { return }
        node.light?.intensity = lightEstimate.ambientIntensity
    }
    
    private func hatNodeForAnchor(_ anchor: ARPlaneAnchor) -> SCNNode? {
        guard !isMagicHatPlaced,
            let scene = SCNScene(named: "MagicHat.scn", inDirectory: "art.scnassets"),
            let node = scene.rootNode.childNode(withName: "magicHat", recursively: false) else { return nil }
        node.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        DispatchQueue.main.async { [weak self] in
            self?.displayMessage(type: .tapThrowBall, displayType: .hideAfterSeconds(4))
        }
        isMagicHatPlaced = true
        return node
    }
}
