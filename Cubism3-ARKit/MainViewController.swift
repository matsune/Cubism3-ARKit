//
//  MainViewController.swift
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

import ARKit
import Foundation
import UIKit
import GLKit

final class MainViewController: GLKViewController {
    
    public var isOpenGLRun = false
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    
    private var glkView: GLKView {
        return view as! GLKView
    }
    
    private var vertexBufferId: GLuint = 0
    private var fragmentBufferId: GLuint = 0
    private var programId: GLuint = 0
    
    private let uv: [GLfloat] = [
        0.0, 1.0,
        1.0, 1.0,
        0.0, 0.0,
        1.0, 0.0
    ]
    
    private var isHiddenFace = false {
        didSet {
            sceneView.isHidden = isHiddenFace
        }
    }
    
    private var model: Cubism3Model?
    
    public func setupCubism() {
        model = Cubism3Model()
        model?.loadAssets("model/Haru/", fileName: "Haru.model3.json")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupOpenGL()
    }
    
    private func setupUI() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        addButton.layer.masksToBounds = false
        addButton.layer.shadowColor = UIColor(white: 0.2, alpha: 1.0).cgColor
        addButton.layer.shadowOpacity = 0.6
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3.5)
        addButton.layer.shadowRadius = 3.5
    }
    
    private func setupOpenGL() {
        isOpenGLRun = true
        guard let ctx = EAGLContext(api: .openGLES2) else {
            fatalError("Failed to init EAGLContext")
        }
        glkView.context = ctx
        EAGLContext.setCurrent(glkView.context)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        glGenBuffers(1, &vertexBufferId)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferId)
        
        glGenBuffers(1, &fragmentBufferId)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), fragmentBufferId)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * uv.count, uv, GLenum(GL_STATIC_DRAW))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        self.resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            let alert = UIAlertController(title: "Device does not support FaceTracking.",
                                          message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let popoverController = segue.destination.popoverPresentationController,
            let button = sender as? UIButton,
            let menuVC = segue.destination as? MenuViewController else {
                return
        }
        popoverController.delegate = self
        popoverController.sourceRect = button.bounds
        
        menuVC.isHiddenFace = isHiddenFace
        menuVC.delegate = self
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        Cubism3Timer.update()
        
        if isOpenGLRun {
            model?.update()
            
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            glClearColor(1.0, 1.0, 1.0, 1.0)
            
            model?.scale(1.0, y: rect.size.width / rect.size.height)
            model?.scaleRelative(4.0, y: 4.0)
            model?.translateY(-0.8)
            model?.draw()
        }
    }
}

extension MainViewController: ARSessionDelegate, ARSCNViewDelegate {
    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        // face angle
        let yaw = atan2(-faceAnchor.transform.columns.2.x, faceAnchor.transform.columns.0.x)
        let roll = atan2(-faceAnchor.transform.columns.1.z, faceAnchor.transform.columns.1.y)
        let pitch = asin(faceAnchor.transform.columns.1.x)
        model?.setParameter(.AngleX, value: -yaw * 40)
        model?.setParameter(.AngleY, value: (roll + 0.4) * 2 * 30)
        model?.setParameter(.AngleZ, value: pitch * 40)
        
        model?.setParameter(.BodyAngleX, value: -yaw * 10)
        model?.setParameter(.BodyAngleY, value: (roll + 0.4) * 2 * 10)
        model?.setParameter(.BodyAngleZ, value: pitch * 10)
        
        model?.setParameter(.BustX, value: -yaw)
        model?.setParameter(.BustY, value: (roll + 0.4) * 2)
        
        // eyeball
        let lookUpL = faceAnchor.blendShapes[.eyeLookUpLeft]!.floatValue
        let lookDownL = faceAnchor.blendShapes[.eyeLookDownLeft]!.floatValue
        let lookInL = faceAnchor.blendShapes[.eyeLookInLeft]!.floatValue
        let lookOutL = faceAnchor.blendShapes[.eyeLookOutLeft]!.floatValue
        let lookUpR = faceAnchor.blendShapes[.eyeLookUpRight]!.floatValue
        let lookDownR = faceAnchor.blendShapes[.eyeLookDownRight]!.floatValue
        let lookInR = faceAnchor.blendShapes[.eyeLookInRight]!.floatValue
        let lookOutR = faceAnchor.blendShapes[.eyeLookOutRight]!.floatValue
        let xEyeL = lookOutL - lookInL
        let xEyeR = lookInR - lookOutR
        let yEyeL = lookUpL - lookDownL
        let yEyeR = lookUpR - lookDownR
        model?.setParameter(.EyeBallX, value: (xEyeL + xEyeR) / 2)
        model?.setParameter(.EyeBallY, value: (yEyeL + yEyeR) / 2)
        
        // eye blink
        let eyeBlinkL = faceAnchor.blendShapes[.eyeBlinkLeft]!.floatValue
        let eyeBlinkR = faceAnchor.blendShapes[.eyeBlinkRight]!.floatValue
        
        // blink invert eyeOpen
        model?.setParameter(.EyeOpenL, value: (eyeBlinkL - 0.5) * -2.0)
        model?.setParameter(.EyeOpenR, value: (eyeBlinkR - 0.5) * -2.0)
        
        let eyeSquintL = faceAnchor.blendShapes[.eyeSquintLeft]!.floatValue
        let eyeSquintR = faceAnchor.blendShapes[.eyeSquintRight]!.floatValue
        model?.setParameter(.EyeSmileL, value: eyeSquintL * 1.4)
        model?.setParameter(.EyeSmileR, value: eyeSquintR * 1.4)
        
        // eye brow
        let innerUp = faceAnchor.blendShapes[.browInnerUp]!.floatValue
        let outerUpL = faceAnchor.blendShapes[.browOuterUpLeft]!.floatValue
        let outerUpR = faceAnchor.blendShapes[.browOuterUpRight]!.floatValue
        let downL = faceAnchor.blendShapes[.browDownLeft]!.floatValue
        let downR = faceAnchor.blendShapes[.browDownRight]!.floatValue
        model?.setParameter(.BrowLY, value: (innerUp + outerUpL) / 2)
        model?.setParameter(.BrowRY, value: (innerUp + outerUpR) / 2)
        model?.setParameter(.BrowLAngle, value: (innerUp - outerUpL + downL) * (2 / 3) - (1 / 3))
        model?.setParameter(.BrowRAngle, value: (innerUp - outerUpR + downR) * (2 / 3) - (1 / 3))
        
        // mouth
        let jawOpen = faceAnchor.blendShapes[.jawOpen]!.floatValue
        model?.setParameter(.MouthOpenId, value: jawOpen)
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MainViewController: MenuViewControllerDelegate {
    func didSelectRestart() {
        resetTracking()
    }
    
    func didChange(isHiddenFace: Bool) {
        self.isHiddenFace = isHiddenFace
    }
}
