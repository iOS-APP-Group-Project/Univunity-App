//
//  CollegesMapView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import SwiftUI
import MapKit
import ParseSwift

struct CollegesMapView: View {
    let colleges: [College]

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.35),
            span: MKCoordinateSpan(latitudeDelta: 35, longitudeDelta: 35)
        )
    )

    @State private var selectedCollege: College?
    @State private var showSavedOnly = false

    @StateObject private var savedViewModel = SavedViewModel()
    @StateObject private var compareViewModel = CompareViewModel()

    private var savedIds: Set<String> {
        Set(savedViewModel.savedColleges.compactMap(\.objectId))
    }

    private var validColleges: [College] {
        colleges.filter { college in
            guard college.latitude != nil, college.longitude != nil else { return false }
            return !showSavedOnly || savedIds.contains(college.objectId ?? "")
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            mapLayer
            floatingControls
            bottomCardLayer
        }
        .navigationTitle("College Map")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            savedViewModel.fetchSavedColleges()
            fitMapToColleges()
        }
        .onChange(of: showSavedOnly) { _ in
            selectedCollege = nil
            fitMapToColleges()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedCollege?.id)
    }

    private var mapLayer: some View {
        Map(position: $position, selection: $selectedCollege) {
            ForEach(validColleges, id: \.id) { college in
                annotationView(for: college)
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .automatic))
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @MapContentBuilder
    private func annotationView(for college: College) -> some MapContent {
        if let lat = college.latitude,
           let lon = college.longitude {
            Annotation(
                college.name ?? "College",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
            ) {
                Button {
                    selectedCollege = college
                    focusOnCollege(college)
                } label: {
                    CollegePinView(
                        college: college,
                        isSelected: selectedCollege?.id == college.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var floatingControls: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()

                VStack(spacing: 10) {
                    Button {
                        showSavedOnly.toggle()
                    } label: {
                        Image(systemName: showSavedOnly ? "heart.fill" : "heart")
                            .font(.headline)
                            .foregroundStyle(showSavedOnly ? .white : .indigo)
                            .frame(width: 44, height: 44)
                            .background(showSavedOnly ? Color.indigo : Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
                    }

                    Button {
                        selectedCollege = nil
                        fitMapToColleges()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .foregroundStyle(.indigo)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()
        }
    }

    @ViewBuilder
    private var bottomCardLayer: some View {
        if let college = selectedCollege {
            SelectedCollegeMapCardView(
                college: college,
                isCompared: compareViewModel.isSelected(college),
                onClose: { selectedCollege = nil },
                onDirections: { openInMaps(college) },
                onCompare: { compareViewModel.toggle(college) }
            )
            .padding(.horizontal)
            .padding(.bottom, 18)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func fitMapToColleges() {
        guard !validColleges.isEmpty else { return }

        let coordinates = validColleges.compactMap { college -> CLLocationCoordinate2D? in
            guard let lat = college.latitude, let lon = college.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        guard let first = coordinates.first else { return }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for coord in coordinates.dropFirst() {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let latDelta = max((maxLat - minLat) * 1.4, 2.5)
        let lonDelta = max((maxLon - minLon) * 1.4, 2.5)

        position = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            )
        )
    }

    private func focusOnCollege(_ college: College) {
        guard let lat = college.latitude, let lon = college.longitude else { return }

        position = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5)
            )
        )
    }

    private func openInMaps(_ college: College) {
        guard let lat = college.latitude, let lon = college.longitude else { return }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = college.name ?? "College"
        mapItem.openInMaps()
    }
}

struct CollegePinView: View {
    let college: College
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: isSelected ? 54 : 46, height: isSelected ? 54 : 46)

                Circle()
                    .stroke(isSelected ? Color.indigo : Color.white, lineWidth: isSelected ? 3 : 2)
                    .frame(width: isSelected ? 54 : 46, height: isSelected ? 54 : 46)

                Group {
                    if let url = college.logoUrl?.url {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure(_):
                                placeholder
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        placeholder
                    }
                }
                .frame(width: isSelected ? 42 : 34, height: isSelected ? 42 : 34)
                .clipShape(Circle())
            }
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)

            Image(systemName: "triangle.fill")
                .font(.caption2)
                .foregroundStyle(isSelected ? .indigo : .white)
                .rotationEffect(.degrees(180))
                .offset(y: -4)
        }
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSelected)
    }

    private var placeholder: some View {
        Image(systemName: "building.columns.fill")
            .resizable()
            .scaledToFit()
            .padding(6)
            .foregroundStyle(.gray)
    }
}

struct SelectedCollegeMapCardView: View {
    let college: College
    let isCompared: Bool
    let onClose: () -> Void
    let onDirections: () -> Void
    let onCompare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            topRow
            statsRow
            actionRow
            secondaryActionRow
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)
    }

    private var topRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if let url = college.logoUrl?.url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure(_):
                            placeholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    placeholder
                }
            }
            .frame(width: 56, height: 56)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(college.name ?? "Unknown School")
                    .font(.headline)
                    .lineLimit(2)

                Text(college.location ?? "Unknown Location")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            infoPill("Tuition", college.tuition ?? "N/A")
            infoPill("GPA", college.minimumGPA ?? "N/A")
            infoPill("Type", college.schoolType ?? "N/A")
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button(action: onDirections) {
                Label("Directions", systemImage: "car.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.indigo)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: onCompare) {
                Image(systemName: isCompared ? "checkmark.circle.fill" : "square.split.2x2")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.7))
                    .foregroundStyle(.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private var secondaryActionRow: some View {
        HStack(spacing: 10) {
            NavigationLink {
                CollegeDetailView(college: college)
            } label: {
                Text("View Details")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.75))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if let website = college.website,
               let url = URL(string: website) {
                Link(destination: url) {
                    Image(systemName: "safari")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.7))
                        .foregroundStyle(.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func infoPill(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var placeholder: some View {
        Image(systemName: "building.columns.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
            .padding(10)
    }
}
