//
//  DiscoverFiltersView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import SwiftUI

struct DiscoverFiltersView: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search colleges", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .onChange(of: viewModel.searchText) { _ in
                viewModel.applyFilters()
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Type")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Picker("Type", selection: $viewModel.selectedType) {
                        Text("Any").tag("Any")
                        Text("Public").tag("Public")
                        Text("Private").tag("Private")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: viewModel.selectedType) { _ in
                        viewModel.applyFilters()
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Size")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Picker("Size", selection: $viewModel.selectedSize) {
                        Text("Any").tag("Any")
                        Text("Small").tag("Small")
                        Text("Medium").tag("Medium")
                        Text("Large").tag("Large")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: viewModel.selectedSize) { _ in
                        viewModel.applyFilters()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Max Tuition")
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Text("$\(Int(viewModel.maxTuition).formatted())")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.indigo)
                }

                Slider(value: $viewModel.maxTuition, in: 0...90000, step: 1000) {
                } onEditingChanged: { _ in
                    viewModel.applyFilters()
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}
