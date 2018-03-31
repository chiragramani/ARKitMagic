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
class ViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: ARInfoLabel!
    private var dispatchWorkItem: DispatchWorkItem?
    private var isMagicHatPlaced = false
    private enum MessageType {
        case moveTheDevice
        case sessionInterrupted
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
        if !isMagicHatPlaced && ARWorldTrackingConfiguration.isSupported {
            displayMessage(type: .moveTheDevice, displayType: .static)
        }
    }
    
    private func configureSceneView() {
        // Since we want plane detection which is only supported for ARWorldTrackingConfiguration.
        guard ARWorldTrackingConfiguration.isSupported else {
            showNotSupportedAlert()
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
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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
}
