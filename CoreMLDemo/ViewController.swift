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
		initializeModel()
		coreMLUpdate()
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
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		tapHandler()
	}
	
	func tapHandler() {
		let center = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
		let hitTestResults = sceneView.hitTest(center, types: [.featurePoint])
		
		if let closestPoint = hitTestResults.first {
			let transform = closestPoint.worldTransform
			let worldPosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
			
			let node = createText(for: currentPrediction)
			sceneView.scene.rootNode.addChildNode(node)
			node.position = worldPosition
			
			
		}
	}
	
	func createText(for string: String) -> SCNNode {
		let text = SCNText(string: string, extrusionDepth: 0.01)
		let font = UIFont(name: "AvenirNext-Bold", size: 0.15)
		text.font = font
		text.alignmentMode = kCAAlignmentCenter
		text.firstMaterial?.diffuse.contents = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
		text.firstMaterial?.specular.contents = UIColor.white
		text.firstMaterial?.isDoubleSided = true
		
		let textNode = SCNNode(geometry: text)
		let bounds = text.boundingBox
		textNode.pivot = SCNMatrix4MakeTranslation((bounds.max.x - bounds.min.x)/2, bounds.min.y, 0.005)
		textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
		
		let sphere = SCNSphere(radius: 0.005)
		sphere.firstMaterial?.diffuse.contents = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
		let sphereNode = SCNNode(geometry: sphere)
		
		let billboardConstraint = SCNBillboardConstraint()
		billboardConstraint.freeAxes = SCNBillboardAxis.Y
		
		let parentNode = SCNNode()
		parentNode.addChildNode(textNode)
		parentNode.addChildNode(sphereNode)
		parentNode.constraints = [billboardConstraint]
		
		return parentNode
	}
	
	func initializeModel() {
		guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
			print("Could not load the model")
			return
		}
		
		let classificationRequest = VNCoreMLRequest(model: model, completionHandler: classificationCompletionHandler)
		classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
		visionRequests = [classificationRequest]
	}
	
	func classificationCompletionHandler(request: VNRequest, error: Error?) {
		if error != nil {
			print(error?.localizedDescription as Any)
			return
		}
		
		guard let results = request.results else {
			print("No results")
			return
		}
		
		if let prediction = results.first as? VNClassificationObservation {
			let object = prediction.identifier
			currentPrediction = object
			DispatchQueue.main.async {
				self.predictionLabel.text = self.currentPrediction
			}
		}
	}
	
	func visionRequest() {
		let pixelBuffer = sceneView.session.currentFrame?.capturedImage
		if pixelBuffer == nil {
			return
		}
		let image = CIImage(cvPixelBuffer: pixelBuffer!)
		
		let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
		do {
			try imageRequestHandler.perform(self.visionRequests)
		} catch {
			print(error)
			
		}
	}
	
	func coreMLUpdate() {
		coreMLQueue.async {
			self.visionRequest()
			self.coreMLUpdate()
		}
	}
}
