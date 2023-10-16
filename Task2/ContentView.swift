import SwiftUI

struct ContentView: View {
    @State var enabled = false
    @State var layout: any Layout = HStackLayout()

    var body: some View {
        AnyLayout(self.layout) {
            ForEach(0..<7) { _ in
                createRectangle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createRectangle() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.blue)
            .onTapGesture {
                withAnimation {
                    enabled.toggle()
                    self.layout = enabled ? DiagonalLayout() : HStackLayout()
                }
            }
    }
}

struct DiagonalLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = proposal.replacingUnspecifiedDimensions().width
        let height = proposal.replacingUnspecifiedDimensions().height

        let count = CGFloat(subviews.count)
        let side = height / count

        var currentY = bounds.maxY
        var currentX = bounds.minX

        for subview in subviews {
            let subviewSize = CGSize(width: side, height: side)
            let position = CGPoint(x: currentX, y: currentY)

            subview.place(at: position, anchor: .bottomLeading, proposal: ProposedViewSize(subviewSize))

            currentY -= subviewSize.height
            currentX += (width - side) / (count - 1)
        }
    }
}

struct HStackLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = proposal.replacingUnspecifiedDimensions().width

        let count = CGFloat(subviews.count)
        let spacing = 8.0 * (count - 1)
        let side = (width - spacing) / count

        let size = CGSize(width: side, height: side)

        let currentY = bounds.midY
        var currentX = bounds.minX + side / 2

        for subview in subviews {
            let position = CGPoint(x: currentX, y: currentY)

            subview.place(at: position, anchor: .center, proposal: ProposedViewSize(size))

            currentX += side + spacing / (count - 1)
        }
    }
}
