//
//  BullsEyeGame.swift
//  RevBullsEye
//
//  Created by Danijela Vrzan on 2020-06-07.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation

class BullsEyeGame {
    
    var currentValue: Int
    var targetValue: Int
    var score: Int
    var round: Int
    
    init(currentValue: Int, targetValue: Int, score: Int, round: Int) {
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.score = score
        self.round = round
    }
    
    func calculatePoints() -> (String, String) {
        let difference = abs(targetValue - currentValue)
        var points = 100 - difference
        
        score += points

        let title: String
        if difference == 0 {
            title = "Perfect!"
            points += 100
        } else if difference < 5 {
            title = "You almost had it!"
            if difference == 1 {
                points += 50
            }
        } else if difference < 10 {
            title = "Pretty good!"
        } else {
            title = "Not even close..."
        }
        
        let message = "You scored \(points) points"

        return (title, message)
    }
    
    func startNewGame() {
        score = 0
        round = 0
        startNewRound()
    }
    
    func startNewRound() {
        round += 1
        targetValue = Int.random(in: 1...100)
    }
    
}
