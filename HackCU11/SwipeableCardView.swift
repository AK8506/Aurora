//
//  SwipeableCardView.swift
//  HackCU11
//
//  Created by SohanBekkam on 3/1/25.
//

import SwiftUI

struct SwipeableCardView: View {
    let title: String
    let content: String
    
    // Callback to notify parent of swipe result
    var onSwipe: (Bool) -> Void
    
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: SwipeStatus = .none
    
    private let swipeThreshold: CGFloat = 100 // how far user must drag
    
    enum SwipeStatus {
        case none
        case like
        case dislike
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .padding()
        .overlay(
            // Visual feedback for swiping
            ZStack {
                if swipeStatus == .like {
                    Text("LIKE")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(20)
                        .border(Color.green, width: 4)
                        .rotationEffect(.degrees(-20))
                } else if swipeStatus == .dislike {
                    Text("NOPE")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(20)
                        .border(Color.red, width: 4)
                        .rotationEffect(.degrees(20))
                }
            }
            .opacity(swipeStatus == .none ? 0 : 1)
        )
        .offset(x: translation.width, y: 0)
        .rotationEffect(.degrees(Double(translation.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    translation = value.translation
                    if translation.width > 0 {
                        swipeStatus = .like
                    } else if translation.width < 0 {
                        swipeStatus = .dislike
                    } else {
                        swipeStatus = .none
                    }
                }
                .onEnded { value in
                    if translation.width > swipeThreshold {
                        // Swiped Right = like
                        withAnimation {
                            translation.width = 1000
                        }
                        onSwipe(true)
                    } else if translation.width < -swipeThreshold {
                        // Swiped Left = dislike
                        withAnimation {
                            translation.width = -1000
                        }
                        onSwipe(false)
                    } else {
                        // Snap back to center
                        withAnimation {
                            translation = .zero
                            swipeStatus = .none
                        }
                    }
                }
        )
        .animation(.spring(), value: translation)
    }
}
