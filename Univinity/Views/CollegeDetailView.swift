//
//  CollegeD.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI
import ParseSwift
import MapKit

struct CollegeDetailView: View {
    let college: College

    @StateObject private var applicationStore = ApplicationStore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                logoSection

                Text(college.name ?? "Unknown School")
                    .font(.largeTitle.bold())

                detailRow("Location", college.location)
                detailRow("Acceptance Rate", college.acceptanceRate)
                detailRow("Minimum GPA", college.minimumGPA)
                detailRow("Tuition", college.tuition)
                detailRow("Type", college.schoolType)
                detailRow("Campus Size", college.size)

                Text("Highlights")
                    .font(.title3.bold())

                Text((college.highlights ?? []).joined(separator: " • "))
                    .foregroundStyle(.secondary)

                Text("Popular Majors")
                    .font(.title3.bold())

                Text((college.majors ?? []).joined(separator: ", "))
                    .foregroundStyle(.secondary)

                Button {
                    applicationStore.addCollege(college, status: .started)
                    HapticsManager.shared.notifySuccess()
                } label: {
                    Label("Apply", systemImage: "doc.text.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.16))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if let website = college.website,
                   let url = URL(string: website) {
                    Link("Visit Website", destination: url)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if college.latitude != nil && college.longitude != nil {
                    NavigationLink {
                        CollegesMapView(colleges: [college])
                    } label: {
                        Label("View on Map", systemImage: "map.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.14))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var logoSection: some View {
        Group {
            if let file = college.logoUrl,
               let url = file.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure(_):
                        placeholderImage
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func detailRow(_ title: String, _ value: String?) -> some View {
        HStack {
            Text("\(title):")
                .fontWeight(.semibold)

            Spacer()

            Text(value ?? "N/A")
                .foregroundStyle(.secondary)
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "building.columns.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
            .padding(30)
    }
}
