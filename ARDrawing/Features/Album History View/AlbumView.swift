//
//  AlbumView.swift
//  ARDrawing
//


import CoreData
import SwiftUI

// MARK: - Model

/// Sketches bucketed under the day-header they were saved on, newest first.
private struct AlbumSection: Identifiable {
    let date: Date
    let sketches: [SavedSketch]
    var id: Date { date }
}

// MARK: - View

struct AlbumView: View {
    @Environment(\.dismiss) private var dismiss
    /// Drives the sliding highlight between "Drawn Image" and "Recorded".
    @Namespace private var tabAnimation

    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedSketch.createdAt, ascending: false)]
    )
    private var sketches: FetchedResults<SavedSketch>

    @State private var selectedTab: AlbumTab = .drawn
    @State private var selectedIDs: Set<NSManagedObjectID> = []

    private let pageMargin: CGFloat = 20

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var visibleSketches: [SavedSketch] {
        sketches.filter { $0.kind == selectedTab.storageKind }
    }

    private var sections: [AlbumSection] {
        let grouped = Dictionary(grouping: visibleSketches) {
            Calendar.current.startOfDay(for: $0.createdAt ?? Date())
        }
        return grouped
            .map { AlbumSection(date: $0.key, sketches: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private var allSelected: Bool {
        !visibleSketches.isEmpty && selectedIDs.count == visibleSketches.count
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            tabPicker
                .padding(.top, 14.h)
                .padding(.horizontal, pageMargin.w)

            ZStack(alignment: .bottom) {
                ReportingScrollView {
                    LazyVStack(alignment: .leading, spacing: 20.h) {
                        if sections.isEmpty {
                            emptyState
                        } else {
                            ForEach(sections) { section in
                                sectionView(section)
                            }
                        }
                    }
                    .padding(.horizontal, pageMargin.w)
                    .padding(.top, 16.h)
                    .padding(.bottom, selectedIDs.isEmpty ? 16.h : 96.h)
                }

                if !selectedIDs.isEmpty {
                    deleteBar
                }
            }
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: Header
    /// Sits on its own white plate that reaches up under the status bar and
    /// rounds off only at the bottom, matching the Figma nav bar.

    private var header: some View {
        HStack(spacing: 8.w) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8.w) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15.s, weight: .bold))

                    Text(LocalizedKey.albumNavTitle.localized)
                        .font(.app(.paytoneOne, size: 24))
                }
                .foregroundStyle(Color(app: .dark))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8.w)

            selectAllButton
        }
        .padding(.horizontal, pageMargin.w)
        .padding(.top, 14.h)
        .padding(.bottom, 16.h)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 22.s,
                bottomTrailingRadius: 22.s,
                topTrailingRadius: 0,
                style: .continuous
            )
            .fill(Color(app: .white))
            .ignoresSafeArea(edges: .top)
        )
    }

    /// Flips to "Deselect all" — icon, label and tint — once every
    /// drawing is already selected, so the pill always states the action
    /// tapping it will take next.
    private var selectAllButton: some View {
        let tint: AppColor = allSelected ? .accent : .dark

        return Button {
            toggleSelectAll()
        } label: {
            HStack(spacing: 6.w) {
                Image(app: allSelected ? .deselectAllIcon : .selectAllIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15.s, height: 15.s)

                Text(
                    allSelected
                        ? LocalizedKey.albumDeselectAll.localized
                        : LocalizedKey.albumSelectAll.localized
                )
                .font(.app(.medium, size: 14))
            }
            .foregroundStyle(Color(app: tint))
            .padding(.horizontal, 14.w)
            .frame(height: 34.h)
            .background(
                Capsule().fill(Color(app: tint))
                    .opacity(0.05)
            )
            .overlay(
                Capsule().stroke(Color(app: tint), lineWidth: 1)
                    .opacity(allSelected ? 0.3 : 0.1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Tabs
    /// A segmented control rather than two loose buttons: a white track
    /// holds both labels and the active one sits on a pill that slides
    /// between them via `matchedGeometryEffect`, matching the Figma.

    private var tabPicker: some View {
        HStack(spacing: 4.w) {
            ForEach(AlbumTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(6.s)
        .background(
            Capsule().fill(Color(app: .white))
        )
        .overlay(
            Capsule().stroke(Color(app: .dark).opacity(0.06), lineWidth: 1)
        )
    }

    private func tabButton(_ tab: AlbumTab) -> some View {
        let isActive = tab == selectedTab

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                selectedTab = tab
            }
        } label: {
            Text(tab.titleKey.localized)
                .font(.app(isActive ? .bold : .bold, size: 14))
                .foregroundStyle(isActive ? Color(app: .accent) : Color(app: .black))
                .frame(maxWidth: .infinity)
                .frame(height: 44.h)
                .background {
                    if isActive {
                        Capsule()
                            .fill(Color(app: .accent).opacity(0.14))
                            .matchedGeometryEffect(id: "activeAlbumTab", in: tabAnimation)
                            .shadow(color: Color(app: .accent).opacity(0.18), radius: 5, y: 2)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: Sections & grid

    private var emptyState: some View {
        Text(LocalizedKey.albumEmptyTitle.localized)
            .font(.app(.medium, size: 15))
            .foregroundStyle(Color(app: .textSecondary))
            .frame(maxWidth: .infinity)
            .padding(.top, 80.h)
    }

    private func sectionView(_ section: AlbumSection) -> some View {
        VStack(alignment: .leading, spacing: 12.h) {
            Text(section.date.albumSectionTitle)
                .font(.app(.semiBold, size: 14))
                .foregroundStyle(Color(app: .black))

            LazyVGrid(columns: columns, spacing: 10.h) {
                ForEach(section.sketches, id: \.objectID) { sketch in
                    thumbnail(sketch)
                }
            }
        }
    }

    private func thumbnail(_ sketch: SavedSketch) -> some View {
        let isSelected = selectedIDs.contains(sketch.objectID)

        return sketchImage(sketch)
            .resizable()
            .scaledToFit()
            .padding(10.s)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 16.s, style: .continuous)
                    .fill(Color(app: .white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16.s, style: .continuous)
                    .stroke(
                        isSelected ? Color(app: .accent).opacity(0.5) : Color(app: .dark).opacity(0.06),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                Image(app: isSelected ? .checkIcon : .uncheckIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.s, height: 20.s)
                    .padding(8.s)
            }
            .contentShape(Rectangle())
            .onTapGesture { toggle(sketch) }
    }

    private func sketchImage(_ sketch: SavedSketch) -> Image {
        guard let uiImage = sketch.uiImage else { return Image(app: .sample1) }
        return Image(uiImage: uiImage)
    }

    // MARK: Delete bar

    private var deleteBar: some View {
        HStack(spacing: 12.w) {
            
            Text(
                String(
                    format: LocalizedKey.albumItemsSelected.localized,
                    selectedIDs.count
                )
            )
            .font(.app(.medium, size: 15))
            .foregroundStyle(Color(app: .dark))
            .padding(.leading, 12.w)
            
            Spacer(minLength: 8.w)
            
            Button {
                deleteSelected()
            } label: {
                HStack(spacing: 6.w) {
                    Image(app: .deleteIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16.s, height: 16.s)
                    
                    Text(LocalizedKey.albumDelete.localized)
                        .font(.app(.semiBold, size: 15))
                }
                .foregroundStyle(Color(app: .white))
                .padding(.horizontal, 16.w)
                .frame(height: 42.h)
                .background(
                    Capsule()
                        .fill(Color(app: .redAccent))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 5.w)
        .frame(height: 50.h)
        .frame(maxWidth: .infinity)
        .background( 
             Capsule()
                 .fill(Color(app: .white))
                 .overlay(
                     Capsule()
                         .stroke(
                             Color(app: .dark).opacity(0.1),
                             lineWidth: 1
                         )
                 )
                 .shadow(
                     color: .kBlack.opacity(0.08),
                     radius: 12,
                     y: -4
                 )
         )
        .padding(.horizontal, pageMargin.w)
        .padding(.bottom, 12.h)
        .transition(
            .move(edge: .bottom)
                .combined(with: .opacity)
        )
    }

    // MARK: Actions

    private func toggle(_ sketch: SavedSketch) {
        withAnimation(.easeOut(duration: 0.15)) {
            if selectedIDs.contains(sketch.objectID) {
                selectedIDs.remove(sketch.objectID)
            } else {
                selectedIDs.insert(sketch.objectID)
            }
        }
    }

    private func toggleSelectAll() {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedIDs = allSelected ? [] : Set(visibleSketches.map(\.objectID))
        }
    }

    private func deleteSelected() {
        let doomed = visibleSketches.filter { selectedIDs.contains($0.objectID) }
        withAnimation(.easeOut(duration: 0.2)) {
            SketchStore.delete(doomed, in: moc)
            selectedIDs.removeAll()
        }
    }
}

// MARK: - Date formatting

private extension Date {
    /// "Thu 3 Sep 2026" — matches the section headers in the design.
    var albumSectionTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM yyyy"
        return formatter.string(from: self)
    }
}

//#Preview {
//    NavigationStack {
//        AlbumView()
//    }
//}
