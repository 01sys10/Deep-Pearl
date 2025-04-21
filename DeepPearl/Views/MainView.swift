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
    @State private var currentTime = Date()
    
    
    @State private var animate = false
    @State private var selectedNote: ThankNote? = nil
    // 유저가 탭한 진주에 해당하는 감사 기록을 담는 변수
    // 기본값 nil, 유저가 진주를 탭하면 값이 채워짐
    @State private var pearlYPositions: [PersistentIdentifier: CGFloat] = [:]
    @State private var pearlXPositions: [PersistentIdentifier: CGFloat] = [:]
    
    // fish level 단계 User Default로 저장
    @AppStorage("fishLevel") private var fishLevel: Int = 1
    
    private let maxFishLevel = 3
    
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            
            Image("default_back")
                .resizable()
            //.scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()          
            
            LightRayView()
            
            // MARK: pearl
            ForEach(notes.filter { !$0.isRecalled }) { note in
                let id = note.persistentModelID
                // let isFloatingUp = note.timestamp < Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                // 테스트용(10초 뒤 상승)
                let isFloatingUp = currentTime.timeIntervalSince(note.timestamp) >= 10
                let x = pearlXPositions[id] ?? CGFloat.random(in: 30...350)

                FloatingPearlView(
                    note: note,
                    x: x,
                    isFloatingUp: isFloatingUp,
                    pearlSize: note.pearlSize
                ) {
                    selectedNote = note
                    showRecollection = true
                }
                .onAppear {
                    if pearlXPositions[id] == nil {
                        pearlXPositions[id] = x
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
                            fishLevel = min(fishLevel + 1, maxFishLevel) // 감사 기록 상기하면 물고기 레벨업
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
            
            
            // MARK: Swimming fish
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    SwimmingGoshaView(fishLevel: fishLevel)
                    Spacer()
                }
                Spacer()
            } // Swimming Gosha
            
            
            // MARK: Button(MainView -> HistoryView)
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
            
            
            // MARK: Button(MainView -> AddModalView)
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
        .onTapGesture {
            currentTime = Date()
        }
        
        
        // MARK: for test
        
        //        .onAppear {
        //            DataManager.deleteAllNotes(in: modelContext)
        //        }
        
        .onAppear {
            fishLevel = 1
        }
        
        .sheet(isPresented: $isShowingAddModal) {
            AddModalView(isPresented: $isShowingAddModal, text: $thankNote)
        }
        .animation(.easeInOut, value: isShowingHistory)
        
    }
    
    
    struct FloatingPearlView: View {
        let note: ThankNote
        let x: CGFloat
        let isFloatingUp: Bool
        let pearlSize: CGFloat
        let onTap: () -> Void
        
        @State private var y: CGFloat
        
        init(note: ThankNote, x: CGFloat, isFloatingUp: Bool, pearlSize: CGFloat, onTap: @escaping () -> Void) {
            self.note = note
            self.x = x
            self.isFloatingUp = isFloatingUp
            self.pearlSize = pearlSize
            self.onTap = onTap
            _y = State(initialValue: isFloatingUp ? 120 : 700)
        }
        
        var body: some View {
            Image(isFloatingUp ? "pearl_yellow" : "pearl_pink")
                .resizable()
                .interpolation(.none)
                .frame(width: pearlSize, height: pearlSize)
                .shadow(color: .white, radius: 16)

                .position(x: x, y: y)
                .onTapGesture {
                    if isFloatingUp {
                        onTap()
                    }
                }
                .onChange(of: isFloatingUp) {
                    withAnimation(.easeInOut(duration: 2)) {
                        y = isFloatingUp ? 120 : 700
                    }
                }
        }
    }
}
    
    #Preview {
        MainView()
    }
