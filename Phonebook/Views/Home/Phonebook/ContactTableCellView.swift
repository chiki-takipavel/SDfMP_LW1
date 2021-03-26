//
//  PhonebookTableCellView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 26.03.21.
//

import SwiftUI

struct ContactTableCellView: View {
    
    let asset: PhonebookAsset
    
    var body: some View {
        VStack {
            PhonebookIconView(asset.iconFileData?.downloadURL, 50)
            Text(asset.givenname + " " + asset.lastname)
                .multilineTextAlignment(.center)
            Text(asset.phone)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .font(.system(size: 12))
            Spacer()
            Image(systemName: "arrow.right")
                .imageScale(.small)
                .foregroundColor(.secondary)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.uiCornerRadius)
                .stroke(Color.blue.opacity(0.8), lineWidth: 3)
        )
    }
}
