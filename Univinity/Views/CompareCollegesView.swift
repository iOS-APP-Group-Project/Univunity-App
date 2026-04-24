//
//  CompareCollegesView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import SwiftUI
import ParseSwift

struct CompareCollegesView: View {
    let colleges: [College]

    private let columnWidth: CGFloat = 160

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.10), Color.blue.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Compare Colleges")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Text("Side-by-side view of your selected schools")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colleges, id: \.id) { college in
                                collegeHeaderCard(college)
                            }
                        }
                        .padding(.horizontal)
                    }

                    comparisonSection(
                        title: "Overview",
                        rows: [
                            ("Location", colleges.map { $0.location ?? "N/A" }),
                            ("Type", colleges.map { $0.schoolType ?? "N/A" }),
                            ("Campus Size", colleges.map { $0.size ?? "N/A" })
                        ]
                    )

                    comparisonSection(
                        title: "Admissions",
                        rows: [
                            ("Acceptance Rate", colleges.map { $0.acceptanceRate ?? "N/A" }),
                            ("Minimum GPA", colleges.map { $0.minimumGPA ?? "N/A" })
                        ]
                    )

                    comparisonSection(
                        title: "Cost",
                        rows: [
                            ("Tuition", colleges.map { $0.tuition ?? "N/A" })
                        ]
                    )

                    comparisonSection(
                        title: "Academics",
                        rows: [
                            ("Majors", colleges.map { joinedOrNA($0.majors) }),
                            ("Highlights", colleges.map { joinedOrNA($0.highlights, separator: " • ") })
                        ]
                    )

                    Spacer(minLength: 20)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func collegeHeaderCard(_ college: College) -> some View {
        VStack(spacing: 10) {
            Group {
                if let file = college.logoUrl,
                   let url = file.url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
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
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(college.name ?? "Unknown School")
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text(college.location ?? "N/A")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(width: columnWidth)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
    }

    private func comparisonSection(title: String, rows: [(String, [String])]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    comparisonRow(label: row.0, values: row.1)
                }
            }
            .padding(.horizontal)
        }
    }

    private func comparisonRow(label: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(values.indices, id: \.self) { index in
                        Text(values[index])
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(width: columnWidth, alignment: .leading)
                            .padding(14)
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func joinedOrNA(_ values: [String]?, separator: String = ", ") -> String {
        let joined = (values ?? []).joined(separator: separator)
        return joined.isEmpty ? "N/A" : joined
    }

    private var placeholderImage: some View {
        Image(systemName: "building.columns.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
            .padding(14)
    }
}
