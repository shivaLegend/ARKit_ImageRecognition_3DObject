//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jayven Nhan on 3/20/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
  
  //MARK: - Variable animation
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    var isSceneMumhammed = false
  
  //MARK: - Variable duration
    let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 5
    let waitDuration: TimeInterval = 0.5
    
    lazy var fadeAndSpinAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration),
            .rotateBy(x: 0, y: CGFloat.pi * 360 / 180, z: 0, duration: rotateDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    lazy var fadeAction: SCNAction = {
        return .sequence([
            .fadeOpacity(by: 0.8, duration: fadeDuration),
            .wait(duration: 15),
            .fadeOut(duration: waitDuration)
            ])
    }()
    
    lazy var treeNode: SCNNode = {
        guard let scene = SCNScene(named: "tree.scn"),
            let node = scene.rootNode.childNode(withName: "tree", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.005
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        return node
    }()
    
    lazy var bookNode: SCNNode = {
        guard let scene = SCNScene(named: "book.scn"),
            let node = scene.rootNode.childNode(withName: "book", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = +.pi/2
        return node
    }()
    
    lazy var mountainNode: SCNNode = {
        guard let scene = SCNScene(named: "mountain.scn"),
            let node = scene.rootNode.childNode(withName: "mountain", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.25
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x += -.pi / 2
        return node
    }()
  
    lazy var shipNode: SCNNode = {
    guard let scene = SCNScene(named: "ship.scn"),
      let node = scene.rootNode.childNode(withName: "ship", recursively: false) else { return SCNNode() }
    let scaleFactor  = 0.5
    node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
    node.eulerAngles.x += -.pi / 2
    return node
    }()
  
  
  
  lazy var rocketshipNode: SCNNode = {
    guard let scene = SCNScene(named: "rocketship.scn"),
      let node = scene.rootNode.childNode(withName: "rocketship", recursively: false) else { return SCNNode() }
    let scaleFactor  = 0.02
    node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
//    node.eulerAngles.x += -.pi / 2
    return node
  }()
  
  lazy var chickenNode: SCNNode = {
    guard let scene = SCNScene(named: "chicken.scn"),
      let node = scene.rootNode.childNode(withName: "chicken", recursively: false) else { return SCNNode() }
    let scaleFactor  = 0.2
    node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
    node.eulerAngles.x += -.pi / 2
    return node
  }()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
    }
    
    func resetTrackingConfiguration() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        label.text = "Move camera around to detect images"
    }
  
  //MARK: -Create animation muhammed
  //MARK: - Animate 3d object
  func loadAnimations (imageAnchor: ARImageAnchor) {
    // Load the character in the idle animation
    let idleScene = SCNScene(named: "art.scnassets/goast/idleFixed.dae")!
    
    // This node will be parent of all the animation models
    let node = SCNNode()
    
    // Add all the child nodes to the parent node
    for child in idleScene.rootNode.childNodes {
      node.addChildNode(child)
    }
    
    // 2. Calculate size based on planeNode's bounding box.
    let (min, max) = node.boundingBox
    let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
    
    // 3. Calculate the ratio of difference between real image and object size.
    // Ignore Y axis because it will be pointed out of the image.
    let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
    let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
    // Pick smallest value to be sure that object fits into the image.
    let finalRatio = [widthRatio, heightRatio].min()!
    
    // 4. Set transform from imageAnchor data.
    node.transform = SCNMatrix4(imageAnchor.transform)
    
    // 5. Animate appearance by scaling model from 0 to previously calculated value.
    let appearanceAction = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.4)
    appearanceAction.timingMode = .easeOut
    // Set initial scale to 0.
    node.scale = SCNVector3Make(0.001, 0.001, 0.001)
    // Add to root node.
    sceneView.scene.rootNode.addChildNode(node)
    // Run the appearance animation.
    node.runAction(appearanceAction)

    

    node.runAction(fadeAction)
    
    // Load all the DAE animations
    loadAnimation(withKey: "dancing", sceneName: "art.scnassets/goast/sambaFixed", animationIdentifier: "sambaFixed-1")
  }
  
  func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
    let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
    let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
    
    if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
      // The animation will only play once
      animationObject.repeatCount = 1
      // To create smooth transitions between animations
      animationObject.fadeInDuration = CGFloat(1)
      animationObject.fadeOutDuration = CGFloat(0.5)
      
      // Store the animation for later use
      animations[withKey] = animationObject
    }
  }
  
  //MARK: - Touched scene view
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let location = touches.first!.location(in: sceneView)
    
    
    // Let's test if a 3D Object was touch
    var hitTestOptions = [SCNHitTestOption: Any]()
    hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
    
    let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
    
    if hitResults.first != nil && isSceneMumhammed == true {
      if(idle) {
        playAnimation(key: "dancing")
      } else {
        stopAnimation(key: "dancing")
      }
      idle = !idle
      return
    }
  }
  
  func playAnimation(key: String) {
    // Add the animation to start playing it right away
    sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
  }
  
  func stopAnimation(key: String) {
    // Stop the animation with a smooth transition
    sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
  }
}

//MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let imageAnchor = anchor as? ARImageAnchor,
                let imageName = imageAnchor.referenceImage.name else { return }
            print(imageAnchor.referenceImage.physicalSize)
            // TODO: Comment out code
            //            let planeNode = self.getPlaneNode(withReferenceImage: imageAnchor.referenceImage)
            //            planeNode.opacity = 0.0
            //            planeNode.eulerAngles.x = -.pi / 2
            //            planeNode.runAction(self.fadeAction)
            //            node.addChildNode(planeNode)
            
            // TODO: Overlay 3D Object
          if imageName == "Muhammed" {
            self.loadAnimations(imageAnchor: imageAnchor)
            self.isSceneMumhammed = true
          } else {
            let overlayNode = self.getNode(withImageName: imageName)
//            overlayNode.opacity = 0
            overlayNode.position.y = 0.05
//            overlayNode.runAction(self.fadeAndSpinAction)
            node.addChildNode(overlayNode)
            self.isSceneMumhammed = false
          }
          self.label.text = "Image detected: \"\(imageName)\""
        }
    }
    
    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
        switch name {
        case "Book":
            node = bookNode
        case "Snow Mountain":
            node = mountainNode
        case "Trees In the Dark":
            node = treeNode
        case "Ship":
            node = shipNode
        case "Rocketship":
          node = rocketshipNode
        case "Chicken":
          node = chickenNode
        default:
            break
        }
        return node
    }
    
}

