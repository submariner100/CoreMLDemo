//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by Macbook on 13/02/2018.
//  Copyright © 2018 Lodge Farm Apps. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

	@IBOutlet var sceneView: ARSCNView!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var predictionLabel: UILabel!
	
	var currentPrediction = "Empty"
	var visionRequests = [VNRequest]()
	let coreMLQueue = DispatchQueue(label: "com.FarmLodge.coremlqueue")
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
		sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
	
	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
		switch camera.trackingState {
		case .limited(let reason):
			statusLabel.text = "Tracking limited \(reason)"
		case .notAvailable:
			statusLabel.text = "Tracking unavailable"
		case .normal:
			statusLabel.text = "Tap to add a Label"
		}
	}
	
}
