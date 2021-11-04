//
//  CircleView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/08/2021.
//

import SwiftUI

struct CircleView: View {
    @State var fill1:CGFloat = 0.0
    @State var fill2:CGFloat = 0.0
    @State var fill3:CGFloat = 0.0
    @State var animations:Bool = false
    
    var male:Int = 0
    var female:Int = 0
    var other:Int = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.05),style: StrokeStyle(lineWidth: 45))
                .padding(30)
            Circle()
                .trim(from: 0, to: fill1)
                .stroke(Color.blue.opacity(2),style: StrokeStyle(lineWidth: 13))
                .rotationEffect(.init(degrees: -90))
                .animation(Animation.linear(duration: 1))
                .padding(10)
            
            Circle()
                .trim(from: 0, to: self.fill2)
                .stroke(Color.red.opacity(2),style: StrokeStyle(lineWidth: 13))
                .rotationEffect(.init(degrees: -90))
                .animation(Animation.linear(duration: 1))
                .padding(23)
            
            
            Circle()
                .trim(from: 0, to: self.fill3)
                .stroke(Color.green.opacity(2),style: StrokeStyle(lineWidth: 13))
                .rotationEffect(.init(degrees: -90))
                .animation(Animation.linear(duration: 1))
                .padding(36)
        }
        .onAppear(){
            for i in 0...male {
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i/60)) {
                    self.fill1 += 0.01
                }
            }
            
            for i in 0...female {
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i/60)) {
                    self.fill2 += 0.01
                }
            }
            
            for i in 0...other {
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i/60)) {
                    self.fill3 += 0.01
                }
            }
        }
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
