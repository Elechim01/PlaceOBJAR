//
//  HomePageView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 14/03/26.
//

import SwiftUI
import ElechimCore

struct HomePageView: View {
    @Environment(ViewModel.self) var viewModel
    
    @State private var path = NavigationPath()
    @State private var isImporting: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                HomeLayer()
                
                bottomActionButton
            }
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button {
                        isImporting.toggle()
                    } label: {
                        Label("Importa USDZ", systemImage: "plus.circle.fill")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                    }
                    
                }
            })
            .fileImporter(isPresented: $isImporting,
                          allowedContentTypes: [.usdz],
                          onCompletion: viewModel.handleFilePickerImportResult
            )
            .navigationDestination(for: Router.self) { route in
                switch route {
                case .detail(let object):
                    DetailPageView(ARObjectModel: object)
                case .realityScene:
                    RealityPageView()
                        .environment(viewModel)
                    
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
                CustomLog.debug(category: .UI, "Reload View")
                viewModel.reloadView()
            })
        }
    }
    
    // MARK: - Componenti UI
    
    @ViewBuilder
    private  func HomeLayer() -> some View {
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
                                path.append(Router.detail(object))
                            }
                            .contextMenu {
                                if object.isImported {
                                    Button(role: .destructive) {
                                        viewModel.deleteModel(from: object)
                                    } label: {
                                        Label("Elimina modello", systemImage: "trash")
                                    }
                                }
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
            .background(Color.accentColor.gradient)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        
    }
}

#Preview {
    HomePageView()
        .environment(DependecyInjection().makeViewModel())
}


