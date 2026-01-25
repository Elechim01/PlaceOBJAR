//
//  ContentView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @StateObject var viewModel : ViewModel = ViewModel()
    @State var text: String = "Premi sullo schemrmo"
    @Environment(\.isPreview) var preview
    var body: some View {
        ZStack(alignment: .bottom) {
            if !preview {
                ARViewContainer()
                    .edgesIgnoringSafeArea(.all)
                    .environmentObject(viewModel)
            }
            VStack{
                Text(text)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.taskAddedNotification)) { object in
                        text = object as? String ?? ""
                    }
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack{
                        ForEach(viewModel.object) { object in
                            VStack{
                                CustomButton(object3D: object)
                                    .environmentObject(viewModel)
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 200)
                }
                .background(Color.gray.gradient)
            }
        }
        .ignoresSafeArea()
    }
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue = false
}
