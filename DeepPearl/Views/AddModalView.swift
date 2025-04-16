//
//  AddModalView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI
import SwiftData

struct AddModalView: View {
    @Query var notes: [ThankNote]

    @Binding var isPresented: Bool
    @Binding var text: String
    @State private var isShowingDiscardAlert = false
    
    @Environment(\.modelContext) private var modelContext

    
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
        //.presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)

//        .onChange(of: isPresented) { oldValue, newValue in
//            if !newValue {
//                if !text.isEmpty {
//                    isShowingDiscardAlert = true
//                } else {
//                    text = ""
//                }
//            }
//        }
        
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

