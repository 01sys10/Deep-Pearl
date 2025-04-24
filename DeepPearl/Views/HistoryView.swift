//
//  HistoryView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/21/25.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query var notes: [ThankNote]
    @Environment(\.modelContext) private var context // 모델 삽입, 수정, 삭제할 때 사용

    @Binding var isShowing: Bool // MainView에서 HistoryView 표시 여부 제어하는 바인딩 값. for xmark
    @State private var selectedDate = Date() // 유저가 캘린더에서 선택한 날짜, 선택된 날짜에 해당하는 ThankNote를 필터링해 표시할 때 사용
    @State private var selectedNote: ThankNote? = nil // 유저가 선택한 날짜에 대응하는 Note 객체, 선택된 진주의 내용을 하단 두루마리 뷰에 표시하거나 편집할 때 사용
    @State private var editingText: String = "" // 편집 중인 텍스트를 임시로 저장하는 변수, 수정 완료 후 selectedNote.note에 반영
    @State private var showDeleteConfirmation = false
    @State private var hasAppeared = false // HistoryView의 초기 등장 애니메이션을 위한 플래그. for calendar opacity animation
    @State private var isEditing = false // 유저가 수정 버튼 눌렀는지 여부, true일 경우 텍스트에디터 활성화, 체크 버튼 나타남.
    @FocusState private var isTextEditorFocused: Bool
    
    @State private var currentMonthOffset = 0 // 현재 달력을 몇 개월 앞뒤로 이동했는지를 나타내는 오프셋
    private let calendar = Calendar.current
    
    var body: some View {
        
        ZStack {
            // 배경 유지
            Color.clear.background(.ultraThinMaterial)
                .ignoresSafeArea(.container, edges: .top)
            
            ScrollView{
                VStack(spacing: 0) {
                    // 상단 툴바
                    HStack {
                        Text("Pearl History")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.leading, 20)
                        Spacer()
                        Button {
                            withAnimation {
                                isShowing = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black.opacity(0.5))
                                .padding()
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // TODO: 월/년 및 이동 버튼 -> 별도 뷰로 분리 ok~
                    MonthNavigationView(currentMonthOffset: $currentMonthOffset, currentDate: currentDate, monthYearText: monthYearText)
                    
                    // 캘린더
                    CalendarGridView(
                        notes: notes,
                        currentDate: currentDate,
                        selectedDate: $selectedDate,
                        selectedNote: $selectedNote
                    )
                    .padding(.bottom, 30)
                    
                    // 두루마리 노트 영역
                    if let selectedNote = selectedNote {
                        ZStack {
                            Image("scroll_paper")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(maxWidth: 380)
                                .padding(.top, 16)
                                .offset(y: isEditing ? -160 : 0) // move up when editing

                            VStack {
                                if isEditing {
                                    // TODO: TextField로 수정 (axis로 multiline 구현)
                                    TextField("", text: $editingText, axis: .vertical)
                                        .lineLimit(2)
                                        .font(.system(size: 16))
                                        .focused($isTextEditorFocused)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 280)
                                        .padding(.top, 70)
                                        .onAppear {
                                            editingText = selectedNote.note
                                        }
                                        .onChange(of: editingText) { _, newValue in
                                            if newValue.count > 35 {
                                                editingText = String(newValue.prefix(35))
                                            }
                                        }
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(
                                                deadline: .now()
                                            ) {
                                                isTextEditorFocused = true
                                            }
                                        }
//
//                                    TextEditor(text: $editingText)
//                                        .onAppear {
//                                            DispatchQueue.main.asyncAfter(
//                                                deadline: .now()
//                                            ) {
//                                                isTextEditorFocused = true
//                                            }
//                                        }
//                                        .font(.system(size: 16))
//                                        .focused($isTextEditorFocused)
//
//                                        .padding(.horizontal, 10)
//                                        .padding(.top, 70)
//                                        .onAppear {
//                                            editingText = selectedNote.note
//                                        }
//                                        .frame(width: 280, height: 130)
//                                    //.background(.thinMaterial)
//                                        .scrollContentBackground(.hidden)
//                                        .lineSpacing(6)
//                                    //.border(.red, width: 4)
//                                        .onChange(of: editingText) { _, newValue in
//                                                if newValue.count > 35 {
//                                                    editingText = String(newValue.prefix(30))
//                                                }
//                                            }
//
                                    Button {
                                        selectedNote.note = editingText
                                        try? context.save()
                                        isEditing = false
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.black.opacity(0.5))
                                            .padding(.top, 40)
                                            //.border(.red, width: 4)
                                    }
                                } else {
                                    HStack(spacing: 20) {
                                        Text(FullDateText(for: selectedNote.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 20)
                                        Spacer()
                                        Button {
                                            isEditing = true
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.black.opacity(0.5))
                                        }
                                        
                                        Button(role: .destructive) {
                                            showDeleteConfirmation = true
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.black.opacity(0.5))
                                        }
                                        .alert("정말 삭제하겠어요?", isPresented: $showDeleteConfirmation){
                                            Button("취소", role: .cancel){ }
                                            Button("삭제", role: .destructive){
                                                context.delete(selectedNote)
                                                try? context.save()
                                                self.selectedNote = nil
                                                // if let noteToDelete = selectedNote {
                                                // DataManager.deleteNote(noteToDelete, in: context)
                                                // selectedNote = nil // ???: 왜 오류일까?
                                            }
                                            
                                        } message: {
                                            Text("이 감사 기록은 복구할 수 없어요.")
                                        }
                                    }
                                    .padding(.trailing, 20)
                                    //.border(.red, width: 4)
                                    // MARK: text
                                Text(selectedNote.note)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 280, height: 90)
                                    .lineSpacing(6)
                                    .padding(12)
                                    .padding(.bottom, 24)
                                    //.border(.red, width: 4)
                                    .font(.system(size: 16))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .offset(y: isEditing ? -160 : 0) // move up when editing
                        }
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 40)
//            .padding(.bottom, isEditing ? 350 : 0)
//            .animation(.easeInOut, value: isEditing)
        }
//        .toolbar {
//            ToolbarItemGroup(
//                placement: .keyboard
//            ) {
//                Spacer()
//                Button(action: {
//                    isTextEditorFocused = false
//                }) {
//                    Image(
//                        systemName:
//                            "keyboard.chevron.compact.down.fill"
//                    ).foregroundColor(.indigo)
//                }
//            }
//        }
        .opacity(hasAppeared ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: hasAppeared)  // HistoryView가 슬라이드 되기 직전에 캘린더 셀들이 먼저 계산되어 즉시 보이는 느낌 없애기 위해.
        
        .onAppear {
            hasAppeared = true

            if let latestNote = notes.sorted(by: { $0.timestamp > $1.timestamp }).first {
                selectedNote = latestNote
                selectedDate = Calendar.current.startOfDay(for: latestNote.timestamp)
            }
        }
    }
    
    var currentDate: Date {
        calendar.date(byAdding: .month, value: currentMonthOffset, to: Date())
        ?? Date()
    }
    
    func monthYearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy LLLL"
        return formatter.string(from: date)
    }
    
    func FullDateText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH시 mm분"
        return formatter.string(from: date)
    }
}

