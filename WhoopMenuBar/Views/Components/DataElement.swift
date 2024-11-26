//
//  DataElement.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.10.24.
//

import SwiftUI

struct DataElement: View {
    var value: String? = nil
    var elementName: String = ""
    var iconName: String
    var iconColor: Color

    var body: some View {
        if value == nil {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(.circular)
        } else {
            VStack {
                HStack (alignment: .center) {
                    Image(systemName: iconName)
                        .foregroundStyle(iconColor)
                        .padding(.trailing, -5)
                    Text(elementName)
                }
                .font(.caption)
                Text(value!)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color(.systemGray))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
        }
        
    }
}

#Preview {
    DataElement(value: "My data", iconName: "star", iconColor: .blue)
        .frame(width: 900)
        .background(.yellow)
}
