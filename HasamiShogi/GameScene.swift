//
//  GameScene.swift
//  HasamiShogi
//
//  Created by g-2016 on 2015/02/07.
//  Copyright (c) 2015年 g-2016. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    enum GameState:Int {
        case selectPiece
        case movePiece
        case enemyTurn
    }

    enum boardState:Int {
        case playerPiece
        case enemyPiece
        case empty
    }
    
    let boardSize = 9
    var playerPoint = 0
    var enemyPoint = 0
    var board = [[boardState]]()
    
    override func didMoveToView(view: SKView) {
        self.initBoard()
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func initBoard(){
        for h in 0..<boardSize {
            var boardCol = [boardState]()
            
            for w in 0..<boardSize {
                if h == 0 {
                    boardCol.append(boardState.playerPiece)
                }else if h == boardSize - 1 {
                    boardCol.append(boardState.enemyPiece)
                }else {
                    boardCol.append(boardState.empty)
                }
            }
        }
    }
    
    func displayBoard(){
        
    }
}
