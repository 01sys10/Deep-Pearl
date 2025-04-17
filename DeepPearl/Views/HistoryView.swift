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
    @Query var notes: [ThankNote] // fetch
    @State private var selectedDate: Date = Date()
    @Binding var isShowing: Bool
    
    // 중복 없이 날짜만 추출
    private var uniqueDates: [Date] {
        let dateSet = Set(notes.map {
            Calendar.current.startOfDay(for: $0.timestamp) // 시간 정보 무시하고 날짜만 기준으로.
        })
        return Array(dateSet).sorted(by: >)}
        
    var body: some View {
        NavigationStack{
            ZStack{
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) { // Carousel
                        HStack(spacing: 24) {
                            ForEach(uniqueDates, id: \.self) { date in
                                VStack { // pearl + day
                                    Image("pearl")
                                        .resizable()
                                    // .frame(maxWidth: .infinity, alignment: .center)
                                    // 선택된 날짜의 진주는 강조
                                    // TODO: 선택 구현
                                        .interpolation(.none)
                                        .frame(width: 70, height: 65)
//                                        .frame(width: selectedDate == date ? 48 : 30,
//                                               height: selectedDate == date ? 48 : 30)
                                        .scaleEffect(selectedDate == date ? 1.2 : 1.0)
                                        .shadow(radius: selectedDate == date ? 8 : 0)
                                        .onTapGesture {
                                            withAnimation(.easeInOut){
                                                selectedDate = date
                                            }
                                        }
                                    
                                    // 진주 밑 day 표시
                                    Text(format(date))
                                        .font(.caption)
                                }
                                .frame(width: 60)
                            }
                        }
//                        .padding(.horizontal)
                        .padding(20)
                        .background(Color.blue)
                    }
                    //.frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    // 날짜별 감사 기록 카드
//                    VStack(alignment: .leading, spacing: 12) {
//                        ForEach(filteredNotes(), id: \.self) { note in
//                            noteCard(for: note)
//                        }
//                    }
//                    .padding(.horizontal)
//                    
                    
                    // 이 if문은 뭐야
                    // 기록
                    if let selectedNote = notes.first(where: {
                        Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate)
                    }) {
                        Text(selectedNote.note)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .topLeading)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
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
    
    // 진주 밑 '일'만 표시
    // TODO: 요일도?
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    func formatFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
    
    /// "for filtering notes"
    /// - Returns: ViewModel 안에 있는 모든 note 중 selectedDate와 같은 날에 작성된 것만 골라서 리턴
    func filteredNotes() -> [ThankNote] {
        notes.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate)
        }
    }
    
    // 이건 무엇
    @ViewBuilder
    func noteCard(for note: ThankNote) -> some View {
        VStack(alignment: .leading) {
            let text = note.note
            let date = note.timestamp

            Text(text)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)

            Text(formatFull(date))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
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
