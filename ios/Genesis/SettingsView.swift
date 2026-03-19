//
//  SettingsView.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("操作") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("ステアリング感度")
                            Spacer()
                            Text(String(format: "%.2f", settings.steeringSensitivity))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.steeringSensitivity, in: 0.01...0.1, step: 0.01)
                    }
                }

                Section("走行") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("最大速度")
                            Spacer()
                            Text(String(format: "%.2f", settings.maxSpeed))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.maxSpeed, in: 0.05...0.5, step: 0.05)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("加速度")
                            Spacer()
                            Text(String(format: "%.3f", settings.acceleration))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.acceleration, in: 0.001...0.02, step: 0.001)
                    }
                }

                Section {
                    Button("デフォルトに戻す") {
                        settings.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
