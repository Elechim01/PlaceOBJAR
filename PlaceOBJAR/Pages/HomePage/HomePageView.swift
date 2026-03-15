//
//  HomePageView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 14/03/26.
//

import SwiftUI

struct HomePageView: View {
    @Environment(ViewModel.self) var viewModel
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                HomeLayer()
                
                bottomActionButton
            }
            .navigationTitle("Home")
            .navigationDestination(for: Router.self) { route in
                switch route {
                case .detail(let object):
                    DetailPageView(objcModel: object)
                case .realityScene:
                    RealityPageView()
                        .environment(viewModel)
                    
                }
            }
        }
    }
    
    // MARK: - Componenti UI
    
    @ViewBuilder
    func HomeLayer() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Benvenuto")
                        .font(.largeTitle.bold())
                    
                    Text("Esplora la collezione di oggetti 3D e portali nel tuo mondo.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if viewModel.isImagesReady {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.objects) { object in
                            CustomButton(object3D: object) {
                                // GO TO Detail Scene
                                path.append(Router.detail(object))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                    
                } else {
                    LoadingARView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private var bottomActionButton: some View {
        Button {
            // GO TO Reality Scene
            path.append(Router.realityScene)
        } label: {
            HStack {
                Image(systemName: "arkit")
                Text("Avvia Esperienza AR")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.accentColor.gradient) // Gradiente automatico
            .clipShape(Capsule()) // Forma a capsula più moderna
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    HomePageView()
        .environment(ViewModel())
}


