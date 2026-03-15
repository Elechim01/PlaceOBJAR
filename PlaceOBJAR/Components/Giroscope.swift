//
//  Giroscope.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 22/02/26.
//

import SwiftUI
import ARKit

struct Giroscope: View {
    
    @Environment(ViewModel.self) var viewModel
    
    let c1_diam: CGFloat = 125
    let c2_diam: CGFloat = 20
    let c3_diam: CGFloat = 50
    
    @State private var fingerOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // C1: Esterno
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: c1_diam, height: c1_diam)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            // C2: Interno (Zona proibita)
            Circle()
                .fill(Color.black)
                .frame(width: c2_diam, height: c2_diam)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            // C3: Pomello (Joystick)
            Circle()
                .fill(.white)
                .frame(width: c3_diam, height: c3_diam)
                .offset(fingerOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            calculatePosition(translation: value.translation)
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                fingerOffset = .zero
                            }
                        }
                )
        }
    }
    
    private func calculatePosition(translation: CGSize){
        let x = translation.width
        let y = translation.height
        
        // Calcoliamo la distanza attuale del dito dal centro
        let currentDistance = sqrt(x*x + y*y)
        
        // Calcolo i limiti basati sui raggi
        let r1 = c1_diam / 2
        let r2 = c2_diam / 2
        let r3 = c3_diam / 2
        
        let minLimit = r2 + r3 // 30
        let maxLimit = r1 - r3 // 35
        
        // Applichiamo il clamping (limite min e max)
        let clampedDistance = max(minLimit, min(currentDistance, maxLimit))
        
        if currentDistance > 0 {
            let factor = clampedDistance / currentDistance
            fingerOffset = CGSize(
                width: x * factor,
                height: y * factor
            )
        } else {
            // Se il dito è esattamente al centro, lo forziamo al limite minimo
            // in una direzione qualsiasi (es. verso l'alto)
            fingerOffset = CGSize(width: 0, height: -minLimit)
        }
        
        
        
        let angle = atan2(translation.height, translation.width)
        viewModel.horizontalAngle = angle
        // let rotation = simd_quatf(angle: Float(angle), axis: [0,1,0])
        
        //    viewModel.homeEntity.transform.rotation *= rotation
        print(angle)
    }
    
}

#Preview {
    Giroscope()
        .environment(ViewModel())
}
