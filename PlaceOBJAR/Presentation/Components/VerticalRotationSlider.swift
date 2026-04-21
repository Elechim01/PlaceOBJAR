//
//  VerticalRotationSlider.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 01/03/26.
//

import SwiftUI
import RealityKit
import ElechimCore

//TODO: remove Bool isAxisZ import 2 rotation
///create GenericVertical and move  the information in the component by super  layer
///for now is this for testing :)

struct VerticalRotationSlider: View {
    @State var rotationAngle: Double = 0
    @State var rotationAngleZ: Double = 0
    
    @State private var visualOffset: CGFloat = 0
    @State private var lastTranslation: CGFloat = 0
    
    private let activeTrackWidth: CGFloat = 250 // La zona dove "vivono" i 360 gradi
    private let backgroundWidth: CGFloat = 270
    private let ratio: Double = 360.0 / 250.0 // 1.44 gradi per pixel
    
    @State private var isAxisZ: Bool = false
    
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("\(  isAxisZ ?  Int(rotationAngleZ) :  Int(rotationAngle))°")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                
                Button {
                    isAxisZ.toggle()
                } label: {
                    Text("\(isAxisZ ? "Z" : "X")")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
            
            ZStack {
                // Sfondo Barra
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: backgroundWidth, height: 50)
                
                IconsElements()
                
                // Cursore Blu (Puntatore)
                Capsule()
                    .fill(Color.blue)
                    .frame(width: 4, height: 35)
                    .shadow(color: .blue.opacity(0.5), radius: 4)
                    .offset(x: visualOffset)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        valueChanged(translation: value.translation)
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            visualOffset = .zero
                            // Commenta questa riga se vuoi che il cursore resti lì
                        }
                    }
            )
            
        }
    }
    
    @ViewBuilder func IconsElements() -> some View {
        HStack(spacing: 0) {
            ForEach(0..<9) { index in
                Rectangle()
                    .fill(index == 4 ? Color.white : Color.white)
                    .frame(width: index == 4 ? 2 : 1, height: index % 2 == 0 ? 25 : 15)
                
                if index < 8 {
                    Spacer().frame(width: 31.25 - (index == 4 ? 2 : 1))
                }
            }
        }
    }
    
    func valueChanged(translation: CGSize) {
        // 1. Calcolo del limite visivo
        let limit = activeTrackWidth / 2
        visualOffset = min(max(translation.width, -limit), limit)
        //= a
        /*
         if value < -limit {
         value = -limit
         } else if value > limit {
         value = limit
         }
         */
        
        // 2. Formula Matematica: Offset -> Angolo
        
        CustomLog.debug(category: .UI, "Offset della visuale \(visualOffset)")
        
        let newAngle = Double(visualOffset) * ratio
        
        // 2. Crea la rotazione (Usa [0,1,0] per ruotare in orizzontale, [1,0,0] per verticale)
        if isAxisZ {
            if newAngle > 0 {
                self.rotationAngleZ = newAngle
            } else {
                self.rotationAngleZ = newAngle + 360
            }
            
            viewModel.rollAngle = newAngle
        } else  {
            if newAngle > 0 {
                self.rotationAngle = newAngle
            } else {
                self.rotationAngle = newAngle + 360
            }
            
            viewModel.verticalAngle = newAngle
        }
        // Feedback aptico al passaggio sulle tacche principali (ogni 45°)
        if Int(newAngle) % 45 == 0 {
            // UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
}

#Preview {
    VerticalRotationSlider()
        .environment(DependecyInjection().makeViewModel())
}
