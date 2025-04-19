//
//  MainView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI
import SwiftData


struct MainView: View {
    @Environment(\.modelContext) var modelContext
    @Query var notes: [ThankNote]
    
    @State private var isShowingAddModal = false
    @State private var isShowingHistory = false
    @State private var showRecollection = false
    @State private var thankNote = ""
    
    @State private var animate = false
    @State private var selectedNote: ThankNote? = nil
    // 유저가 탭한 진주에 해당하는 감사 기록을 담는 변수
    // 기본값 nil, 유저가 진주를 탭하면 값이 채워짐
    
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            
            Image("default_back")
                .resizable()
            //.scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            //.edgesIgnoringSafeArea(.all)
            
            
            LightRayView()
            
            // MARK: pearl
            ForEach(notes.filter { !$0.isRecalled }) { note in
                // let isFloatingUp = note.timestamp < Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                // 테스트용(10초 뒤 상승)
                let isFloatingUp = note.timestamp < Date().addingTimeInterval(-10)
                
                Image(isFloatingUp ? "pearl_yellow" : "pearl_pink")
                    .resizable()
                    .interpolation(.none)
                    .frame(width: note.pearlSize, height: note.pearlSize)
                    .position(x: CGFloat.random(in: 30...350),
                              y: isFloatingUp ? 120 : 700)
                    .onTapGesture {
                        if isFloatingUp {
                            selectedNote = note
                            showRecollection = true
                        }
                    }
            }
            
            // alert로 상기 내용 보여주기
            .alert(isPresented: $showRecollection) {
                Alert(
                    title: Text("Thank-note from a week ago"),
                    message: Text(selectedNote?.note ?? ""),
                    dismissButton: .default(Text("Thanks!")) {
                        if let selectedNote = selectedNote {
                            selectedNote.isRecalled = true
                            try? modelContext.save()
                        }
                    }
                )
            }
            
            
            // MARK: coral
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
                .offset(x: animate ? -10 : 10)
                .animation(
                    Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                    value: animate
                )
                .onAppear {
                    animate = true
                }
                
            }
            
            
            
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
