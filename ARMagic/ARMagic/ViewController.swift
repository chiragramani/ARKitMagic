//
//  ViewController.swift
//  ARMagic
//
//  Created by Chirag Ramani on 31/03/18.
//  Copyright © 2018 Chirag Ramani. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: ARInfoLabel!
    private var dispatchWorkItem: DispatchWorkItem?
    private enum MessageType {
        case moveTheDevice
        case sessionInterrupted
        case sessionInterruptionEnded
        case sessionFailed(error: Error)
        
        /// Message to be displayed in the info label.
        var displayMessage: String {
            switch self {
            case .moveTheDevice:
                return "Hey, Welcome! 👋🏻 \n Lets start by aiming the camera at the floor.👇🏻"
            case .sessionInterruptionEnded:
                return "Session interruption ended"
            case .sessionFailed(let error):
                return "Session failed: \(error.localizedDescription)"
            case .sessionInterrupted:
                return "Session was interrupted"
            }
        }
    }
    private enum InfoDisplayType {
        case `static`
        case hideAfterSeconds(TimeInterval)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSceneView()
    }
    
    private func configureSceneView() {
        // Since we want plane detection which is only supported for ARWorldTrackingConfiguration.
        guard ARWorldTrackingConfiguration.isSupported else {
            showNotSupportedAlert()
            return
        }
        
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
    
    private func showNotSupportedAlert() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Sorry, this feature is not supported on your device.",
                                                preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
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
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
