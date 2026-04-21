//
//  DetailPageView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/03/26.
//

import SwiftUI
import SceneKit
import ElechimCore

struct DetailPageView: View {
    let ARObjectModel: ARObjectModel
    @State private var scene: SCNScene?
    @State private var isSceneLoaded = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @Environment(\.isPreview) var isPreview
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SceneView(scene: scene,
                          options: [.autoenablesDefaultLighting, .allowsCameraControl]
                )
                .ignoresSafeArea()
                .opacity(isSceneLoaded ? 1 : 0)
            }
            
            if !isSceneLoaded && !showError {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    
                    VStack(spacing: 15) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Caricamento della scena...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            
            if showError {
                errorBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: isSceneLoaded)
        .animation(.spring(), value: showError)
        .toolbar {
            ToolbarItem(placement: .principal) {
                glassTitle
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !isPreview {
                loadScene()
            } else {
                errorMessage = "Anteprima non disponibile"
                showError = true
            }
        }
    }
    
    // MARK: - Subviews
    
    private var errorBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 35))
                .foregroundStyle(.orange)
                .symbolEffect(.bounce, value: errorMessage)

            VStack(spacing: 4) {
                Text("Attenzione")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                withAnimation { showError = false }
            } label: {
                Text("Chiudi")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(.primary.opacity(0.1), in: Capsule())
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                )
        }
        .shadow(color: .black.opacity(0.15), radius: 20)
        .padding(40)
    }

    private var glassTitle: some View {
        Text(ARObjectModel.name)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    // MARK: - Logic
    
    private func loadScene() {
        guard scene == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let scene = try SCNScene(url: ARObjectModel.ulrModel)
                self.scene = scene
                withAnimation { self.isSceneLoaded = true }
            } catch {
                self.isSceneLoaded = false
                CustomLog.error(category: .VM, "\(error.localizedDescription)")
                Utils.showError(alertMessage: &errorMessage, showAlert: &showError, from: error)
            }
        }
    }
}

#Preview {
    DetailPageView(ARObjectModel: .init(urlModel: URL(string:"http://www.google.it")!))
}
