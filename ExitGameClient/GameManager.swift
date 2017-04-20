//
//  Room.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-03-30.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit

enum GameStatus {
    case disconnected
    case ready
    case ingame
    case paused
    case finished
}

protocol GameManagerDelegate {
    func gameStarted()
    func gameStopped()
    func gamePaused()
    func gameFinished()
    func gameTicked()
}


class GameManager: NSObject {
    
    static let sharedInstance: GameManager = GameManager();
    var gameManagerDelegate : GameManagerDelegate?
    var roomName:String?
    var gameStatus:GameStatus = GameStatus.disconnected;
    
    var objectives:[GameObjective] = [];
    var gameLogs:[GameLog] = [];
    var completedStep:[Int] = [];
    var objectivesShown:[Int] = [];

    var gameTitle = ""
    var runningTime = 45 * 60
    var difficulty:Int = 0;
    var successRate:Int = 0;
    var currTime = 0
    
    var penaltyIncrement = 60
    var hintPenalty = 0
    var chatPenalty = 0
    var textHintUsed:Int = 0;
    var chatHintUsed:Int = 0;
    var liveHelpPending = false;
    
    var currObjectiveText = ""
    var currObjectiveTime = 0
    
    
    var allowExtraTime = true;
    var extraTimeBought = 0;

    var startTime:Date?

    override private init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameManager.tickGame), userInfo: nil, repeats: true)
    }
    
    
    func startGame() {
        if (self.gameStatus == .ready){
            resetGame()
            startTime = Date();
            self.gameStatus = .ingame;
            objectivesShown.append(0);
            gameManagerDelegate?.gameStarted();
            ConnectionManager.sharedInstance.signalGameStarted();
        }
    }
    
    func stopGame()  {
        if (self.gameStatus == .ingame){
            self.gameStatus = .ready
            resetGame();
            startTime = nil;
            gameManagerDelegate?.gameStopped();
        }
    }
    
    func resetGame() {
        gameLogs.removeAll();
        completedStep.removeAll();
        objectivesShown.removeAll();
        currTime = 0;
        textHintUsed = 0;
        chatHintUsed = 0;
        extraTimeBought = 0;
        startTime = nil;
        currObjectiveText = ""
        currObjectiveTime = 0
        
        for i in objectives{
            i.isHintShown = false;
            i.isComplete = false;
        }
    }
    
    func tickGame()  {
        if (self.gameStatus == .ingame){
            let now = Date();
            let nowInt = Int(now.timeIntervalSince1970);
            currTime = nowInt - Int(startTime!.timeIntervalSince1970) + calculatePenalizedTime() - extraTimeBought;
            if currTime >= runningTime {
                gameStatus = .finished;
                gameManagerDelegate?.gameFinished();
                ConnectionManager.sharedInstance.signalGameFinished();
            }

            gameManagerDelegate?.gameTicked();
        }
        
    }
    
    func getExtraTime(_ time:Int) {
        let cm = ConnectionManager.sharedInstance;

        gameStatus = .ingame
        gameManagerDelegate?.gameStarted()
        extraTimeBought += time * 60
        allowExtraTime = false;
        cm.signalBoughtExtraTime();
        
    }
    
    func calculatePenalizedTime() -> Int {
        let hintUsed = self.textHintUsed + self.chatHintUsed;
        var total = 0;
        
        if (hintUsed == 0){
            return 0;
        }
        
        for i in 1...hintUsed{
            total += i;
        }
        
        var extraTime = total * penaltyIncrement;
        extraTime += textHintUsed * hintPenalty;
        extraTime += chatHintUsed * chatPenalty;
        
        return extraTime;
    }
    
    func deductTimeForChat() {
        self.chatHintUsed += 1;
        self.gameManagerDelegate?.gameTicked();
        ConnectionManager.sharedInstance.signalChatHintUsed();
    }
    
    func deductTimeForHint() {
        self.textHintUsed += 1;
        self.gameManagerDelegate?.gameTicked();
        ConnectionManager.sharedInstance.signalTextHintUsed();
    }
    
    func uncheckObjective(_ id:Int) {
        let cm = ConnectionManager.sharedInstance;

        let currObj = objectives[id]
        currObj.isComplete = false;
        if let index = completedStep.index(of:id) {
            completedStep.remove(at: index)
        }
        for i in currObj.enableObj{
            uncheckHelper(i)
        }
        
        currObjectiveText = objectives[ objectivesShown.last!].objText
        cm.signalObjChanged();
    }
    
    func uncheckHelper(_ id:Int)  {
        let currObj = objectives[id]
        if currObj.isComplete! {
            currObj.isComplete = false;
        }
        if let index = objectivesShown.index(of:id) {
            objectivesShown.remove(at: index)
        }
        if let index = completedStep.index(of:id) {
            completedStep.remove(at: index)
        }
        for i in currObj.enableObj{
            uncheckHelper(i)
        }
    }
    
    func checkObjective(_ id:Int) {
        let cm = ConnectionManager.sharedInstance;
        
        let currObj = objectives[id]
        currObj.isComplete = true;
        completedStep.append(id);
        for i in currObj.enableObj{
            let requirement = Set(objectives[i].requiredObj)
            
            if requirement.isSubset(of: Set(completedStep)){
                objectivesShown.append(i)
            }
        }
        currObjectiveText = objectives[ objectivesShown.last!].objText
        cm.signalObjChanged();
    }
    
}
