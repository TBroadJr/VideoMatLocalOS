//
//  ContentView.swift
//  VideoMatLocalOS
//
//  Created by Tornelius Broadwater, Jr on 11/22/22.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        spawnTV(in: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func spawnTV(in arView: ARView) {
        
        // width by thickness by height
        // unit is meters
        let dimentions: SIMD3<Float> = [1.23, 0.046, 0.7]
        
        // Create Tv Housing
        let housingMesh = MeshResource.generateBox(size: dimentions)
        let housingMat = SimpleMaterial(color: .black, roughness: 0.4, isMetallic: false)
        let housingEntity = ModelEntity(mesh: housingMesh, materials: [housingMat])
        
        // Create TV Screen Plane
        let screenMesh = MeshResource.generatePlane(width: dimentions.x, depth: dimentions.z)
        let screenMat = SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)
        let screenEntity = ModelEntity(mesh: screenMesh, materials: [screenMat])
        screenEntity.name = "tvScreen"
        
        // Add TV Screen to Housing
        housingEntity.addChild(screenEntity)
        
        // Sets the screen entity on top of the housing entity because by default its set in the middle which can cause glitching
        screenEntity.setPosition([0, dimentions.y/2 + 0.001, 0], relativeTo: housingEntity)
        
        // Create anchor to place tv on wall
        let anchor = AnchorEntity(plane: .vertical)
        anchor.addChild(housingEntity.clone(recursive: true))
        arView.scene.addAnchor(anchor)
            
        arView.enableTapGesture()
        housingEntity.generateCollisionShapes(recursive: true)
    }
}

extension ARView {
    func enableTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "tvScreen" {
            loadVideoMaterial(for: entity)
        }
    }
    
    func loadVideoMaterial(for entity: ModelEntity) {
        let asset = AVAsset(url: Bundle.main.url(forResource: "DemoVideo", withExtension: "mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer()
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
