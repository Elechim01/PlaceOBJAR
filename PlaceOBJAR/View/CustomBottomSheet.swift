//
//  CustomBottomSheet.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/02/26.
//

import SwiftUI

struct CustomBottomSheet: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 40) {
                Text("Segli il tuo oggetto 3D")
                    .font(.title)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .padding()
                .glassEffect(.regular,in: Circle())
                
            }
            .padding(.top, 10)
            
            Text("Seleziona un elemento da inserire nella realtà aumentata")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top,10)
            
            LazyVGrid(columns: [GridItem(),GridItem()]) {
                ForEach(viewModel.object) { object in
                    CustomButton(object3D: object)
                        .environment(viewModel)
                }
            }
        }
    }
}

#Preview {
    SheetPreviewWrapper {
        CustomBottomSheet()
            .environment(ViewModel())
    }
}

extension ProcessInfo {
    static var isRunningInPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
