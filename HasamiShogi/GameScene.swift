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
        case enemySelect
        case enemyMove
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
    
    let senteMoveSound = SKAction.playSoundFileNamed("senteaction.wav", waitForCompletion: false)
    let goteMoveSound = SKAction.playSoundFileNamed("goteaction.wav", waitForCompletion: false)
    let cannotPutSpund = SKAction.playSoundFileNamed("cannotput.wav", waitForCompletion: false)
    let getSound = SKAction.playSoundFileNamed("get.wav", waitForCompletion: false)
    let finishSound = SKAction.playSoundFileNamed("gamefinish.wav", waitForCompletion: false)

    
    var boardSprite:SKSpriteNode!
    var playerPointLabel:SKLabelNode!
    var enemyPointLabel:SKLabelNode!
    var wait:SKLabelNode!
    var selectPiece:SKSpriteNode!
    var touchName = ""
    
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
                    self.selectState(location,name,"player",playerPieceHoverImage,GameState.movePiece)
                    
                case GameState.movePiece:
                    self.moveState(name,playerPieceImage,GameState.selectPiece,GameState.enemySelect,senteMoveSound)
                    self.checkGet("player")
                    
                case GameState.enemySelect:
                    self.selectState(location,name, "enemy", enemyPieceHoverImage, GameState.enemyMove)
                    self.checkGet("enemy")
                    
                case GameState.enemyMove:
                    self.moveState(name, enemyPieceImage, GameState.enemySelect, GameState.selectPiece,goteMoveSound)
                 
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
        boardSprite.name = "board"
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
                    enemyPiece.name = "enemy\(w)"
                    enemyPiece.zPosition = 1
                    self.addChild(enemyPiece)
                    
                    board[h][w] = enemyPiece.name!
                default:
                    println("empty")
                }
            }
        }
    }
    
    func setPos(h:Int,_ w:Int) -> CGPoint {
       return CGPointMake(CGFloat(space) + CGFloat(w) * pieceSize,CGFloat(space) + CGFloat(h-4) * pieceSize + boardSprite.position.y)
    }
    
    func findPiece(piece:SKSpriteNode) -> (Int,Int) {
        var index = (0,0)
        
        for h in 0..<boardSize {
            for w in 0..<boardSize {
                if board[h][w] == piece.name {
                    index = (h,w)
                }
            }
        }
        
        return index
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
        var pieceIndex = self.findPiece(piece)
        
        board[pieceIndex.0][pieceIndex.1] = "empty"
        board[index1!][index2!] = piece.name!
        piece.position = self.setPos(index1!, index2!)
        
    }
    
    func selectState(location:SKNode,_ name:String,_ pieceName:String,_ image:SKTexture,_ nextState:GameState){
        if let selectName = name.rangeOfString(pieceName) {
            selectPiece = location as SKSpriteNode
            selectPiece.texture = image
            gameState = nextState
            touchName = name
            self.searchCanMove(name)
        }
    }
    
    func moveState(name:String,_ image:SKTexture,_ backState:GameState,_ nextState:GameState,_ actionSound:SKAction){
        if name == touchName {
            selectPiece.texture = image
            gameState = backState
            canMove?.removeAllChildren()
        }else if let selectName = name.rangeOfString("canMove") {
            self.runAction(actionSound)
            selectPiece.texture = image
            gameState = nextState
            canMove?.removeAllChildren()
            self.move(selectPiece,name)
        }else {
            self.runAction(cannotPutSpund)
        }
    }
    
    func checkGet(turn:String){
        let piecePos = self.findPiece(selectPiece)
        var player1 = ""
        var player2 = ""
        
        if let name = turn.rangeOfString("player") {
            player1 = "player"
            player2 = "enemy"
        }else {
            player1 = "enemy"
            player2 = "player"
        }
        
        for d in 0..<4 {
            if piecePos.0 + 2 * dir1[d] >= 0 && piecePos.0 + 2 * dir1[d] < boardSize && piecePos.1 + 2 * dir2[d] >= 0 && piecePos.1 + 2 * dir2[d] < boardSize {
                if let turnPlayer = board[piecePos.0 + dir1[d]][piecePos.1 + dir2[d]].rangeOfString(player2) {
                    if let notTurnPlayer = board[piecePos.0 + 2 * dir1[d]][piecePos.1 + 2 * dir2[d]].rangeOfString(player1) {
                        //TODO: remove
                        
                        board[piecePos.0 + dir1[d]][piecePos.1 + dir2[d]] = "empty"
                        self.setScore(turn);
                    }
                }
            }
        }
    }
    
    func setScore(turn:String){
        
        if turn == "player" {
            playerPoint++
        }else {
            enemyPoint++
        }
        
        playerPointLabel = SKLabelNode(text: "先手:\(playerPoint)")
        enemyPointLabel = SKLabelNode(text: "後手:\(enemyPoint)")
    }
}
