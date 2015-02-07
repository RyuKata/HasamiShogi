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
    
    var viewSize:CGSize!
    var pieceSize:CGFloat!
    var space:CGFloat!
    var scale:CGFloat!
    let boardSize = 9
    var board = [[String]]()
    var canMove:SKNode!
    
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
    var selectPiece:SKSpriteNode!
    
    let dir1 = [0,0,-1,1]
    let dir2 = [-1,1,0,0]
    
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
                    if let selectName = name.rangeOfString("player") {
                        selectPiece = location as SKSpriteNode
                        selectPiece.texture = playerPieceHoverImage
                        gameState = GameState.movePiece
                        selectPiece.name = name
                        self.searchCanMove(name)
                    }
                case GameState.movePiece:
                    if name == selectPiece.name {
                        selectPiece.texture = playerPieceImage
                        gameState = GameState.selectPiece
                        canMove?.removeAllChildren()
                    }else if let selectName = name.rangeOfString("canMove") {
                        selectPiece.texture = playerPieceImage
                        gameState = GameState.enemyTurn
                        canMove?.removeAllChildren()
                        self.move(selectPiece,name)
                    }
                case GameState.enemyTurn:
                    gameState = GameState.movePiece
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
            var boardCol = [String]()
            
            for w in 0..<boardSize {
                switch h {
                case 0:
                    boardCol.append("player")
                case boardSize - 1:
                    boardCol.append("enemy")
                default:
                    boardCol.append("empty")
                }
            }
            board.append(boardCol)
        }
        
        scale = self.view!.frame.size.width / boardImage.size().width
        pieceSize = playerPieceImage.size().width * scale
        space = ((viewSize.width - pieceSize * 9) / 2) * scale
        canMove = SKNode()
    }
    
    func displayBoard(){
        boardSprite = SKSpriteNode(texture: boardImage)
        boardSprite.setScale(scale)
        boardSprite.position = CGPointMake(viewSize.width / 2, viewSize.height / 2)
        boardSprite.zPosition = -2
        self.addChild(boardSprite)
        self.addChild(canMove)
        
        for h in 0..<boardSize {
            for w in 0..<boardSize {
                switch board[h][w] {
                case "player":
                    var playerPiece = SKSpriteNode(texture: playerPieceImage)
                    
                    playerPiece.anchorPoint = CGPointMake(-0.2, 0.85)
                    playerPiece.setScale(scale)
                    playerPiece.position = self.setPos(h, w)
                    playerPiece.name = "player\(w)"
                    playerPiece.zPosition = 1
                    self.addChild(playerPiece)
                    
                    board[h][w] = playerPiece.name!
                    
                case "enemy":
                    var enemyPiece = SKSpriteNode(texture: enemyPieceImage)
                    
                    enemyPiece.anchorPoint = CGPointMake(-0.25, 0.9)
                    enemyPiece.setScale(scale)
                    enemyPiece.position = self.setPos(h,w)
                    enemyPiece.zPosition = 1
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
    
    func searchCanMove(searchName:String){
        //(h,w)
        var indexes = [(Int,Int)]()
        
        for h in 0..<boardSize {
            for w in 0..<boardSize {
                if board[h][w] == searchName {
                    indexes.append((h,w))
                    var floor = SKSpriteNode(texture: masuHoverImage)
                    
                    floor.setScale(scale)
                    floor.anchorPoint =  CGPointMake(-0.25, 0.85)
                    floor.position = self.setPos(h, w)
                    floor.name = "canMove"
                    canMove.addChild(floor)
                }
            }
        }

        for d in 0..<4 {
            var index = indexes.first!
            
            while true {
                index.0 += dir1[d]
                index.1 += dir2[d]
                
                if index.0 >= 0 && index.0 < boardSize && index.1 >= 0 && index.1 < boardSize &&
                    board[index.0][index.1] == "empty" {
                    var floor = SKSpriteNode(texture: masuHoverImage)
                    
                    floor.setScale(scale)
                    floor.anchorPoint =  CGPointMake(-0.25, 0.85)
                    floor.position = self.setPos(index.0, index.1)
                    floor.name = "canMove\(index.0)\(index.1)"
                    canMove.addChild(floor)
                        
                }else {
                    break
                }
            }
        }
    }
    
    func move(piece:SKSpriteNode,_ floorName:String){
        let str = floorName as NSString
        let index1 = str.substringWithRange(NSRange(location: 7, length: 1)).toInt()
        let index2 = str.substringWithRange(NSRange(location: 8, length: 1)).toInt()
        
        //TODO:プレイヤーの位置を empty に
        board[index1!][index2!] = piece.name!
        piece.position = self.setPos(index1!, index2!)
    }
}
