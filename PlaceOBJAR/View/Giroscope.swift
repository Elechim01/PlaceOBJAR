//
//  Giroscope.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 22/02/26.
//

import SwiftUI
import ARKit

struct Giroscope: View {
    
    @State private var fingerOffset: CGSize = .zero
    
    private let circleDimension: CGFloat = 150
    private let joisticDimension: CGFloat = 50
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        ZStack {
            Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: circleDimension, height: circleDimension)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            Circle()
                .fill(.white)
                .frame(width: joisticDimension,height: joisticDimension)
                .offset(fingerOffset)
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            let translation  = value.translation
                            let spaceToMove = (circleDimension - joisticDimension) / 2
                            
                            let distance = sqrt(pow(translation.width, 2) +  pow(translation.height, 2) )

                            
                            if distance < spaceToMove {
                                fingerOffset = translation
                            } else {
                                let offset =  spaceToMove / distance
                                fingerOffset = CGSize(width: translation.width * offset,
                                                      height: translation.height * offset)
                            }
                           let angle = atan2(translation.height, translation.width)
                           
                            let rotation = simd_quatf(angle: Float(angle), axis: [0,1,0])
                            
                            viewModel.homeEntity.transform.rotation = rotation
                            print(angle)
                        })
                        .onEnded({ _ in
                            withAnimation {
                                fingerOffset = .zero
                            }
                        })
                )
        }
    }
}

#Preview {
    Giroscope()
        .environment(ViewModel())
}
