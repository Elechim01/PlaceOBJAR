//
//  ScanningPlaceholder.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/03/26.
//

import SwiftUI

struct ScanningPlaceholder: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(width: 150, height: 80)
                    .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                    .foregroundStyle(Color.accentColor.opacity(0.5))
                    .offset(y: 30)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Image(systemName: "arkit")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.accentColor)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10)
                    .rotation3DEffect(.degrees(isAnimating ? 360: 0), axis: (x: 0, y: 0, z: 1))
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .background {
                        Circle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                            .scaleEffect(isAnimating ? 1.4 : 0.8)
                    }
                
            }
            .frame(height: 150)
            
            VStack(spacing: 12) {
                Text("Cerca una superficie")
                    .font(.title3.bold())
                
                Text("Muovi lentamente il telefono per rilevare l'ambiente circostante.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
#Preview {
    ScanningPlaceholder()
        .ignoresSafeArea()
}
