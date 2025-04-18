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

    @Binding var isPresented: Bool // add sheet presented 여부
    @Binding var text: String // 유저가 TextEditor에 작성하는 텍스트
    @State private var isShowingDiscardAlert = false // 유저가 작성 중에 모달을 닫으려 할 경우 동작을 확인하는 경고창
    
    @Environment(\.modelContext) private var modelContext // 영구 데이터 모델의 전체 라이프사이클을 관리하는 역할, 모델에 대한 변경사항을 추적하고 유지한다.
    // 여기서는 저장할 때 사용
// autosaveEnabled. -> 암묵적 쓰기 -> 데이터가 삽입되거나 등록된 모델을 변경하면 ModelContext에서 save() 호출
// @Environment는 SwiftUI 뷰 내부에서만 가능, 함수나 구조체 내부에서는 직접 넘겨야 됨.
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    TextEditor(text: $text)
                        .padding()
                        //.background(.ultraThinMaterial)
                        .background(Color.white)
                        .cornerRadius(14)
                        .padding()
                        .foregroundColor(.primary)
                }
                .background(Color.white)
                //.background(.ultraThinMaterial)
            }
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
                    Text("감사한 일을 기록해주세요")
                        .font(.headline)
                        .fontWeight(.bold)
                        //.foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let alreadyExists = notes.contains {
                            Calendar.current.isDate($0.timestamp, inSameDayAs: .now)
                        }

                        if alreadyExists {
                            // 하루 1개 제한 알림 띄우기
                            // TODO: 사용자 알림 UI로 변경
                            print("이미 작성한 기록이 있어요!")
                        } else {
                            DataManager.saveNote(text: text, in: modelContext)
                            // 뷰에서 주입받은 context를 외부 저장 로직에 전달하기 위해 modelContext를 넘긴다.
                            
                            text = ""
                            isPresented = false
                        }
                    }
                    .disabled(text.isEmpty)
                    .foregroundColor(text.isEmpty ? .gray : .blue)
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

