//
//  AddModalView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI
import SwiftData

struct AddModalView: View {
    @Query var notes: [ThankNote] // 여기서는 읽어올 때(오늘 기록이 이미 있는지 확인할 때) 사용
    // @Query로 접근 -> 값 수정/삭제 -> modelContext에 변경 내용 저장
    @Environment(\.modelContext) private var modelContext // 영구 데이터 모델의 전체 라이프사이클을 관리하는 역할, 모델에 대한 변경사항을 추적하고 유지한다.
    // 여기서는 저장할 때 사용
    // autosaveEnabled. -> 암묵적 쓰기 -> 데이터가 삽입되거나 등록된 모델을 변경하면 ModelContext에서 save() 호출
    // @Environment는 SwiftUI 뷰 내부에서만 가능, 함수나 구조체 내부에서는 직접 넘겨야 됨.
    
    @Binding var isPresented: Bool // add sheet presented 여부
    @Binding var text: String // 유저가 TextEditor에 작성하는 텍스트
    @State private var isShowingDiscardAlert = false // 유저가 작성 중에 모달을 닫으려 할 경우 동작을 확인하는 경고창
    @State private var isShowingAlreadyExistsAlert = false // 이미 작성한 감사 기록이 있는 날짜에 또 작성을 시도할 경우 띄울 경고창 - 덮어 쓰기 가능
    @FocusState private var isFocused: Bool
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                // MARK: TextEditor
                if !isFocused && text.isEmpty {
                    Text("오늘 감사했던 일을 35자 이내로 적어보세요.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 22)
                        .padding(.top, 18)
                }
                
                TextEditor(text: $text)
                    .padding()
                    .scrollContentBackground(.hidden)
                    .cornerRadius(14)
                    .padding()
                    .foregroundColor(.primary)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > 35 {
                            text = String(newValue.prefix(35))
                        }
                    }
                // 알아서 TextEditor focused
                // .onAppear { DispatchQueue.main.asyncAfter(deadline: .now()+0.35) {
                //             isFocused = true }
                //           }
            }
            .overlay(
                Text("\(text.count)/35")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.trailing, 30)
                    .padding(.bottom, 10),
                alignment: .bottomTrailing
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if !text.isEmpty {
                            isShowingDiscardAlert = true
                        } else {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("오늘은 어떤 일이 감사했나요?")
                        .font(.headline)
                        .fontWeight(.bold)
                    //.foregroundColor(.white)
                }
                
                // MARK: save button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        let alreadyExists = notes.contains {
                            Calendar.current.isDate($0.timestamp, inSameDayAs: .now)
                        }
                        
                        if alreadyExists {
                            // 하루 1개 제한 알림 띄우기
                            print("이미 작성한 기록이 있다!!")
                            isShowingAlreadyExistsAlert = true
                        } else {
                            DataManager.saveNote(text: text, in: modelContext)
                            // 뷰에서 주입받은 context를 외부 저장 로직에 전달하기 위해 modelContext를 넘긴다.
                            text = ""
                            isPresented = false
                        }
                    }
                    .disabled(text.isEmpty)
                    .foregroundColor(text.isEmpty ? .gray : .blue)
                    .alert("오늘의 감사는 이미 완료했어요!👍", isPresented: $isShowingAlreadyExistsAlert){
                        Button("기존 기록 유지", role: .cancel){
                            text = ""
                            isPresented = false
                        }
                        Button("지금 쓴 기록으로 덮어쓰기", role: .destructive){
                            DataManager.replaceNote(text: text, in: modelContext)
                            text = ""
                            isPresented = false
                        }
                    } message: {
                        Text("새로운 기록으로 바꾸실래요?\n(기존 내용은 사라져요)")
                    }
                }
                
            }
        }
        .presentationDetents([.medium])
        .presentationContentInteraction(.scrolls)
        
        .alert("기록 중이던 내용을 모두 삭제하시겠어요?", isPresented: $isShowingDiscardAlert) {
            Button("취소", role: .cancel) {
                isPresented = true
            }
            Button("삭제", role: .destructive) {
                text = ""
                isPresented = false
            }
        }
    }
}

