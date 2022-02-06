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
                .font(.caption)
                .rotationEffect(self.textAngle())
                .foregroundColor(.black)
                .padding(.bottom, 60)
            
            Capsule()
                .frame(width: self.capsuleWidth(),
                       height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
                .padding(.bottom, 120)
            
            Text(marker.degreeText())
                .fontWeight(.regular)
                .font(.system(size: 8))
                .rotationEffect(self.textAngle())
                .foregroundColor(Color("primaryColor"))
                .padding(.bottom,205)
            
        }
        .rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return self.marker.degrees == 0 ? 4 : 2
    }
    
    private func capsuleHeight() -> CGFloat {
        return self.marker.degrees == 0 ? 13 : 6
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
            VStack {
                Capsule()
                    .foregroundColor(Color("primaryColor"))
                    .frame(width: 5,height: 20)
                    .padding(.bottom,20)
                ZStack {
                    ZStack {
                        Circle()
                            .stroke(Color("primaryColor").opacity(0.15),style: StrokeStyle(lineWidth: 150))
                            .padding(50)
                        
                        Circle()
                            .stroke(Color("primaryColor"),style: StrokeStyle(lineWidth: 10))
                            .padding(-20)
                        
                        Circle()
                            .stroke(Color("primaryColor"),style: StrokeStyle(lineWidth: 5))
                            .padding(10)
                        
                        Circle()
                            .stroke(Color.white,style: StrokeStyle(lineWidth: 25))
                            .padding(50)
                        
                        ForEach(Marker.markers(), id: \.self) { marker in
                            CompassMarkerView(marker: marker,
                                              compassDegress: self.compassHeading.degrees)
                        }
                        
                    }
                    .frame(width: 200, height: 200)
                    .rotationEffect(Angle(degrees: self.compassHeading.degrees))
                    
                    Text("Filter".localizedString)
                        .font(.system(size: 12))
                        .frame(width: 45, height: 45, alignment: .center)
                        .foregroundColor(Color("primaryColor"))
                        .background(Color("primaryColor").opacity(0.5))
                        .cornerRadius(22.5)
                }
                
                Text("Tap compass to filter feed in chosen direction".localizedString)
                    .padding(.top,20)
                    .font(.system(size: 11))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .foregroundColor(.black)
                    .padding(.bottom,10)
                
            }
        }
    }
}

struct CompassMarkerViewForIPhoneSmall: View {
    let marker: Marker
    let compassDegress: Double
    
    var body: some View {
        ZStack {
            Text(marker.label)
                .font(.system(size: 8))
                .rotationEffect(self.textAngle())
                .foregroundColor(.black)
                .padding(.bottom, 45)
            
            Capsule()
                .frame(width: self.capsuleWidth(),
                       height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
                .padding(.bottom, 90)
            
            Text(marker.degreeText())
                .fontWeight(.regular)
                .font(.system(size: 6))
                .rotationEffect(self.textAngle())
                .foregroundColor(Color("primaryColor"))
                .padding(.bottom,133)
            
        }
        .rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return self.marker.degrees == 0 ? 3 : 1.5
    }
    
    private func capsuleHeight() -> CGFloat {
        return self.marker.degrees == 0 ? 8 : 4
    }
    
    private func capsuleColor() -> Color {
        return self.marker.degrees == 0 ? .red : .gray
    }
    
    private func textAngle() -> Angle {
        return Angle(degrees: -self.compassDegress - self.marker.degrees)
    }
}

struct CompassViewSwiftUIForIPhoneSmall: View {
    
    @ObservedObject var compassHeading = CompassHeading()
    
    var body: some View {
        ZStack {
            VStack {
                Capsule()
                    .foregroundColor(Color("primaryColor"))
                    .frame(width: 4,height: 10)
                    .padding(.bottom,14)
                
                ZStack {
                    ZStack {
                        Circle()
                            .stroke(Color("primaryColor").opacity(0.15),style: StrokeStyle(lineWidth: 120))
                            .padding(40)
                        
                        Circle()
                            .stroke(Color("primaryColor"),style: StrokeStyle(lineWidth: 6))
                            .padding(-16)
                        
                        Circle()
                            .stroke(Color("primaryColor"),style: StrokeStyle(lineWidth: 3))
                            .padding(2)
                        
                        Circle()
                            .stroke(Color.white,style: StrokeStyle(lineWidth: 16))
                            .padding(20)
                        
                        ForEach(Marker.markers(), id: \.self) { marker in
                            CompassMarkerViewForIPhoneSmall(marker: marker,
                                              compassDegress: self.compassHeading.degrees)
                        }
                        
                    }
                    .frame(width: 120, height: 120)
                    .rotationEffect(Angle(degrees: self.compassHeading.degrees))
                    
                    Text("Filter".localizedString)
                        .font(.system(size: 7))
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(Color("primaryColor"))
                        .background(Color("primaryColor").opacity(0.5))
                        .cornerRadius(15)
                }
                
                Text("Tap compass to filter feed in chosen direction".localizedString)
                    .padding(.top,16)
                    .font(.system(size: 8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .foregroundColor(.black)
                    .padding(.bottom,5)
            }
        }
    }
}
