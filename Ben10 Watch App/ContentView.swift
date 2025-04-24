import SwiftUI
import WatchKit

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX , y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct OverlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Create a diamond/overlap shape manually
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // top center
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)) // right center
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) // bottom center
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY)) // left center
        path.closeSubpath()
        return path
    }
}

struct OmnitrixView: View {
    
    @State private var pulse = false
    @State private var isAct = true
    @State private var crownValue: Double = 0.0
    @State private var selectedIndex: Int = 0
    @FocusState private var isFocused: Bool
    let omnitrixImages=["Asset 1","Asset 2","Asset 3","Asset 4","Asset 5","Asset 6","Asset 7","Asset 8","Asset 9","Asset 10"]
    let scrW = WKInterfaceDevice.current().screenBounds.width
    let scrH = WKInterfaceDevice.current().screenBounds.height
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.green
                .opacity(pulse ? 1.0 : 0.7)
                .animation(.easeInOut(duration: 1.0), value: pulse)
                .edgesIgnoringSafeArea(.all)
            ZStack {
                // Left triangle
                Triangle()
                    .fill(Color.black)
                    .frame(width: scrH*2.1, height: scrW*2.1/2)
                    .rotationEffect(.degrees(-90))
                    .offset(y:scrH*0.08)
                    .offset(x: isAct ? scrW/1.5:0)
                    .animation(.easeInOut(duration: 0.4), value: isAct)
                    .edgesIgnoringSafeArea(.all)
                // Right triangle
                Triangle()
                    .fill(Color.black)
                    .frame(width: scrH*2.1, height: scrW*2.1/2)
                    .rotationEffect(.degrees(90))
                    .offset(y: scrH*0.08)
                    .offset(x: isAct ? -scrW/1.5:0)
                    .animation(.easeInOut(duration: 0.4), value: isAct)
                    .edgesIgnoringSafeArea(.all)
                // Overlapping area (custom shape)
                OverlapShape()
                    .fill(Color.green)
                    //.offset(y:15)
                    .frame(width: isAct ? 0:scrW*0.85, height: isAct ? 0:scrH)
                    .animation(.easeInOut(duration: 0.4), value: isAct)
                    .edgesIgnoringSafeArea(.all)
                Image(omnitrixImages[selectedIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: isAct ? 0:scrW, height: isAct ? 0:scrH)
                    .animation(.easeInOut(duration: 0.5), value: isAct)
                
            }
            .focusable(true)
            .focused($isFocused)
            .digitalCrownRotation(
                $crownValue,
                from: 0,
                through: Double(omnitrixImages.count - 1),
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onAppear {
                isFocused = true
            }
            .onChange(of: crownValue) {
                if(isAct==false){
                    selectedIndex = Int(crownValue.rounded()) % omnitrixImages.count
                }}

            .onTapGesture {
                isAct.toggle()
            }

        }
        .onReceive(timer) { _ in
            pulse.toggle()
        }
    }
}
