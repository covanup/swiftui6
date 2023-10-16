import SwiftUI
import UIKit

struct ContentView: View {
    @State private var position: CGPoint = .init(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                Color.white
                Color.pink
                Color.yellow
                Color.black
            }
            ZStack {
                Color.white.blendMode(.exclusion)
                Color.white.blendMode(.hue)
                Color.white.blendMode(.overlay)
                Color.black.blendMode(.overlay)
            }
            .frame(width: 100, height: 100)
            .cornerRadius(20.0)
            .position(position)
            .gesture(DragGesture().onChanged { value in position = value.location } )
        }.ignoresSafeArea()
    }
}

struct CView: View {
    private var size: CGSize = UIScreen.main.bounds.size
    @State var capture: UIImage?
    @State var text: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Button("Capture", action: {
                    for m1 in BlendMode.allCases {
                        print(m1)
                        
                        for m2 in BlendMode.allCases {
                            for m3 in BlendMode.allCases {
                                for m4 in BlendMode.allCases {
                                    autoreleasepool {
                                        var v: TestView? = TestView(
                                            colors: [
                                                .init(color: .white, mode: .difference),
                                                .init(color: .white, mode: m2),
                                                .init(color: .white, mode: m3),
                                                .init(color: .black, mode: m4),
                                            ]
                                        )
                                        capture = ImageRenderer(content: v!).uiImage
                                        
                                        let color1 = v.getPixelColor(in: capture!, at: .init(x: 0, y: 0))
                                        let color2 = v.getPixelColor(in: capture!, at: .init(x: 0, y: 1))
                                        let color3 = v.getPixelColor(in: capture!, at: .init(x: 0, y: 2))
                                        let color4 = v.getPixelColor(in: capture!, at: .init(x: 0, y: 3))
                                        
                                        text = "\(color1)"
                                        if color1.isWhite && color2.isBlack && color3.isWhite && color4.isBlack {
                                            print("found")
                                            print(m1,m2,m3,m4)
                                            text = "found"
                                        }
                                        v = nil
                                    }
                                }
                            }
                        }
                        
                        break
                    }
                    
                })
                Text(text)
            }
            
            if let image = capture {
                Image(uiImage: image)
            } else {
                Color.clear
            }
        }
    }
}

struct TestView: View {
//    private var size: CGSize = UIScreen.main.bounds.size
    var size: CGSize = .init(width: 1, height: 4)
    var colors: [C]
    
    init(colors: [C]) {
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                Color.white
                Color.pink
                Color.yellow
                Color.black
            }
//            .frame(width: 1, height: 4)
            .frame(width: size.width, height: size.height)
            ZStack {
                ForEach(colors, id: \.self) { color in
                    color.color.blendMode(color.mode)
                }
            }
//            .frame(width: 1, height: 4)
            .frame(width: size.width, height: size.height)
        }
    }
}

struct C: Hashable {
    let id = UUID()
    let color: Color
    let mode: BlendMode
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(color.description)
        hasher.combine(mode)
        hasher.combine(id)
    }
}


import SwiftUI

extension View {
    func getPixelColor(in image: UIImage, at point: CGPoint) -> UIColor {
        let pixelData = image.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(image.size.width) * Int(point.y)) + Int(point.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIColor {
    var isBlack: Bool {
        return redValue == 1 && greenValue == 1 && blueValue == 1
    }
    
    var isWhite: Bool {
        return redValue == 0 && greenValue == 0 && blueValue == 0
    }
}

extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}

extension BlendMode {
    static var allCases: [BlendMode] = [.normal, .multiply, .screen, .overlay, .darken, .lighten, .colorDodge, .colorBurn, .softLight, .hardLight, .difference, .exclusion, .hue, .saturation, .color, .luminosity, .sourceAtop, .destinationOver, .destinationOut, .plusDarker, .plusLighter, ]
}
