//
//  SwipeableCardView.swift
//  HackCU11
//
//  Created by SohanBekkam on 3/1/25.


import SwiftUI

struct SwipeableCardView: View {
    let title: String
    let content: String
    var onSwipe: (Bool) -> Void

    @State private var translation: CGSize = .zero
    @State private var swipeStatus: SwipeStatus = .none
    @State private var shouldRemove = false

    private let swipeThreshold: CGFloat = 100

    enum SwipeStatus {
        case none, like, dislike
    }

    var body: some View {
        if !shouldRemove { // Prevents flashing
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
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
            .padding()
            .overlay(
                ZStack {
                    if swipeStatus == .like {
                        Text("LIKE")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding(20)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .rotationEffect(.degrees(-20))
                            .opacity(0.8)
                    } else if swipeStatus == .dislike {
                        Text("NOPE")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(20)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .rotationEffect(.degrees(20))
                            .opacity(0.8)
                    }
                }
                .opacity(swipeStatus == .none ? 0 : 1)
            )
            .offset(x: translation.width)
            .rotationEffect(.degrees(Double(translation.width / 25))) // Less aggressive tilt
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                        swipeStatus = translation.width > 0 ? .like : .dislike
                    }
                    .onEnded { value in
                        if abs(translation.width) > swipeThreshold {
                            let isLiked = translation.width > 0
                            withAnimation(.easeOut(duration: 0.4)) { // Smooth exit
                                translation.width = isLiked ? 1000 : -1000
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                shouldRemove = true // Remove after animation
                                onSwipe(isLiked)
                            }
                        } else {
                            withAnimation(.spring()) {
                                translation = .zero
                                swipeStatus = .none
                            }
                        }
                    }
            )
            .animation(.spring(), value: translation)
        }
    }
}
