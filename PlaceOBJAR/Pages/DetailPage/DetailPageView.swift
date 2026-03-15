//
//  DetailPageView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/03/26.
//

import SwiftUI
import SceneKit

struct DetailPageView: View {
    let objcModel: OBJCModel
    @State private var scene: SCNScene?
    @State private var isSceneLoaded = false
    @Environment(\.isPreview) var isPreview
    var body: some View {
        ZStack {
            if let scene = scene {
                SceneView(scene: scene,
                          options: [.autoenablesDefaultLighting,
                                    .allowsCameraControl]
                )
                .ignoresSafeArea()
                .opacity(isSceneLoaded ? 1 : 0) // Parte invisibile
                .animation(.easeIn(duration: 0.5), value: isSceneLoaded)
            } else {
                ZStack {
                    // Uno sfondo leggermente sfocato per preparare l'occhio
                    Color.gray.opacity(0.05).ignoresSafeArea()
                    
                    // La bolla di caricamento
                    VStack {
                        ProgressView(label: {
                            Text("Caricamento della scena in corso...")
                        }, )
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        )
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                glassTitle
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !isPreview {
                loadScene()
            }
        }
    }
    
    private var glassTitle: some View {
        Text(objcModel.name)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
    }
    
    private func loadScene() {
        guard scene == nil else { return }
        Task {
            let scene =  SCNScene(named: objcModel.modelName)
            await MainActor.run {
                self.scene = scene
                withAnimation {
                    self.isSceneLoaded = true
                }
                
            }
        }
    }
}

#Preview {
    DetailPageView(objcModel: .init(urlModel: URL(string:"http://www.google.it")!))
}
