//
//  HistoryView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI
import SwiftData

// TODO: 좌우 월 이동


struct HistoryView: View {
    @Query var notes: [ThankNote]
    // ModelContext에 접근하지 않고도 데이터를 모두 동일하게 받아올 수 있다.
    
    @State private var selectedDate: Date = Date()
    @State private var selectedNote: ThankNote? = nil
    @Binding var isShowing: Bool
    
    @State private var editingText: String = ""
    @State private var currentIndex: Int = 0
    @FocusState private var isTextEditorFocused: Bool
    
    //    @State private var dragOffset: CGFloat = 0
    //
    //
    //    @State private var scrollOffset: CGFloat = 0
    //    @State private var cardWidth: CGFloat = 80
    //
    @State private var isEditing: Bool = false
    @Environment(\.modelContext) private var context
    
    
    
    // 중복 없이 날짜만 추출
    private var uniqueDates: [Date] {
        let dateSet = Set(notes.map {
            Calendar.current.startOfDay(for: $0.timestamp) // 시간 정보 무시하고 날짜만 기준으로.
        })
        return Array(dateSet).sorted(by: >)}
    
    var noteBinding: Binding<String>? {
        guard let note = selectedNote else { return nil }
        
        return Binding<String>(
            get: { note.note },
            set: { newText in
                if isEditing {
                    note.note = newText
                }
            }
        )
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            VStack(spacing: 20) {
                Spacer()
                // MARK: - carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(uniqueDates, id: \.self) { date in // 노트 작성된 날짜 돌면서
                            VStack { // pearl + day
                                // Image(note.isFloatingUp ? "pearl_yellow" : "pearl_pink")
                                //                                Image("pearl")
                                //                                    .resizable()
                                //                                // TODO: 드래그 선택 캐러셀 구현
                                //                                // 선택된 날짜의 진주 강조
                                //                                    .interpolation(.none)
                                //                                    .frame(width: selectedDate == date ? 58 : 45,
                                //                                           height: selectedDate == date ? 58 : 45)
                                //                                    .scaleEffect(selectedDate == date ? 1.2 : 1.0)
                                //                                    .shadow(color: .white, radius: selectedDate == date ? 8 : 0)
                                //                                    .onTapGesture {
                                //                                        withAnimation(.easeInOut) {
                                //                                            selectedDate = date
                                //
                                //                                            // 1. 날짜별 노트 목록 저장
                                //                                            let notesForDate = filteredNotes(for: date)
                                //
                                //                                            // 2. 첫 번째 노트 추출
                                //                                            if let firstNote = notesForDate.first {
                                //                                                selectedNote = firstNote
                                //                                                editingText = firstNote.note
                                //                                            } else {
                                //                                                selectedNote = nil
                                //                                                editingText = ""
                                if let note = filteredNotes(for: date).first {
                                    let isOlderThan10s = Date().timeIntervalSince(note.timestamp) >= 10
                                    let imageName = isOlderThan10s ? "pearl_yellow" : "pearl_pink"
                                    let pearlSize = note.pearlSize
                                    
                                    Image(imageName)
                                        .resizable()
                                        .interpolation(.none)
                                        .frame(width: selectedDate == date ? pearlSize + 10 : pearlSize,
                                               height: selectedDate == date ? pearlSize + 10 : pearlSize)
                                        .scaleEffect(selectedDate == date ? 1.2 : 1.0)
                                        .shadow(color: .white, radius: selectedDate == date ? 8 : 0)
                                        .onTapGesture {
                                            withAnimation(.easeInOut) {
                                                if selectedDate == date {
                                                    selectedNote = nil
                                                    editingText = ""
                                                } else {
                                                    selectedDate = date
                                                    if let firstNote = filteredNotes(for: date).first {
                                                        selectedNote = firstNote
                                                        editingText = firstNote.note
                                                    } else {
                                                        selectedNote = nil
                                                        editingText = ""
                                                    }
                                                    isEditing = false
                                                }
                                            }
                                            // isEditing = false
                                        }
                                }
                                
                                // 진주 밑 dd(EE)
                                Text(format(date))
                                    .font(.caption)
                            }
                            .frame(width: 60) // (pearl + day) 끼리의 간격
                        }
                    }
                    .padding(20)
                    //.background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // 날짜별 감사 기록 카드
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredNotes(), id: \.self) { note in
                        noteCard(for: note)
                    }
                }
                Spacer()
                Spacer()
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .padding(.top)
            .background(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            
            // 닫기 버튼
            Button {
                withAnimation {
                    isShowing = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .shadow(radius: 3)
            }
            .padding(.top, 50)
            .padding(.trailing, 25)
        }
        .background(
            Color.black.opacity(0)
                .blur(radius: 15)
        )
        .ignoresSafeArea()
    }
    
    /// - Returns:  일(요일)
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd(EE)"
        return formatter.string(from: date)
    }
    
    func formatFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    /// "for filtering notes"
    /// - Returns: ViewModel 안에 있는 모든 note 중 selectedDate와 같은 날에 작성된 것만 골라서 리턴
    func filteredNotes(for date: Date? = nil) -> [ThankNote] {
        let targetDate = date ?? selectedDate
        var result: [ThankNote] = [] // fetch(read)
        
        for note in notes {
            if Calendar.current.isDate(note.timestamp, inSameDayAs: targetDate) {
                result.append(note)
            }
        }
        
        return result
    }
    
    
    @ViewBuilder
    func noteCard(for note: ThankNote) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .trailing){
                if note == selectedNote && isEditing {
                    TextEditor(text: $editingText)
                        .focused($isTextEditorFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button(action: {
                                    isTextEditorFocused = false
                                }){ Image(systemName: "keyboard.chevron.compact.down.fill")}
                            }
                        }
                        .padding(24)
                        .lineSpacing(6)
                        .background(.thinMaterial)
                        .scrollContentBackground(.hidden)
                        .cornerRadius(12)
                    
                    if note == selectedNote {
                        if isEditing {
                            Button(action: {
                                isEditing.toggle()
                                selectedNote?.note = editingText
                                try? context.save()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                //.background(.green)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                        
                    }
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        Text(note.note)
                            .padding(56)
                            .lineSpacing(6)
                            .background(.thinMaterial)
                            .cornerRadius(12)
                        
                        if note == selectedNote {
                            HStack(spacing: 10) {
                                Button(action: {
                                    isEditing = true
                                    selectedNote = note
                                    editingText = note.note
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.white)
                                        .padding(2)
                                    //.background(.blue)
                                    //.cornerRadius(8)
                                }
                                
                                Button(role: .destructive){
                                    context.delete(note)
                                    try? context.save()
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                        .padding(2)
                                    //.background(.red)
                                    //.cornerRadius(8)
                                }
                            }
                            .padding(12)
                            
                        }
                        
                    }
                    Text(formatFull(note.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(alignment: .trailing)
                }
                
            }
            .padding(12)
        }
    }
    func makeNoteBinding(for note: ThankNote) -> Binding<String> {
        Binding<String>(
            get: { note.note },
            set: { newText in
                if isEditing {
                    note.note = newText
                }
            }
        )
    }
    
}


// TODO: 진주 색상 처리
/*
 let isOlderThanWeek = Calendar.current.dateComponents([.day], from: note.timestamp, to: Date()).day ?? 0 >= 7
 
 Image(isOlderThanWeek ? "pearl_yellow" : "pearl_pink")
 */


//#Preview {
//    HistoryView(isShowing: .constant(true))
//        .modelContainer(for: ThankNote.self, inMemory: true)
//}