// MARK: Calendar struct
struct CalendarGridView: View {
    let notes: [ThankNote]
    let currentDate: Date
    @Binding var selectedDate: Date
    @Binding var selectedNote: ThankNote?
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        // LazyVGrid 안의 셀은 계산이 빠르니까 먼저 보이고
        // HistoryView 전체의 .transition(.move)는 그 다음 적용돼서 캘린더 셀만 먼저 띡 뜨게 된다.
        
        // Lazy는 계산 타이밍의 최적화(렌더링 비용 감소)지, 화면 표시 타이밍을 기다리는 게 아님.
        
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(weekdayHeaders, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(generateDaysInMonth(for: currentDate), id: \.self) { date in
                if let date = date {
                    let note = notes.first(where: {
                        calendar.isDate($0.timestamp, inSameDayAs: date)
                    })
                    let isSelected = calendar.isDate(
                        date,
                        inSameDayAs: selectedDate
                    )
                    let hasNote = note != nil
                    let isPastNote =
                    hasNote && Date().timeIntervalSince(note!.timestamp) > 10
                    
                    VStack {
                        if hasNote {
                            Image(isPastNote ? "pearl_yellow" : "pearl_pink")
                                .resizable()
                                .interpolation(.none)
                                .frame(width: 44, height: 44)
                                .shadow(
                                    color: isSelected ? .white : .clear,
                                    radius: 6
                                )
                        } else {
                            Image("pearl_gray")
                                .resizable()
                                .interpolation(.none)
                                .frame(width: 32, height: 32)
                                .opacity(0.3)
                        }
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        selectedDate = date
                        selectedNote = note
                    }
                } else {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols
    }
    
    func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: date)
              )
        else {
            return []
        }
        
        var days: [Date?] = []
        let weekdayOffset = calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday
        
        if weekdayOffset > 0 {
            days += Array(repeating: nil, count: weekdayOffset)
            // Date.distantPast 값이 매달 생겼던 이유: 매달 시작 요일이 달라지기 때문
            // 달력 셀 배열 만들 때, 월의 시작 요일이 수요일이면 앞쪽에 월/화 (2칸) 자리가 비어있어야 함.
            // 이 코드가 그 빈 자리를 nil로 채워 그 자리를 확실이 "날짜 아님"으로 처리.
        }
        
        for day in range {
            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstOfMonth
            ) {
                days.append(date)
            }
        }
        
        return days
    }
}

struct MonthNavigationView: View {
    @Binding var currentMonthOffset: Int
    let currentDate: Date
    let monthYearText: (Date) -> String
    
    var body: some View {
        HStack {
            Button {
                currentMonthOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black.opacity(0.5))
            }
            Spacer()
            Text(monthYearText(currentDate))
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
            Button {
                currentMonthOffset += 1
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 60)
    }
}

