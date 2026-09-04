import StoreKit
import SwiftUI

struct StorefrontView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: StorefrontModel

    init(productIDs: [String]) {
        _model = StateObject(wrappedValue: StorefrontModel(productIDs: productIDs))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("買的是這顆頭的怪味，不是把洗頭紀錄贖回來。")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }

                Section("角色包") {
                    if model.isLoading {
                        ProgressView("正在找角色包…")
                    } else if model.products.isEmpty {
                        Text("目前沒有可購買的角色包。")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.products) { product in
                            productRow(product)
                        }
                    }
                }

                Section {
                    Button("還原購買") {
                        Task { await model.restorePurchases() }
                    }

                    if let message = model.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("角色包")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .fontWeight(.black)
                }
            }
        }
        .task {
            await model.load()
        }
    }

    private func productRow(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if model.entitledProductIDs.contains(product.id) {
                    Text("已擁有")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
            }

            Button(model.entitledProductIDs.contains(product.id) ? "已解鎖" : product.displayPrice) {
                Task { await model.purchase(product) }
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
            .disabled(model.entitledProductIDs.contains(product.id))
        }
        .padding(.vertical, 5)
    }
}
