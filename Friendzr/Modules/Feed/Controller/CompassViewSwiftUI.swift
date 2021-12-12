//
//  CompassViewSwiftUI.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/09/2021.
//

import SwiftUI

class Degree {
    static var degreeString = ""
}

struct Marker: Hashable {
    let degrees: Double
    let label: String

    init(degrees: Double, label: String = "") {
        self.degrees = degrees
        self.label = label
    }

    func degreeText() -> String {
        return String(format: "%.0f", self.degrees)
    }

    static func markers() -> [Marker] {
        return [
            Marker(degrees: 0, label: "N"),
            Marker(degrees: 30),
            Marker(degrees: 60),
            Marker(degrees: 90, label: "E"),
            Marker(degrees: 120),
            Marker(degrees: 150),
            Marker(degrees: 180, label: "S"),
            Marker(degrees: 210),
            Marker(degrees: 240),
            Marker(degrees: 270, label: "W"),
            Marker(degrees: 300),
            Marker(degrees: 330)
        ]
    }
}

struct CompassMarkerView: View {
    let marker: Marker
    let compassDegress: Double

    var body: some View {
        ZStack {
            Text(marker.label)
                .fontWeight(.bold)
                .rotationEffect(self.textAngle())
                .foregroundColor(.black)
                .padding(.bottom, 75)

            Capsule()
                .frame(width: self.capsuleWidth(),
                       height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
                .padding(.bottom, 165)

            Text(marker.degreeText())
                .fontWeight(.regular)
                .font(.system(size: 10))
                .rotationEffect(self.textAngle())
                .foregroundColor(Color("primaryColor"))
                .padding(.bottom,250)

        }
        .rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return self.marker.degrees == 0 ? 5 : 2
    }

    private func capsuleHeight() -> CGFloat {
        return self.marker.degrees == 0 ? 16 : 10
    }

    private func capsuleColor() -> Color {
        return self.marker.degrees == 0 ? .red : .gray
    }

    private func textAngle() -> Angle {
        return Angle(degrees: -self.compassDegress - self.marker.degrees)
    }
}


struct CompassViewSwiftUI: View {
    
    @ObservedObject var compassHeading = CompassHeading()

    var body: some View {
        ZStack {
            if #available(iOS 15.0, *) {
                Color.clear
            } else {
                // Fallback on earlier versions
            }
            
            VStack {
                Capsule()
                    .foregroundColor(.blue)
                    .frame(width: 5,height: 30)
                    .padding(.bottom,-10)
                ZStack {
                    ZStack {
                        Circle()
                            .stroke(Color("primaryColor").opacity(0.15),style: StrokeStyle(lineWidth: 250))
                            .padding(130)
                        
                        Circle()
                            .stroke(Color("primaryColor"),style: StrokeStyle(lineWidth: 10))
                            .padding(10)
                        
                        Circle()
                            .stroke(Color("primaryColor"),style: StrokeStyle(lineWidth: 5))
                            .padding(50)
                        
                        Circle()
                            .stroke(Color.white,style: StrokeStyle(lineWidth: 40))
                            .padding(90)
                        
                        ForEach(Marker.markers(), id: \.self) { marker in
                            CompassMarkerView(marker: marker,
                                              compassDegress: self.compassHeading.degrees)
                        }
                        
                    }
                    .frame(width: 320, height: 320)
                    .rotationEffect(Angle(degrees: self.compassHeading.degrees))

                    Text("\(Degree.degreeString)")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .frame(width: 45, height: 45, alignment: .center)
                        .foregroundColor(Color("primaryColor"))
                        .background(Color("primaryColor").opacity(0.5))
                        .cornerRadius(22.5)
                }
                
            }
            .padding(.top,screenH - 500)
        }

    }
}

struct CompassViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        CompassViewSwiftUI()
    }
}
