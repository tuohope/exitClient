//
//  Room.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-03-30.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit

protocol GameManagerDelegate {
    func gameStarted()
    func gameStopped()
    func gameFinished()
    func gameTicked()
}


class GameManager: NSObject {
    
    static let sharedInstance: GameManager = GameManager();
    var cm = { return ConnectionManager.sharedInstance }

    var gameManagerDelegate : GameManagerDelegate?
    
    
    var objtest:[GameObjective] = [];
    var gameLogs:[GameLog] = [];
    var completedStep:[Int] = [];
    var objectivesShown:[Int] = [];

    var gameTitle = ""
    var runningTime = 45 * 60
    var currTime = 0
    
    var isRunning = false
    
    var penaltyDefault = 0
    var hintPenalty = 0
    var chatPenalty = 0
    var liveHelpPending = false;
    
    var incrementDefault = 0;
    var penaltyIncrement = 60
    var currObjectiveText = ""
    var currObjectiveTime = 0
    
    var difficulty:Int = 0;
    var successRate:Int = 0;
    
    var hintUsed:Int = 0;
//    var currStep: Int = 0;
    
//    var objectives:[String] = [];
//    var hints:[String] = [];

    override private init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameManager.tickGame), userInfo: nil, repeats: true)
    }
    
    
    func startGame() {
        if (!isRunning){
            resetGame()
            isRunning = true;
            objectivesShown.append(0);
            gameManagerDelegate?.gameStarted();
        }
        
    }
    
    func stopGame()  {
        if (isRunning){
            isRunning = false;
            resetGame();
            gameManagerDelegate?.gameStopped();
        }
    }
    
    func resetGame() {
        gameLogs.removeAll();
        completedStep.removeAll();
        objectivesShown.removeAll();
        currTime = 0;
        hintUsed = 0;
        hintPenalty = penaltyDefault;
        penaltyIncrement = incrementDefault
        currObjectiveText = ""
        currObjectiveTime = 0
        
        for i in objtest{
            i.isHintShown = false;
            i.isComplete = false;
        }
    }
    
    func tickGame()  {
        if (isRunning){
            if (currTime>=runningTime){
                isRunning = false;
                gameManagerDelegate?.gameFinished();
                return;
            }

            currTime += 1
            gameManagerDelegate?.gameTicked();
        }
        
    }
    
    func deductTimeForChat() {
        let penalty = chatPenalty + hintUsed * penaltyIncrement
        self.hintUsed += 1;
        
        
        if currTime + penalty > runningTime {
            currTime = runningTime
        }else{
            currTime += penalty
        }
        
        self.gameManagerDelegate?.gameTicked();
        self.cm().postForHelp();
    }
    
    func deductTimeForHint() {
        let penalty = penaltyDefault + hintUsed * penaltyIncrement
        self.hintUsed += 1;

        
        if currTime + penalty > runningTime {
            currTime = runningTime
        }else{
            currTime += penalty
        }
        
//        self.currTime += self.hintPenalty;
//        self.hintPenalty += self.penaltyIncrement;
//        self.hintUsed += 1;
        self.gameManagerDelegate?.gameTicked();
//        self.cm().postData(room: "Airplane")
        self.cm().postForUpdate();
    }
    
    func uncheckObjective(_ id:Int) {
        let currObj = objtest[id]
        currObj.isComplete = false;
        if let index = completedStep.index(of:id) {
            completedStep.remove(at: index)
        }
        for i in currObj.enableObj{
            uncheckHelper(i)
        }
        
        currObjectiveText = objtest[ objectivesShown.last!].objText
        self.cm().postForUpdate();
    }
    
    func uncheckHelper(_ id:Int)  {
        let currObj = objtest[id]
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
        let currObj = objtest[id]
        currObj.isComplete = true;
        completedStep.append(id);
        for i in currObj.enableObj{
            let requirement = Set(objtest[i].requiredObj)
            
            if requirement.isSubset(of: Set(completedStep)){
                objectivesShown.append(i)
            }
        }
        currObjectiveText = objtest[ objectivesShown.last!].objText
        self.cm().postForUpdate();
    }
    
}
