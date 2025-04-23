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
    @State private var isShowingTutorial = false

    @State private var showRecollection = false
    @State private var thankNote = ""
    @State private var currentTime = Date()
    
    
    @State private var animate = false
    
    @State private var selectedNote: ThankNote? = nil
    // 유저가 탭한 진주에 해당하는 감사 기록을 담는 변수
    // 기본값 nil, 유저가 진주를 탭하면 값이 채워짐
    // @State private var pearlYPositions: [PersistentIdentifier: CGFloat] = [:]
    @State private var pearlXPositions: [PersistentIdentifier: CGFloat] = [:]// 진주의 위치 기억하기 위한 변수. 한 번 위치를 저장해서 다음 렌더링 때도 같은 위치를 사용하려고.
    // 각 ThankNote 객체는 SwiftData에서 고유한 persistentModelID(PersistenetIdentifier)를 가지고 있기 때문에 이 ID를 통해 진주 하나 하나를 구분할 수 있다.
    
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
            
            LightRayView(animate: $animate)
            
            // MARK: pearl
            ForEach(notes.filter { !$0.isRecalled }) { note in
                let id = note.persistentModelID
                // 일주일 뒤 상승
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
            
            // TODO: alert말고 오버레이로 수정
            // alert로 상기 내용 보여주기
            .alert(isPresented: $showRecollection) {
                Alert(
                    title: Text("🙏일주일 전 감사 기록🙏"),
                    message: Text(selectedNote?.note ?? ""),
                    dismissButton: .default(Text("감사하다!")) {
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
                        .interpolation(.none) // 보간법. 주어진 픽셀을 가지고 더 작은 픽셀 단위로 추정하고 만든다.
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
                    Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), // animate가 true로 한 번만 바뀌더라도 Swiftui가 x축 오프셋이 -10 -> 10 -> -10 -> 10 ... 이런 식으로 계속 오가도록 애니메이션 반복
                    value: animate
                )
                .onAppear {
                    animate = false
                }
                // SwiftUI의 뷰는 상태가 바뀌면 해당 뷰 트리 자체가 다시 생성된다
                // 모델 데이터를 변경하고 저장하면, Swiftui는 내부적으로 notes에 변화가 생겼다고 판단, 관련된 뷰 계층을 다시 생성
                // "어? 데이터 바뀌었네? 그럼 이 뷰도 다시 만들어야지"하면서 .onAppear 이전에 설정된 애니메이션 상태도 날려버리는 것
                // 여기서는 HistoryView를 다녀와도 onAppear가 실행되지 않아서
                // HistoryView isShowing값이 변할 때 다시 트리거를 주는 걸로 해결(아래 onChange)
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
            
            
            // MARK: Buttons(MainView -> HistoryView & MainView -> TutorialView)
            VStack{
                HStack{
                    Button{
                        withAnimation{
                            isShowingTutorial = true
                        }
                    } label:{
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                    }
                    .tint(.white)
                    .padding(.top, 45)
                    .padding(.leading, 30)
                    .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: 4)
                    
                    Spacer()
                    
                    Button{
                        withAnimation{
                            isShowingHistory = true
                        }
                    } label:{
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                    }
                    .tint(.white)
                    .padding(.top, 45)
                    .padding(.trailing, 30)
                    .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: 4)
                }
                Spacer()
            }
            
            if isShowingHistory {
                HistoryView(isShowing: $isShowingHistory)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(1)
                //.environmentObject(mockViewModel)
            }
            
            // TODO: isShowingTutorial 구현
            
            
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
                            .padding(22)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 50)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
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
            
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                animate = true
            }
        }
        
        
        .sheet(isPresented: $isShowingAddModal) {
            AddModalView(isPresented: $isShowingAddModal, text: $thankNote)
        }
        .animation(.easeInOut, value: isShowingHistory)
        .onChange(of: isShowingHistory) { _, newValue in
            if !newValue {
                // 히스토리뷰 닫히면 coral 애니메이션 다시 시작
                animate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    animate = true
                }
            }
        }
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
