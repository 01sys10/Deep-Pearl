//
//  ThankNote.swift
//  DeepPearl
//
//  Created by soyeonsoo on 4/16/25.
//

import Foundation

import SwiftData

@Model
class ThankNote {
    var note: String
    var timestamp: Date
    var isRecalled: Bool = false // 상기 여부
    var pearlSize: CGFloat = CGFloat.random(in: 40...70) // random size pearl
    
    init(note: String, timestamp: Date = .now) {
        self.note = note
        self.timestamp = timestamp
    }
}


// Schema named ThankNote
// two attributes
// : note(String type), timestamp(Date type)

// 메인 화면 하단의 add 버튼을 누르면 감사 기록을 할 수 있는 페이지로 넘어간다.
// 사용자가 기록을 완료, save하면
// 1. db에 note와 timestamp가 저장된다.
// 2. 진주가 만들어지고 메인 화면 하단에 동동 떠있게 된다.

// 진주가 만들어진지 일주일이 지나면 진주의 색이 바뀌고 화면의 상단으로 떠오른다.
// 상단에 떠오른 진주를 사용자가 터치하면 그 진주에 기록된 기록을 말풍선 형태로 확인할 수 있다.
// 이 과정을 '상기'라고 하는데, 상기를 완료하면 메인 화면에 있는 고샤(물고기)가 자란다(이미지 교체).

// 메인 화면 우측 상단의 보관함 버튼을 누르면 그동안 기록한 감사 기록을 날짜별 캐러셀 형태로 확인할 수 있는 history 페이지가 오른쪽에서 나온다.
// history 창의 우측 상단에 닫기 버튼이 있다. 닫으면 메인 화면으로 돌아간다.
// 캐러셀은 월별로 만들어지며 월 간 이동은 화살표 탭으로 가능하다.
// 상단에 가로로 캐러셀이 있다. 7일치 진주가 한 화면에 보이며 가로로 드래그해 볼 수 있다.
// 디비에 저장된 날짜만 보인다. 기록한 날짜만 보인다는 뜻이다.
// 만들어진지 일주일이 안 된 진주는 분홍색, 일주일이 넘은 진주는 노란색으로 보인다.
// 드래그하다가 선택된 날짜는 중앙에 배치되며 크기나 형태가 강조되어 선택되었음을 나타낸다.
// 선택된 진주 밑에 텍스트 박스가 있다. 텍스트 박스 안에서 진주에 담긴 기록을 확인한다.
// 텍스트 박스 우측 하단에는 수정, 삭제 버튼이 있다. 수정은 별도의 확인 없이 텍스트 편집 화면이 되고, 삭제는 alert로 확인 후 삭제된다.
