//
//  ContentView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State var viewModel: ViewModel = ViewModel()
    
    @State private var showSheet: Bool = false
    
    // Stati iniziali per gesture
    @State private var initialRotation: simd_quatf?
    @State private var initialScale: SIMD3<Float>?

    @State private var slider: Float = 0.005
/*
    var body: some View {
        VStack {
    
               /* Slider(value: $slider, in: 0.0035...0.1)
                    .onChange(of: slider) { newValue in
                        viewModel.homeEntity.transform.scale = SIMD3<Float>(repeating: newValue)
                    }
                
                Button {
                    viewModel.homeAncor?.removeChild(viewModel.homeEntity)
                } label: {
                    Image(systemName: "trash")
                }
                
                Button {
                    showSheet.toggle()
                } label: {
                    Text("Aggiungi")
                }
                */
            RealityView { content in
                content.camera = .spatialTracking
                
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.2,0.2]))
                
                if let robot = try? await ModelEntity(named: viewModel.object[1].modelName) {
                    robot.name = viewModel.object[1].name
                    robot.generateCollisionShapes(recursive: true)
                    robot.components.set(InputTargetComponent(allowedInputTypes: .all))
                    
                    viewModel.homeEntity = robot
                    anchor.addChild(robot)
                }
                
                content.add(anchor)
                viewModel.homeAncor = anchor
            } update: { content in
                if let robot = content.entities.first(where: { $0.name == viewModel.object[1].name }) {
                    robot.position.y -= 0.1
                }
            } placeholder: {
                VStack {
                    Spacer()
                    Text("Metti il telefono davanti ad un piano")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        // MARK: - Gesture
        .gesture(
            SpatialEventGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    viewModel.homeEntity = value.entity
                    print("Selezionata: \(value.entity.name)")
                }
        )
        // Pinch / Scaling
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    guard let entity = viewModel.homeEntity else { return }
                    if initialScale == nil { initialScale = entity.transform.scale }
                    
                    // Smoothing scaling
                    let targetScale = initialScale! * SIMD3<Float>(repeating: Float(value))
                    let smoothed = simd_mix(entity.transform.scale, targetScale, t: 0.5)
                    
                    entity.transform.scale = simd_clamp(
                        smoothed,
                        SIMD3<Float>(repeating: 0.0035),
                        SIMD3<Float>(repeating: 0.1)
                    )
                }
                .onEnded { _ in initialScale = nil }
        )
        // Drag / Move
        .simultaneousGesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard let parent = viewModel.homeEntity.parent else { return }
                    viewModel.homeEntity.position = value.unproject(value.location, from: .local, to: parent) ?? viewModel.homeEntity.position
                }
        )
        // Rotate
        .simultaneousGesture(
            RotateGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard let entity = viewModel.homeEntity else { return }
                    if initialRotation == nil { initialRotation = entity.transform.rotation }
                    
                    var delta = simd_quatf(angle: Float(value.rotation.radians), axis: [0,1,0])
                    
                    // Optional: detents ogni 15° (~0.2618 rad)
                    let angleInRad = atan2(2*(delta.vector.w*delta.vector.y + delta.vector.x*delta.vector.z),
                                           1 - 2*(delta.vector.y*delta.vector.y + delta.vector.z*delta.vector.z))
                    let step: Float = .pi / 12 // 15°
                    let snapped = round(angleInRad / step) * step
                    delta = simd_quatf(angle: snapped, axis: [0,1,0])
                    
                    // Applica la rotazione accumulata
                    entity.transform.rotation = initialRotation! * delta
                }
                .onEnded { _ in initialRotation = nil }
        )
        // Bottom sheet
        .sheet(isPresented: $showSheet) {
            CustomBottomSheet()
                .environment(viewModel)
        }
    }*/
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                controlPanel
                arView
            }
            Giroscope()
                .environment(viewModel)
            
                .padding(.top)
            
        }
        .sheet(isPresented: $showSheet) {
            CustomBottomSheet()
                .environment(viewModel)
        }
    }
}

