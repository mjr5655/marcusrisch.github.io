import SwiftUI
import SceneKit
import UIKit

/// Interactive 3D wine bottle. It turns slowly on its own until you touch it, then you spin it by dragging.
/// Pinch or double-tap to zoom in on the label.
struct BottleSceneView: UIViewRepresentable {
    let shape: BottleShape
    let style: WineStyle
    let labelImage: UIImage?

    func makeCoordinator() -> BottleCoordinator { BottleCoordinator() }

    func makeUIView(context: Context) -> SCNView {
        let coordinator = context.coordinator
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.antialiasingMode = .multisampling4X
        view.scene = coordinator.scene
        view.pointOfView = coordinator.cameraNode
        view.allowsCameraControl = false

        // Any touch stops the idle rotation.
        let touch = UILongPressGestureRecognizer(target: coordinator, action: #selector(BottleCoordinator.handleTouch(_:)))
        touch.minimumPressDuration = 0
        touch.cancelsTouchesInView = false
        touch.delegate = coordinator
        view.addGestureRecognizer(touch)

        let pan = UIPanGestureRecognizer(target: coordinator, action: #selector(BottleCoordinator.handlePan(_:)))
        pan.delegate = coordinator
        view.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: coordinator, action: #selector(BottleCoordinator.handlePinch(_:)))
        pinch.delegate = coordinator
        view.addGestureRecognizer(pinch)

        let doubleTap = UITapGestureRecognizer(target: coordinator, action: #selector(BottleCoordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = coordinator
        view.addGestureRecognizer(doubleTap)

        coordinator.configure(shape: shape, style: style, label: labelImage)
        coordinator.startIdleRotation()
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.configure(shape: shape, style: style, label: labelImage)
    }
}

final class BottleCoordinator: NSObject, UIGestureRecognizerDelegate {
    let scene = SCNScene()
    let cameraNode = SCNNode()
    private let bottleNode = SCNNode()

    private var currentKey = ""
    private var labelMaterial: SCNMaterial?
    private var labelCenterY: CGFloat = 1.0

    private var zoom: CGFloat = 0           // 0 = whole bottle, 1 = close on the label
    private var pinchStartZoom: CGFloat = 0
    private var panStartAngle: Float = 0
    private var hasStartedIdle = false

    private static let farDistance: CGFloat = 7.5
    private static let nearDistance: CGFloat = 3.1
    private static let farCenterY: CGFloat = 1.6

    override init() {
        super.init()
        buildScene()
    }

    // MARK: Scene

    private func buildScene() {
        scene.background.contents = UIColor.clear

        let camera = SCNCamera()
        camera.fieldOfView = 28
        camera.zNear = 0.1
        camera.zFar = 60
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)

        // Warm key light, cool rim light, soft ambient: a dim bar with a lamp over the bottle.
        let key = SCNLight()
        key.type = .directional
        key.color = UIColor(red: 1.0, green: 0.90, blue: 0.74, alpha: 1)
        key.intensity = 900
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.eulerAngles = SCNVector3(-0.45, 0.55, 0)
        scene.rootNode.addChildNode(keyNode)

        let rim = SCNLight()
        rim.type = .directional
        rim.color = UIColor(red: 0.55, green: 0.68, blue: 1.0, alpha: 1)
        rim.intensity = 700
        let rimNode = SCNNode()
        rimNode.light = rim
        rimNode.eulerAngles = SCNVector3(-0.25, Float.pi - 0.7, 0)
        scene.rootNode.addChildNode(rimNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(red: 0.30, green: 0.36, blue: 0.55, alpha: 1)
        ambient.intensity = 260
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        scene.lightingEnvironment.contents = Self.environmentImage()
        scene.lightingEnvironment.intensity = 1.4

        scene.rootNode.addChildNode(bottleNode)
        setZoom(0, animated: false)
    }

    /// Dark studio with a few soft light panels, so the glass has something to reflect.
    private static func environmentImage() -> UIImage {
        let size = CGSize(width: 1024, height: 512)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.22, green: 0.30, blue: 0.50, alpha: 1).cgColor,
                UIColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1).cgColor,
            ] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            UIColor(white: 1, alpha: 0.95).setFill()
            UIBezierPath(roundedRect: CGRect(x: 130, y: 110, width: 70, height: 280), cornerRadius: 35).fill()
            UIBezierPath(roundedRect: CGRect(x: 600, y: 140, width: 50, height: 230), cornerRadius: 25).fill()
            UIColor(red: 1, green: 0.82, blue: 0.55, alpha: 0.9).setFill()
            UIBezierPath(roundedRect: CGRect(x: 830, y: 120, width: 90, height: 260), cornerRadius: 40).fill()
        }
    }

    /// Builds (or rebuilds) the bottle when its shape/style changes, and updates the label texture.
    func configure(shape: BottleShape, style: WineStyle, label: UIImage?) {
        let key = "\(shape.name)-\(style.rawValue)"
        if key != currentKey {
            bottleNode.childNodes.forEach { $0.removeFromParentNode() }
            let built = BottleGeometry.makeBottleNode(shape: shape, style: style)
            built.node.childNodes.forEach { child in
                child.removeFromParentNode()
                bottleNode.addChildNode(child)
            }
            labelMaterial = built.labelMaterial
            labelCenterY = shape.labelCenterY
            currentKey = key
            setZoom(zoom, animated: false)
        }
        if let label {
            labelMaterial?.diffuse.contents = label
            labelMaterial?.emission.contents = label
            labelMaterial?.emission.intensity = 0.35 // lifts the label out of shadow so text stays legible
        } else {
            labelMaterial?.diffuse.contents = UIColor(red: 0.95, green: 0.91, blue: 0.82, alpha: 1)
            labelMaterial?.emission.contents = nil
        }
    }

    // MARK: Idle rotation

    func startIdleRotation() {
        guard !hasStartedIdle else { return }
        hasStartedIdle = true
        let spin = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 30)
        bottleNode.runAction(.repeatForever(spin), forKey: "idle")
    }

    private func stopRotation() {
        bottleNode.removeAllActions()
    }

    // MARK: Zoom

    private func setZoom(_ value: CGFloat, animated: Bool) {
        zoom = min(max(value, 0), 1)
        let distance = Self.farDistance + (Self.nearDistance - Self.farDistance) * zoom
        let height = Self.farCenterY + (labelCenterY - Self.farCenterY) * zoom
        let target = SCNVector3(0, Float(height), Float(distance))
        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.35
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            cameraNode.position = target
            SCNTransaction.commit()
        } else {
            cameraNode.position = target
        }
    }

    // MARK: Gestures

    @objc func handleTouch(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began { stopRotation() }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            stopRotation()
            panStartAngle = bottleNode.eulerAngles.y
        case .changed:
            let dx = Float(gesture.translation(in: gesture.view).x)
            bottleNode.eulerAngles.y = panStartAngle + dx * 0.012
        case .ended, .cancelled:
            // A little momentum so a flick keeps spinning briefly.
            let velocity = Float(gesture.velocity(in: gesture.view).x) * 0.012
            let coast = SCNAction.rotateBy(x: 0, y: CGFloat(velocity * 0.5), z: 0, duration: 0.9)
            coast.timingMode = .easeOut
            bottleNode.runAction(coast, forKey: "coast")
        default:
            break
        }
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            stopRotation()
            pinchStartZoom = zoom
        case .changed:
            setZoom(pinchStartZoom + (gesture.scale - 1) * 0.9, animated: false)
        default:
            break
        }
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        stopRotation()
        setZoom(zoom > 0.5 ? 0 : 1, animated: true)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool { true }
}
