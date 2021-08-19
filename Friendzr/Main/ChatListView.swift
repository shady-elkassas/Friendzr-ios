//
//  ChatListView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import SwiftUI

struct ChatListView: View {
    var body: some View {
        VStack {
            TopView()
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}

struct TopView : View {
    
    var body : some View{
        
        VStack{
            HStack(spacing: 15){
                Text("Chats")
                    .fontWeight(.heavy)
                    .font(.system(size: 23))
                    .accentColor(.green)
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image("feeds_selected_ic").resizable().frame(width: 20, height: 20)
                }
                
                Button(action: {
                    
                }) {
                    Image("menu").resizable().frame(width: 20, height: 20)
                }
                
            }
            .foregroundColor(Color.white)
            .padding()
            
            GeometryReader{_ in
            }
        }
        

    }
}
