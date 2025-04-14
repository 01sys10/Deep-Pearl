//
//  ContentView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingGratitudeModal = false
    @State private var gratitudeText = ""
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            
            Image("default_back")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
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
                    // move to history
                }label:{
                    Image(systemName: "archivebox.fill")
                        //.frame(width: 40, height: 47)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        //.background(.ultraThinMaterial)
                        //.clipShape(Circle())
                }
                //.buttonStyle(.bordered)
                .tint(.white)
                .padding(.bottom, 60)
                .padding([.top, .trailing], 45)
                .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: 4)
                Spacer()

            }
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button{
                        isShowingGratitudeModal = true
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
        .sheet(isPresented: $isShowingGratitudeModal) {
            GratitudeModalView(isPresented: $isShowingGratitudeModal, text: $gratitudeText)
        }
    }
}

struct GratitudeModalView: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    @State private var isShowingDiscardAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $text)
                    .padding()
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(10)
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("감사한 일을 기록해주세요")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Save action
                        isPresented = false
                    }
                    .disabled(text.isEmpty)
                    .foregroundColor(text.isEmpty ? .gray : .blue)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        .onChange(of: isPresented) { oldValue, newValue in
            if !newValue && !text.isEmpty {
                isShowingDiscardAlert = true
            }
        }
        .alert("기록 중이던 내용을 모두 삭제하시겠어요?", isPresented: $isShowingDiscardAlert) {
            Button("취소", role: .cancel) {
                isPresented = true
            }
            Button("삭제", role: .destructive) {
                text = ""
            }
        }
    }
}

#Preview {
    ContentView()
}
