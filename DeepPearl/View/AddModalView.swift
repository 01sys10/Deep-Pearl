//
//  GratitudeModalView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI

struct AddModalView: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    @State private var isShowingDiscardAlert = false
//    @EnvironmentObject var viewModel: ThankNotesViewModel
    @StateObject private var viewModel = ThankNotesViewModel()

    
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
                        // ThankNotesViewModel.addNote(text: text) // instance method. can't use like it's type method.
                        // static으로 선언되어 있지 않은데 인스턴스 없이 써서 오류. (인스턴스 메서드를 타입에서 호출해서 오류)
                        viewModel.addNote(text: text)
                        
                        text = ""
                        isPresented = false
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

