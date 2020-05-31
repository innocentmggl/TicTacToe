//
//  ContentView.swift
//  TicTacToe
//
//  Created by Innocent Magagula on 2020/05/30.
//  Copyright © 2020 Innocent Magagula. All rights reserved.
//

import SwiftUI
import Combine

enum BoardCellStatus {
    case empty
    case o
    case x
}

class Square: ObservableObject {

    @Published var status: BoardCellStatus

    init(status: BoardCellStatus) {
        self.status = status
    }
}

class ModelBoard {
    var squares = [Square]()
    init() {
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
    func resetGame() {
        for i in 0...8 {
            squares[i].status = .empty
        }
    }
    var gameOver: (BoardCellStatus, Bool) {
        get {
            if isWinningCombination != .empty {
                return (isWinningCombination, true)
            } else {
                for i in 0...8 {
                    if squares[i].status == .empty {
                        return (.empty, false)
                    }
                }
                return (.empty, true)
            }
        }
    }
    private var isWinningCombination:BoardCellStatus {
        get {
            if let check = self.getWinner([0, 1, 2]) {
                return check
            } else  if let check = self.getWinner([3, 4, 5]) {
                return check
            }  else  if let check = self.getWinner([6, 7, 8]) {
                return check
            }  else  if let check = self.getWinner([0, 3, 6]) {
                return check
            }  else  if let check = self.getWinner([1, 4, 7]) {
                return check
            }  else  if let check = self.getWinner([2, 5, 8]) {
                return check
            }  else  if let check = self.getWinner([0, 4, 8]) {
                return check
            }  else  if let check = self.getWinner([2, 4, 6]) {
                return check
            }
            return .empty
        }
    }

    //check for a move that will make .o win the game
    //if none check possible winning move for .x and block it
    //if no winning move to block calculate best move closer to winning
    // this is done by the minimax algorithm

    private func getWinner(_ indexes: [Int]) -> BoardCellStatus? {
        var homeCounter:Int = 0
        var visitorCounter:Int = 0
        for anIndex in indexes {
            let aSquare = squares[anIndex]
            if aSquare.status == .x {
                homeCounter = homeCounter + 1
            } else if aSquare.status == .o {
                visitorCounter = visitorCounter + 1
            }
        }
        if homeCounter == 3 {
            return .x
        } else if visitorCounter == 3 {
            return .o
        }
        return nil
    }

    private func aiMove() {
        var anIndex = Int.random(in: 0 ... 8)
        while (makeMove(index: anIndex, player: .o) == false && gameOver.1 == false) {
            anIndex = Int.random(in: 0 ... 8)
        }
    }

    func makeMove(index: Int, player:BoardCellStatus) -> Bool {
        if squares[index].status == .empty {
            squares[index].status = player
            if player == .x {
                //delay half a second for before making AI move
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.aiMove()
                }
            }
            return true
        }
        return false
    }
}

struct SquareView: View {
    @ObservedObject var dataSource: Square
    var action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Text((self.dataSource.status != .empty) ? (self.dataSource.status != .o) ? "X" : "0" : " ")
                .font(.largeTitle)
                .foregroundColor(Color.black)
                .frame(minWidth: 60, minHeight: 60)
                .background(Color.gray)
                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        }
    }
}

struct ContentView : View {
    private var board = ModelBoard()
    @State private var isGameOver = false

    func buttonAction(_ index: Int) {
        _ = self.board.makeMove(index: index, player: .x)
        self.isGameOver = self.board.gameOver.1
    }

    var body: some View {
        VStack {
            HStack {
                SquareView(dataSource: board.squares[0]) { self.buttonAction(0) }
                SquareView(dataSource: board.squares[1]) { self.buttonAction(1) }
                SquareView(dataSource: board.squares[2]) { self.buttonAction(2) }
            }
            HStack {
                SquareView(dataSource: board.squares[3]) { self.buttonAction(3) }
                SquareView(dataSource: board.squares[4]) { self.buttonAction(4) }
                SquareView(dataSource: board.squares[5]) { self.buttonAction(5) }
            }
            HStack {
                SquareView(dataSource: board.squares[6]) { self.buttonAction(6) }
                SquareView(dataSource: board.squares[7]) { self.buttonAction(7) }
                SquareView(dataSource: board.squares[8]) { self.buttonAction(8) }
            }
        }
        .alert(isPresented: $isGameOver) {
            Alert(title: Text("Game Over"),
                  message: Text(self.board.gameOver.0 != .empty ?
                    (self.board.gameOver.0 == .x) ? "You Win!" : "AI Wins!"
                    : "Parity"), dismissButton: Alert.Button.destructive(Text("Ok")){
                        self.board.resetGame()
            })
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
