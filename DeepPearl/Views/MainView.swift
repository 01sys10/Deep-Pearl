//
//  MainView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI



struct MainView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var isShowingAddModal = false
    @State private var isShowingHistory = false
    @State private var thankNote = ""
    
    
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            
            Image("default_back")
                .resizable()
                //.scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                //.edgesIgnoringSafeArea(.all)
            
            LightRayView()
            
            // TODO: Add coral images

            VStack {
                    Spacer()
                    HStack(spacing: 0) {
                        Image("coral_yellow")
                            .resizable()
                            .interpolation(.none)
                            //.scaledToFit()
                            .frame(width: 200, height: 180)

                        Image("coral_red")
                            .resizable()
                            .interpolation(.none)
                            //.scaledToFit()
                            .frame(width: 200, height: 180)
                    }
            }
                .allowsHitTesting(false) // 산호초는 인터랙션 없음
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    SwimmingGoshaView()
                        .frame(width: 190, height: 190)
                    Spacer()
                }
                Spacer()
            } // Swimming Gosha
            
            
            
            VStack{
                Button{
                    withAnimation{
                        isShowingHistory = true
                    }
                } label:{
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
            
            if isShowingHistory {
                HistoryView(isShowing: $isShowingHistory)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    //.environmentObject(mockViewModel)

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
            } // add note modal button
        }
        
//        .onAppear {
//            DataManager.deleteAllNotes(in: modelContext)
//        }
        .sheet(isPresented: $isShowingAddModal) {
            AddModalView(isPresented: $isShowingAddModal, text: $thankNote)
        }
        .animation(.easeInOut, value: isShowingHistory)

    }
}

#Preview {
    MainView()
}
