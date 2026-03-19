//
//  CarSelectionView.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import SwiftUI

struct CarSelectionView: View {
    @Binding var selectedCarId: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(CarModel.all) { car in
            Button {
                selectedCarId = car.id
                dismiss()
            } label: {
                HStack(spacing: 16) {
                    // 車のアイコン
                    Text(car.emoji)
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    // 車の情報
                    VStack(alignment: .leading, spacing: 4) {
                        Text(car.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(car.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // 選択状態
                    if car.id == selectedCarId {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("車を選択")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CarSelectionView(selectedCarId: .constant("mini_cooper"))
    }
}
