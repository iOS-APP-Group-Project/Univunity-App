//
//  SwipeCardView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI
import ParseSwift

struct SwipeCardView: View {
    let college: College
    let matchScore: Int
    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)

            VStack(spacing: 14) {
                Group {
                    if let file = college.logoUrl,
                       let url = file.url {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                placeholderImage
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        placeholderImage
                    }
                }
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("Match \(matchScore)%")
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.indigo.opacity(0.10))
                    .foregroundStyle(.indigo)
                    .clipShape(Capsule())

                Text(college.name ?? "Unknown College")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(college.location ?? "Unknown Location")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    statRow("Acceptance Rate", college.acceptanceRate)
                    statRow("Minimum GPA", college.minimumGPA)
                    statRow("Tuition", college.tuition)
                    statRow("Type", college.schoolType)
                    statRow("Campus Size", college.size)

                    if let highlights = college.highlights, !highlights.isEmpty {
                        Text("Highlights: \(highlights.joined(separator: " • "))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(3)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(18)

            HStack {
                Text("NOPE")
                    .font(.system(size: 24, weight: .heavy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 3)
                    )
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(-15))
                    .opacity(offset.width < 0 ? min(abs(offset.width) / CGFloat(100), CGFloat(1)) : 0)

                Spacer()

                Text("LIKE")
                    .font(.system(size: 24, weight: .heavy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 3)
                    )
                    .foregroundColor(.green)
                    .rotationEffect(.degrees(15))
                    .opacity(offset.width > 0 ? min(abs(offset.width) / CGFloat(100), CGFloat(1)) : 0)
            }
            .padding(20)
        }
        .frame(maxHeight: 500)
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(Double(offset.width / CGFloat(20))))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        if offset.width > 120 {
                            HapticsManager.shared.medium()
                            offset.width = 1000
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                onSwipeRight()
                                offset = .zero
                            }
                        } else if offset.width < -120 {
                            HapticsManager.shared.light()
                            offset.width = -1000
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                onSwipeLeft()
                                offset = .zero
                            }
                        } else {
                            offset = .zero
                        }
                    }
                }
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: offset)
    }

    private func statRow(_ label: String, _ value: String?) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .fontWeight(.semibold)
            Spacer()
            Text(value ?? "N/A")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private var placeholderImage: some View {
        Image(systemName: "building.columns.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
            .padding(20)
    }
}
