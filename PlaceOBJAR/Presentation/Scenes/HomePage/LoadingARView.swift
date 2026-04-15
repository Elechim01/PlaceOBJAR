//
//  LoadingARView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/03/26.
//

import SwiftUI

struct LoadingARView: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.down.right.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor.gradient)
                .symbolEffect(.bounce, value: isAnimating)
                .rotation3DEffect(
                    .degrees(isAnimating ? 15 : -15),
                    axis: (x: 1, y: 1, z: 0)
                )
            
            VStack(spacing: 8) {
                Text("Preparazione modelli...")
                    .font(.headline)
                
                Text("Stiamo calibrando le mesh 3D per la tua stanza.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