// MARK: - Control Panel
private extension ContentView {
    var controlPanel: some View {
        HStack {
           /* Slider(value: $slider, in: 0.0035...0.1)
                .onChange(of: slider) { newValue in
                    viewModel.homeEntity.transform.scale = SIMD3<Float>(repeating: newValue)
                }
            */
            Button {
                viewModel.homeAncor?.removeChild(viewModel.homeEntity)
            } label: {
                Image(systemName: "trash")
            }
            
            Button {
                showSheet.toggle()
            } label: {
                Text("Aggiungi")
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - AR View
private extension ContentView {
    var arView: some View {
        RealityView { content in
            content.camera = .spatialTracking
          await  setupAR(content)
        } update: { content in
            updateAR(content)
        } placeholder: {
            VStack {
                Spacer()
                Text("Metti il telefono davanti ad un piano")
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .gesture(arGestures())
        .gesture(selectEntityGesture())
    }
}

// MARK: - Setup AR
private extension ContentView {
    func setupAR(_ content: RealityViewCameraContent) async {
    
       
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.2,0.2]))
        
        if let robot = try? await ModelEntity(named: viewModel.object[1].modelName) {
            robot.name = viewModel.object[1].name
            robot.generateCollisionShapes(recursive: true)
            robot.components.set(InputTargetComponent(allowedInputTypes: .all))
            
            viewModel.homeEntity = robot
            anchor.addChild(robot)
        }
        
        content.add(anchor)
        viewModel.homeAncor = anchor
    }
    
    func updateAR(_ content: RealityViewCameraContent) {
        if let robot = content.entities.first(where: { $0.name == viewModel.object[1].name }) {
            robot.position.y -= 0.1
        }
    }
}

// MARK: - Gesture Helpers
private extension ContentView {
    
    // Entity selection
    func selectEntityGesture() -> some Gesture {
        SpatialEventGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                viewModel.homeEntity = value.entity
                print("Selezionata: \(value.entity.name)")
            }
    }
    
    // Combined gestures: pinch, rotate, drag
    func arGestures() -> some Gesture {
        // 1. Usa MagnifyGesture (specifico per il 3D) invece di MagnificationGesture
        let pinch = MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged(scaleChanged)
            .onEnded { _ in initialScale = nil }
            
        let rotate = RotateGesture()
            .targetedToAnyEntity()
            .onChanged(rotateChanged)
            .onEnded { _ in initialRotation = nil }
            
        let drag = DragGesture()
            .targetedToAnyEntity()
            .onChanged(dragChanged)
            
        // 2. Usa exclusively per separare pinch e rotate, mantenendo il drag separato
        return pinch.simultaneously(with: rotate)
                    .simultaneously(with: drag)
    }
    
    // MARK: Gesture callbacks
    func scaleChanged(_ value: EntityTargetValue<MagnifyGesture.Value>) {
        // Usiamo l'entità direttamente intercettata dalla gesture
        let entity = value.entity
        
        if initialScale == nil {
            initialScale = entity.transform.scale
        }
        
        // Estraiamo il valore numerico della gesture usando .magnification
        let magnificationFactor = Float(value.magnification)
        
        let newScale = initialScale! * SIMD3<Float>(repeating: magnificationFactor)
        
        entity.transform.scale = simd_clamp(
            newScale,
            SIMD3<Float>(repeating: 0.0035),
            SIMD3<Float>(repeating: 0.1)
        )
    }
    
    func rotateChanged(_ value: EntityTargetValue<RotateGesture.Value>) {
      let entity = viewModel.homeEntity
        if initialRotation == nil { initialRotation = entity.transform.rotation }
        
        let delta = simd_quatf(angle: Float(value.rotation.radians), axis: [0,1,0])
        entity.transform.rotation = initialRotation! * delta
    }
    
    func dragChanged(_ value: EntityTargetValue<DragGesture.Value>) {
        guard let parent = viewModel.homeEntity.parent else { return }
        viewModel.homeEntity.position = value.unproject(value.location, from: .local, to: parent) ?? viewModel.homeEntity.position
    }
}



/* .gesture(SpatialEventGesture()
     .targetedToAnyEntity()
     .onEnded({ value in
         let entity = value.entity
        
         print("Tapped on: \(entity.name)")
     })
 )
 */

 /*.simultaneousGesture(MagnificationGesture()
     .onChanged({ value in
         let delta = Float(value / lastScale)
         print("Delta: \(delta)")
     //Self.Homeentity.transform.scale = SIMD3<Float>(repeating: delta)
       //  self.lastScale = value
 }))
 .simultaneousGesture(RotateGesture().onChanged({ angle in
     let rotation = simd_quatf(angle: Float(angle.rotation.radians),
                               axis: [0,1,0])
     Self.Homeentity.transform.rotation = rotation
 }))
 .gesture(
     DragGesture()
         .targetedToEntity(Self.Homeentity)
         .onChanged { value in
             if let parent = Self.Homeentity.parent {
                 Self.Homeentity.position =
                     value.unproject(value.location,
                                     from: .local,
                                     to: parent) ?? Self.Homeentity.position
             }
         }
 )
  */

enum Interaction {
    case none
    case dragging
    case rotating
}


struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue = false
}
