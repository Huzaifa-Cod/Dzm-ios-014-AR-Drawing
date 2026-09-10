//
//  ReportingScrollView.swift
//  ARDrawing


import SwiftUI

/// True while the scrolling content extends past the bottom of its container.
struct HasContentBelowKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct ReportingScrollView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    private let space = "reportingScroll"

    var body: some View {
        GeometryReader { container in
            ScrollView(showsIndicators: false) {
                content()
                    .background {
                        GeometryReader { inner in
                            // The content's top edge in container coordinates:
                            // zero at rest, negative once scrolled. Adding the
                            // content height puts us at its bottom edge, so
                            // anything past the container means more to come.
                            let bottom = inner.frame(in: .named(space)).minY + inner.size.height
                            Color.clear.preference(
                                key: HasContentBelowKey.self,
                                value: bottom > container.size.height + 1
                            )
                        }
                    }
            }
            .coordinateSpace(name: space)
        }
    }
}
