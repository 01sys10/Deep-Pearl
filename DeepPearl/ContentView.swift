//
//  ContentView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/8/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            Image("default_back")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            LightRayView()
            VStack{
                Spacer()
                Button{
                    
                }label:{
                    Image(systemName: "plus")
                        .frame(width: 40, height: 47)
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundStyle(Color.white)
                        .clipShape(Circle())
                    
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .padding(.bottom, 60)
                .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: 4)
            }
        }
    }
}

#Preview {
    ContentView()
}
