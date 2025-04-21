//
//  HistoryView.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/21/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query var notes: [ThankNote]
    @Binding var isShowing: Bool
    @Environment(\.modelContext) private var context

    @State private var selectedDate = Date()
    @State private var selectedNote: ThankNote? = nil
    @State private var editingText: String = ""
    @State private var isEditing = false
    @FocusState private var isTextEditorFocused: Bool

    @State private var currentMonthOffset = 0
    private let calendar = Calendar.current

    var body: some View {
        ZStack(alignment: .top) {
            // 배경 유지
            Color.clear.background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 툴바
                HStack {
                    Text("Pearl History")
                        .font(.headline)
                        .padding(.leading, 20)
                    Spacer()
                    Button {
                        withAnimation {
                            isShowing = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            //.foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.bottom, 30)

                // 월/년 및 이동 버튼
                HStack {
                    Button {
                        currentMonthOffset -= 1
                    } label: {
                        Image(systemName: "chevron.left")
                            //.foregroundColor(.white)

                    }

                    Spacer()

                    Text(monthYearText(for: currentDate))
                        .font(.title3)
                        .fontWeight(.medium)

                    Spacer()

                    Button {
                        currentMonthOffset += 1
                    } label: {
                        Image(systemName: "chevron.right")
                            //.foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 60)

                // 캘린더
                CalendarGridView(
                    notes: notes,
                    currentDate: currentDate,
                    selectedDate: $selectedDate,
                    selectedNote: $selectedNote
                )

                // 두루마리 노트 영역
                if let selectedNote = selectedNote {
                    ZStack {
                        Image("scroll_paper")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(maxWidth: 380)
                            //.padding(.top, 6)

                        VStack {
                            if isEditing {
                                TextEditor(text: $editingText)
                                    .focused($isTextEditorFocused)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button(action: {
                                                isTextEditorFocused = false
                                            }){ Image(systemName: "keyboard.chevron.compact.down.fill").foregroundColor(.indigo)}
                                        }
                                    }
                                    .padding(16)
                                    .onAppear {
                                        editingText = selectedNote.note
                                    }
                                    .frame(width: 280, height: 160)
                                    .background(.thinMaterial)
                                    .scrollContentBackground(.hidden)
                                    .lineSpacing(6)
                                    .cornerRadius(12)

                                Button {
                                    selectedNote.note = editingText
                                    try? context.save()
                                    isEditing = false
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                }
                            } else {
                                Text(selectedNote.note)
                                    .multilineTextAlignment(.center)
                                    .padding(16)
                                    .frame(width: 280, height: 160)
                                    .lineSpacing(6)
                                    .padding(.top, 18)

                                HStack(spacing: 20) {
                                    Button {
                                        isEditing = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }

                                    Button(role: .destructive) {
                                        context.delete(selectedNote)
                                        try? context.save()
                                        self.selectedNote = nil
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)
                }

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    var currentDate: Date {
        calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }

    func monthYearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy LLLL"
        return formatter.string(from: date)
    }
}

struct CalendarGridView: View {
    let notes: [ThankNote]
    let currentDate: Date
    @Binding var selectedDate: Date
    @Binding var selectedNote: ThankNote?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(weekdayHeaders, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(generateDaysInMonth(for: currentDate), id: \.self) { date in
                let note = notes.first(where: { calendar.isDate($0.timestamp, inSameDayAs: date) })
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let hasNote = note != nil
                let isPastNote = hasNote && Date().timeIntervalSince(note!.timestamp) > 10

                VStack {
                    if hasNote {
                        Image(isPastNote ? "pearl_yellow" : "pearl_pink")
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 44, height: 44)
                            .shadow(color: isSelected ? .white : .clear, radius: 6)
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
            }
        }
        .padding(.horizontal, 20)
    }

    var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols
    }

    func generateDaysInMonth(for date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else {
            return []
        }

        var days: [Date] = []
        let weekdayOffset = calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday

        if weekdayOffset > 0 {
            days += Array(repeating: Date.distantPast, count: weekdayOffset)
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        return days
    }
}
