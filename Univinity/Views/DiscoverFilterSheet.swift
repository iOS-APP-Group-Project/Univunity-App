//
//  DiscoverFilterSheet.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import SwiftUI

struct DiscoverFilterSheet: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.10), Color.blue.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle("Search")

                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)

                                    TextField("Search name, state, city, or major", text: $viewModel.searchText)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .onChange(of: viewModel.searchText) { _ in
                                            viewModel.applyFilters()
                                        }
                                }
                                .padding(14)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }

                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle("School Type")

                                HStack(spacing: 10) {
                                    filterChip("Any", isSelected: viewModel.selectedType == "Any") {
                                        viewModel.selectedType = "Any"
                                        viewModel.applyFilters()
                                    }

                                    filterChip("Public", isSelected: viewModel.selectedType == "Public") {
                                        viewModel.selectedType = "Public"
                                        viewModel.applyFilters()
                                    }

                                    filterChip("Private", isSelected: viewModel.selectedType == "Private") {
                                        viewModel.selectedType = "Private"
                                        viewModel.applyFilters()
                                    }
                                }
                            }
                        }

                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle("Campus Size")

                                HStack(spacing: 10) {
                                    filterChip("Any", isSelected: viewModel.selectedSize == "Any") {
                                        viewModel.selectedSize = "Any"
                                        viewModel.applyFilters()
                                    }

                                    filterChip("Small", isSelected: viewModel.selectedSize == "Small") {
                                        viewModel.selectedSize = "Small"
                                        viewModel.applyFilters()
                                    }

                                    filterChip("Medium", isSelected: viewModel.selectedSize == "Medium") {
                                        viewModel.selectedSize = "Medium"
                                        viewModel.applyFilters()
                                    }

                                    filterChip("Large", isSelected: viewModel.selectedSize == "Large") {
                                        viewModel.selectedSize = "Large"
                                        viewModel.applyFilters()
                                    }
                                }
                            }
                        }

                        sectionCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    sectionTitle("Max Tuition")
                                    Spacer()
                                    Text("$\(Int(viewModel.maxTuition).formatted())")
                                        .font(.headline)
                                        .foregroundStyle(.indigo)
                                }

                                Slider(value: $viewModel.maxTuition, in: 0...90000, step: 1000) {
                                } onEditingChanged: { _ in
                                    viewModel.applyFilters()
                                }

                                HStack {
                                    Text("$0")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("$90,000")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                       
                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle("Actions")

                                Toggle(isOn: $viewModel.showActionButtons) {
                                    Label("Show Swipe Buttons", systemImage: "hand.tap.fill")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .tint(.indigo)
                            }
                        }
                        
                        Button {
                            viewModel.searchText = ""
                            viewModel.selectedType = "Any"
                            viewModel.selectedSize = "Any"
                            viewModel.maxTuition = 80000
                            viewModel.applyFilters()
                        }
                        label: {
                            Text("Reset Filters")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.12))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.indigo : Color.white)
                .foregroundStyle(isSelected ? Color.white : Color.indigo)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.indigo.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
