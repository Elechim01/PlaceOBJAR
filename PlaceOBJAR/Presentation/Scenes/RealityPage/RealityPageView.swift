//
//  RealityPageView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/03/26.
//

import SwiftUI
import RealityKit
import ARKit
import ElechimCore

struct RealityPageView: View {
    
    @Environment(ViewModel.self) var viewModel
    @State private var showSheet: Bool = false
    @State private var slider: Float = 0.005
    @Environment(\.isPreview) var isPreview
    
    
    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack() {
            if !isPreview {
                ArCustomView()
                    .ignoresSafeArea()
            }
            if !viewModel.isTrackingPlane {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    ScanningPlaceholder()
                }
                .transition(.opacity)
            }
            
            
            if viewModel.isTrackingPlane {
                HStack {
                    VerticalRotationSlider()
                        .environment(viewModel)
                    
                    Giroscope()
                        .environment(viewModel)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding()
            }
        }
        .toolbar(content: {
            ControlPannel()
                .frame(maxWidth: .infinity)
        })
        .alert(viewModel.errorMessage, isPresented: $viewModel.showError, actions: {
            Button {
                viewModel.showError.toggle()
            } label: {
                Text("OK")
            }
            
        })
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet) {
            CustomBottomSheet()
                .environment(viewModel)
        }
    }
    
    @ViewBuilder
    private func ControlPannel() -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring()) {
                        viewModel.deleteEntity()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.red)
                }
                .padding(.leading,5)
                
                Button {
                    showSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                if !viewModel.homeEntity.availableAnimations.isEmpty {
                    Button {
                        viewModel.buttonPlayPauseAction()
                    } label: {
                        Image(systemName: viewModel.controllersIsPlay ? "play" : "pause")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.trailing, 15)
            
            Rectangle()
                .fill(.primary.opacity(0.15))
                .frame(width: 1, height: 20)
            
            if !viewModel.homeEntity.name.isEmpty || isPreview {
                Text(isPreview ? "Un Nome Di Un'Entità Molto Lungo Per Test" : viewModel.homeEntity.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 15)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func ArCustomView() -> some View {
        RealityView { content in
            content.camera = .spatialTracking
            await  viewModel.setupAR(content)
        } update: { content in
            // SwiftUI state → RealityKit scene es colori ecc no Gesture
            print("showSheet -> \(showSheet)")
            viewModel.updateAR(content)
        } placeholder: {
            ScanningPlaceholder()
        }
        .gesture(viewModel.arGestures())
        .gesture(viewModel.selectEntityGesture())
    }
    
}

#Preview {
    NavigationStack {
        RealityPageView()
            .environment(DependecyInjection().makeViewModel())
    }
}
