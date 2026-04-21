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
                    .strokeBorder(
                        LinearGradient(colors: [.cyan, .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 2, dash: [5])
                    )
                    .frame(width: 150, height: 80)
                    .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                    .foregroundStyle(.cyan) // Colore più elettrico
                    .offset(y: 30)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Image(systemName: "arkit")
                    .font(.system(size: 60))
                    .foregroundStyle(.white) // Bianco per staccare dal nero
                    .shadow(color: .blue.opacity(0.8), radius: 15) // Effetto neon
                    .rotation3DEffect(.degrees(isAnimating ? 360: 0), axis: (x: 0, y: 0, z: 1))
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .background {
                        Circle()
                            .fill(Color.blue.opacity(0.3)) // Bagliore di fondo
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                            .scaleEffect(isAnimating ? 1.4 : 0.8)
                    }
            }
            .frame(height: 150)
            
            VStack(spacing: 12) {
                // 3. Testi - Bianco pieno per leggibilità totale
                Text("Cerca una superficie")
                    .font(.title3.bold())
                    .foregroundStyle(.white) // Testo principale brillante
                
                Text("Muovi lentamente il telefono per rilevare l'ambiente circostante.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        ScanningPlaceholder()
            .ignoresSafeArea()
    }
}
