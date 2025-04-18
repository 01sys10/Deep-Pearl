//
//  HistoryView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI
import SwiftData

// TODO: calendar carousell

struct HistoryView: View {
    @Query var notes: [ThankNote]
    // ModelContext에 접근하지 않고도 데이터를 모두 동일하게 받아올 수 있다.
    
    @State private var selectedDate: Date = Date()
    @State private var selectedNote: ThankNote? = nil
    @Binding var isShowing: Bool
    
    @State private var editingText: String = ""
    @State private var currentIndex: Int = 0
    
    
    
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
        NavigationStack{
            ZStack{
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // MARK: - carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(uniqueDates, id: \.self) { date in
                                VStack { // pearl + day
                                    Image("pearl")
                                        .resizable()
                                    // 선택된 날짜의 진주는 강조
                                    // TODO: 드래그 선택 캐러셀 구현
                                        .interpolation(.none)
                                    //.frame(width: 70, height: 65)
                                        .frame(width: selectedDate == date ? 58 : 45,
                                               height: selectedDate == date ? 58 : 45)
                                        .scaleEffect(selectedDate == date ? 1.2 : 1.0)
                                        .shadow(radius: selectedDate == date ? 8 : 0)
                                        .onTapGesture {
                                            withAnimation(.easeInOut) {
                                                selectedDate = date
                                                
                                                // 1. 날짜별 노트 목록 저장
                                                let notesForDate = filteredNotes(for: date)
                                                
                                                // 2. 첫 번째 노트 추출
                                                if let firstNote = notesForDate.first {
                                                    selectedNote = firstNote
                                                    editingText = firstNote.note
                                                } else {
                                                    selectedNote = nil
                                                    editingText = ""
                                                }
                                                isEditing = false
                                            }
                                        }
                                    
                                    // 진주 밑 dd(EE)
                                    Text(format(date))
                                        .font(.caption)
                                }
                                .frame(width: 60)
                            }
                        }
                        .padding(20)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                     .padding(50)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    //                     날짜별 감사 기록 카드
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(filteredNotes(), id: \.self) { note in
                            noteCard(for: note)
                        }
                    }
                    .padding(.horizontal)
                    
                    //
                    
                    
                    //                    TabView(selection: $currentIndex) {
                    //                        ForEach(uniqueDates.indices, id: \.self) { index in
                    //                            let date = uniqueDates[index]
                    //                            VStack(spacing: 6) {
                    //                                Image("pearl")
                    //                                    .resizable()
                    //                                    .interpolation(.none)
                    //                                    .scaledToFit()
                    //                                    .frame(width: currentIndex == index ? 60 : 40,
                    //                                           height: currentIndex == index ? 60 : 40)
                    //                                    .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                    //                                    .shadow(radius: currentIndex == index ? 10 : 0)
                    //
                    //                                Text(format(date))
                    //                                    .font(.caption)
                    //                                    .foregroundStyle(currentIndex == index ? .primary : .secondary)
                    //                            }
                    //                            .frame(maxWidth: .infinity)
                    //                            .tag(index)
                    //                        }
                    //                    }
                    //                    .frame(height: 100)
                    //                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    //                    .onChange(of: currentIndex) {
                    //                        selectedDate = uniqueDates[currentIndex]
                    //                    }
                    
                    
                    
                    //                    GeometryReader { proxy in
                    //                        ScrollView(.horizontal, showsIndicators: false) {
                    //                            HStack(spacing: 16) {
                    //                                ForEach(uniqueDates, id: \.self) { date in
                    //                                    GeometryReader { geo in
                    //                                        let midX = geo.frame(in: .global).midX
                    //                                        let screenMidX = proxy.size.width / 2
                    //                                        let distance = abs(screenMidX - midX)
                    //                                        let scale = max(0.8, 1.3 - (distance / 200))
                    //                                        let opacity = max(0.3, 1.0 - (distance / 300))
                    //
                    //                                        VStack(spacing: 6) {
                    //                                            Image("pearl")
                    //                                                .resizable()
                    //                                                .interpolation(.none)
                    //                                                .scaledToFit()
                    //                                                .frame(width: 50, height: 50)
                    //                                                .scaleEffect(scale)
                    //                                                .opacity(opacity)
                    //                                                .shadow(radius: selectedDate == date ? 10 : 0)
                    //                                                .onAppear {
                    //                                                    if midX > screenMidX - 5 && midX < screenMidX + 5 {
                    //                                                        selectedDate = date
                    //                                                    }
                    //                                                }
                    //
                    //                                            Text(format(date))
                    //                                                .font(.caption)
                    //                                        }
                    //                                        .frame(width: cardWidth, height: 80)
                    //                                    }
                    //                                    .frame(width: cardWidth, height: 100)
                    //                                }
                    //                            }
                    //                            .padding(.horizontal, (proxy.size.width - cardWidth) / 2)
                    //                        }
                    //                        .frame(height: 100)
                    //                    }
                    
                    
                    // MARK: - notes & buttons
                    if let selectedNote = selectedNote {
                        VStack(alignment: .leading) {
                            Text(selectedNote.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            TextEditor(text: $editingText)
                                .disabled(!isEditing)
                                .frame(minHeight: 150)
                            
                            HStack {
                                Button(action: {
                                    isEditing.toggle()
                                    if !isEditing {
                                        selectedNote.note = editingText
                                        try? context.save()
                                    }
                                }) {
                                    Text(isEditing ? "완료" : "수정")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(.blue)
                                        .cornerRadius(8)
                                }
                                
                                Button(role: .destructive) {
                                    context.delete(selectedNote)
                                    try? context.save() //
                                    self.selectedNote = nil //
                                    self.editingText = ""
                                } label: {
                                    Text("삭제")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(.red)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.top, 5)
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .padding(.top)
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //                ToolbarItem(placement: .principal) {
                    //                    Text("Pearl History")
                    //                        .font(.headline)
                    //                        .fontWeight(.bold)
                    //                    //.foregroundColor(.white)
                    //                }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation{
                                isShowing = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
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
        var result: [ThankNote] = [] // fetch(read) 함수 따로 없이 이렇게 가져오나?

        for note in notes {
            if Calendar.current.isDate(note.timestamp, inSameDayAs: targetDate) {
                result.append(note)
            }
        }

        return result
    }
    
    
    @ViewBuilder
    func noteCard(for note: ThankNote) -> some View {
        VStack(alignment: .leading) {
            let text = note.note
            let date = note.timestamp
            
            Text(text)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            
            Text(formatTime(date))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(alignment: .trailing)
            
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

// TODO: UD

// TODO: 좌우 월 이동

#Preview {
    HistoryView(isShowing: .constant(true))
        .modelContainer(for: ThankNote.self, inMemory: true)
}
