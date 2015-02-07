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

    enum BoardState:Int {
        case playerPiece
        case enemyPiece
        case empty
    }
    
    var viewSize:CGSize!
    var pieceSize:CGFloat!
    var space:CGFloat!
    var scale:CGFloat!
    let boardSize = 9
    var board = [[BoardState]]()
    
    var playerPoint = 0
    var enemyPoint = 0
    var gameState:GameState!
    
    let boardImage = SKTexture(imageNamed: "ban")
    let playerPieceImage = SKTexture(imageNamed: "player")
    let playerPieceHoverImage = SKTexture(imageNamed: "player_hover")
    let enemyPieceImage = SKTexture(imageNamed: "enemy_r")
    let enemyPieceHoverImage = SKTexture(imageNamed: "enemy_hover_r")
    let masuHoverImage = SKTexture(imageNamed: "masu_hover")
    
    var boardSprite:SKSpriteNode!
    var playerPointLabel:SKLabelNode!
    var enemyPointLabel:SKLabelNode!
    var wait:SKLabelNode!
    var touchName = ""
    
    override func didMoveToView(view: SKView) {
        viewSize = self.view?.frame.size
        
        gameState = GameState.selectPiece
        self.initBoard()
        self.displayBoard()
        self.displayLabel()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch:AnyObject in touches {
            let location = self.nodeAtPoint(touch.locationInNode(self))
            
            if let name = location.name {
                switch gameState! {
                case GameState.selectPiece:
                    println("select")
                    if let selectName = name.rangeOfString("player") {
                        (location as SKSpriteNode).texture = playerPieceHoverImage
                        gameState = GameState.movePiece
                        touchName = name
                    }
                case GameState.movePiece:
                    println("move")
                    if name == touchName {
                        (location as SKSpriteNode).texture = playerPieceImage
                        gameState = GameState.selectPiece
                    }
                case GameState.enemyTurn:
                    println("enemy turn")
                default:
                    println("error")
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func initBoard(){
        for h in 0..<boardSize {
            var boardCol = [BoardState]()
            
            for w in 0..<boardSize {
                switch h {
                case 0:
                    boardCol.append(BoardState.playerPiece)
                case boardSize - 1:
                    boardCol.append(BoardState.enemyPiece)
                default:
                    boardCol.append(BoardState.empty)
                }
            }
            board.append(boardCol)
        }
        
        scale = self.view!.frame.size.width / boardImage.size().width
        pieceSize = playerPieceImage.size().width * scale
        space = ((viewSize.width - pieceSize * 9) / 2) * scale
    }
    
    func displayBoard(){
        boardSprite = SKSpriteNode(texture: boardImage)
        boardSprite.setScale(scale)
        boardSprite.position = CGPointMake(viewSize.width / 2, viewSize.height / 2)
        self.addChild(boardSprite)
        
        for h in 0..<boardSize {
            for w in 0..<boardSize {
                switch board[h][w] {
                case BoardState.playerPiece:
                    var playerPiece = SKSpriteNode(texture: playerPieceImage)
                    
                    playerPiece.anchorPoint = CGPointMake(-0.2, 0.85)
                    playerPiece.setScale(scale)
                    playerPiece.position = self.setPos(h, w)
                    playerPiece.name = "player\(w)"
                    self.addChild(playerPiece)
                    
                case BoardState.enemyPiece:
                    var enemyPiece = SKSpriteNode(texture: enemyPieceImage)
                    
                    enemyPiece.anchorPoint = CGPointMake(-0.25, 0.9)
                    enemyPiece.setScale(scale)
                    enemyPiece.position = self.setPos(h,w)
                    self.addChild(enemyPiece)
                default:
                    println("empty")
                }
            }
        }
    }
    
    func setPos(h:Int,_ w:Int) -> CGPoint {
       return CGPointMake(CGFloat(space) + CGFloat(w) * pieceSize,CGFloat(space) + CGFloat(h-4) * pieceSize + boardSprite.position.y)
    }
    
    func displayLabel(){
        playerPointLabel = SKLabelNode(text: "先手:\(playerPoint)")
        playerPointLabel.position = CGPointMake(playerPointLabel.frame.width, 10)
        self.addChild(playerPointLabel)
        
        enemyPointLabel = SKLabelNode(text: "後手:\(enemyPoint)")
        enemyPointLabel.position = CGPointMake(viewSize.width - enemyPointLabel.frame.width, 10)
        self.addChild(enemyPointLabel)
        
        wait = SKLabelNode(text: "待った")
        wait.position = CGPointMake(viewSize.width / 2, 10)
        self.addChild(wait)
    }
}
