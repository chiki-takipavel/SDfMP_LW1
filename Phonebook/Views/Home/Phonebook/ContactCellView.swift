//
//  PhonebookCellView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI

struct ContactListCellView: View {
    
    let asset: PhonebookAsset
    
    var body: some View {
        HStack {
            PhonebookIconView(asset.iconFileData?.downloadURL, 50)
            VStack(alignment: .leading) {
                Text(asset.givenname + " " + asset.lastname)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(asset.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 5)
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
