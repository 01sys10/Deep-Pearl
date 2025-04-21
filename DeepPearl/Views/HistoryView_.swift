//
//  HistoryView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/14/25.
//

import SwiftUI
import SwiftData

// TODO: 좌우 월 이동 버튼

struct HistoryView_: View {
    @Query var notes: [ThankNote]
    // ModelContext에 접근하지 않고도 데이터를 모두 동일하게 받아올 수 있다.
    
    @State private var selectedDate: Date = Date()
    @State private var selectedNote: ThankNote? = nil
    @Binding var isShowing: Bool
    
    @State private var editingText: String = ""
    @State private var currentIndex: Int = 0
    @FocusState private var isTextEditorFocused: Bool
    
    @State private var isEditing: Bool = false
    @Environment(\.modelContext) private var context
    
    
    
    // 중복 없이 날짜만 추출
    private var uniqueDates: [Date] {
        let dateSet = Set(notes.map {
            Calendar.current.startOfDay(for: $0.timestamp) // 시간 정보 무시하고 날짜만 기준으로.
        })
        
        return Array(dateSet).sorted(by: >)}
    
    // noteBinding 프로퍼티
    // selectedNote가 선택되어 있을 때만 동작하는 Binding<String> 생성기
    // HistoryView 안에서 단 하나의 note를 바인딩할 수 있게 해준다.
    // 항상 selectedNote만 바인딩 대상이니까 여러 개의 note에 대한 동시 접근은 불가능
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
    
    /*
     HistoryView 캐러셀 버리고 전체 캘린더가 한눈에 보이는 뷰로 바꾸자.
     배경은 지금 배경을 유지한다.
     툴바 위치에는 Pearl History라는 제목이 좌상단에, 닫기 버튼이 우상단에 있다.
     그 밑 중앙에 "월 년" (ex: April 2025)가 쓰여있고 양옆으로 월 간 이동을 할 수 있는 버튼이 있다.
     그 아래로 한 달 캘린더가 보인다. 각 일수 위에 그 날 만들어진 진주가 보인다(각각 섀도우 효과). 감사 기록을 하지 않은 날짜 위에는 흑백 처리된, 크기가 중간으로 일정한 진주가 있다.
     특정 날짜의 진주를 선택하면 진주가 하이라이트된다(white color shadow로 빛나는 효과).
     하이라이트된 진주가 담고 있는 note가 캘린더 아래 텍스트 박스 공간에서 보인다.
     텍스트 박스 공간은 픽셀 아트로 표현된 두루마리 종이 이미지이다. (내가 이미지 넣을거야)
     두루마리 이미지 위, 텍스트 우하단에 수정버튼과 삭제버튼이 나란히 있다.
     (note 작성 시간은 어디에 둘지 모르겠으니 일단 안 넣는걸로 하고)


     (이건 나중에 하자. AddModalViewd에서 처리해야겠지.)
     note의 글자 수 제한을 2줄 정도로 줘서 이미지가 늘어나지 않아도 그 위에 텍스트가 다 담기도록 한다.
     */
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            VStack(spacing: 20) {
                Spacer()
                // MARK: - carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(uniqueDates, id: \.self) { date in // 노트 작성된 날짜 돌면서
                            VStack { // pearl + day
                                // TODO: 드래그 선택 캐러셀 구현

                                if let note = filteredNotes(for: date).first {
                                    let isOlderThan10s = Date().timeIntervalSince(note.timestamp) >= 10
                                    let imageName = isOlderThan10s ? "pearl_yellow" : "pearl_pink"
                                    let pearlSize = note.pearlSize
                                    
                                    Image(imageName)
                                        .resizable()
                                        .interpolation(.none)
                                        .frame(width: selectedDate == date ? pearlSize + 20 : pearlSize,
                                               height: selectedDate == date ? pearlSize + 20 : pearlSize)
                                        .scaleEffect(selectedDate == date ? 1.2 : 1.0)
                                        .shadow(color: .white, radius: selectedDate == date ? 8 : 0)
                                        .onTapGesture {
                                            withAnimation(.easeInOut) {
                                                if selectedDate == date {
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
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)

                }
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .center)
                
                
                // MARK: note text
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
    
    // MARK: formatters
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
    
    
    // MARK: noteCard function
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
                                        .font(.system(size: 14, weight: .bold))
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
                                        .font(.system(size: 14, weight: .bold))

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
    
    // 파라미터로 원하는 note 객체를 전달하면
    // 그 객체의 note.note를 바인딩으로 감싸서 리턴
    
    // 특정 ThankNote 인스턴스에 대해 note.note를 읽고 수정할 수 있도록 Binding타입 리턴
    // TextEditor같은 입력창은 보통 Binding<String>을 필요로 한다.
    // ThankNote는 그냥 객체고, 텍스트에디터는 바인딩타입을 요구하니까 note.note라는 속성을 바인딩처럼 다룰 수 있도록 포장하는 역할
    // 사용자가 텍스트 수정할 때 직접 note.note속성에 반영될 수 있다.
    // 여러 노트 중 어떤 걸 수정하고 싶은지 지정해서 사용 가능
    // 유연하게 noteCard(for:) 같은 곳에서 각 note별로 바인딩을 줄 수 있다.
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
