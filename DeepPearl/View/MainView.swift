//
//  MainView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI

struct MainView: View {
    @State private var isShowingAddModal = false
    @State private var gratitudeText = ""
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            
            Image("default_back")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // TODO: add coral images
            
            // VStack {
            //     Spacer()
            //     HStack(spacing: -210) {
            //         Image("coral_yellow")
            //             .interpolation(.none)
            //             .resizable()
            //             .scaledToFit()
            //             .frame(width: 410, height: 180)
            //             .padding(.leading, 20)
            
            //         Image("coral_red")
            //             .interpolation(.none)
            //             .resizable()
            //             .scaledToFit()
            //             .frame(width: 410, height: 180)
            //             .padding(.trailing, 20)
            //     }
            //     .padding(.bottom, 20)
            // }
            
            LightRayView()
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    AnimatedGoblinSharkView()
                        .frame(width: 190, height: 190)
                    Spacer()
                }
                Spacer()
            }
            
            VStack{
                Button{
                    HistoryView()
                }label:{
                    Image(systemName: "archivebox.fill")
                    //.frame(width: 40, height: 47)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                    //.background(.ultraThinMaterial)
                    //.clipShape(Circle())
                }
                //.buttonStyle(.bordered)
                .tint(.white)
                .padding(.top, 45)
                .padding(.trailing, 30)
                .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: 4)
                Spacer()
            }
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button{
                        isShowingAddModal = true
                    } label:{
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 60)
                    .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: 4)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingAddModal) {
            AddModalView(isPresented: $isShowingAddModal, text: $gratitudeText)
        }
    }
}

#Preview {
    MainView()
}
