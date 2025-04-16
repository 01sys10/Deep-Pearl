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
    @State private var selectedDate: Date = Date()
    @Binding var isShowing: Bool
    
    // 날짜만 추출    
    private var uniqueDates: [Date] {
        // let dateSet = Set(viewModel.notes.map { Calendar.current.startOfDay(for: $0.timestamp) })
        // timestamp는 옵셔널, startOfDay는 옵셔널을 못 받는다. 꼭 Date여야 한다.
        let dateSet = Set(notes.map {
            Calendar.current.startOfDay(for: $0.timestamp ?? Date())
        })
        return Array(dateSet).sorted(by: >)}
        
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        Spacer()
                        
                        ForEach(uniqueDates, id: \.self) { date in
                            VStack {
                                Image("pearl")
                                    .resizable()
                                    .frame(width: selectedDate == date ? 48 : 30,
                                           height: selectedDate == date ? 48 : 30)
                                    .scaleEffect(selectedDate == date ? 1.2 : 1.0)
                                    .shadow(radius: selectedDate == date ? 8 : 0)
                                    .animation(.easeInOut, value: selectedDate == date)
                                    .onTapGesture {
                                        selectedDate = date
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text(format(date))
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
//                Divider()
//                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredNotes(), id: \.self) { note in
                        noteCard(for: note)
                    }
                }
                .padding(.horizontal)
                
                
                
                if let selectedNote = notes.first(where: {
                    Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate)
                }) {
                    Text(selectedNote.note)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Spacer()

            }
            .padding(.top)
            .background(.thinMaterial)
            .edgesIgnoringSafeArea(.all)
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Pearl History")
                        .font(.headline)
                        .fontWeight(.bold)
                    //.foregroundColor(.white)
                }
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
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
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
            Calendar.current.isDate($0.timestamp ?? Date(), inSameDayAs: selectedDate)
        }
    }
    
    @ViewBuilder
    func noteCard(for note: ThankNote) -> some View {
        VStack(alignment: .leading) {
            let text = note.note ?? ""
            let date = note.timestamp ?? Date()

//            Text(text)
//                .padding()
//                .background(.ultraThinMaterial)
//                .cornerRadius(12)

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


#Preview {
    HistoryView(isShowing: .constant(true))
        .modelContainer(for: ThankNote.self, inMemory: true)
}
