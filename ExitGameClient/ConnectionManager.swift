//
//  ConnectionManager.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-03-30.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO


protocol ConnectionManagerDelegate {
    func fetchDataStarted()
    func fetchDataSuccess()
    func fetchDataFailed()
}

class ConnectionManager: NSObject {

    static let sharedInstance: ConnectionManager = ConnectionManager();
    var serverIP = "http://192.168.0.46:3001/";
    var delegate:ConnectionManagerDelegate?
    var socket:SocketIOClient!
    var roomName:String?
    var connected = false;

    
    
    override private init() {
//        socket = SocketIOClient(socketURL: URL(string: serverIP)!, config: [.log(false), .forcePolling(true)])
//        socket.connect();
        super.init();
//        registerHandler();
    }
    
    
    func registerHandler() {
        let gameManager = GameManager.sharedInstance;
        socket.on("connect") {data, ack in
            print("connected")
            self.socket.emit("addGameClient", self.roomName!)
        }
        
        socket.on("roomRegistered") {data in
//            print(data)
            self.connected = true;
            gameManager.gameStatus = .ready
        }
        

        socket.on("startGame") {
            data in
            gameManager.startGame();
        }
        
        socket.on("stopGame") {
            data in
            gameManager.stopGame();
        }
        
        socket.on("disableCYG") {data, ack in
            gameManager.disableCYG();
        }
        
        socket.on("enableCYG") {data, ack in
            gameManager.enableCYG();
        }
        
        socket.on("addTime") {data, ack in
            let time = data[0] as! Int
            gameManager.addTime(time);
        }
        socket.on("deductTime") {data, ack in
            let time = data[0] as! Int
            gameManager.deductTime(time);
        }
    }
    
    func signalCYGEnabled() {
        socket.emit("CYGEnabled", "")
    }
    
    func signalCYGDisabled() {
        socket.emit("CYGDisabled", "")
    }
    
    func signalGameStarted() {
        socket.emit("gameStarted",Int(GameManager.sharedInstance.startTime!.timeIntervalSince1970))
    }
    
    func signalGameFinished()  {
        socket.emit("gameFinished", "game has finished");
    }
    func signalGameStopped() {
        socket.emit("gameStopped", "game stopped and resetted");
    }

    func signalObjChanged()  {
        let gm = GameManager.sharedInstance;
        
        let data = [//"currTime" : gm.currTime,
                    "currObjectiveId" : gm.currObjectiveId,
                    "stepCompleteTime": gm.stepCompleteTime!] as [String : Any]
        
        socket.emit("objectiveChanged",data);

    }
    
    func signalTextHintUsed() {
        let gm = GameManager.sharedInstance;
        let data = ["textHintUsed" : gm.textHintUsed]
        socket.emit("textHintUsed", data)
    }
    
    func signalChatHintUsed() {
        let gm = GameManager.sharedInstance;
        let data = ["chatHintUsed" : gm.chatHintUsed,
                    "chatMessage" : "this is a chat message ph"] as [String : Any]
        socket.emit("chatHintUsed", data)
        
    }
    func signalBoughtExtraTime() {
        let gm = GameManager.sharedInstance;
        let data = ["extraTimeBought" : gm.extraTimeBought]
        socket.emit("extraTimeBought", data)
    }
    
    func signalTimeAdded() {
        socket.emit("timeAdded", GameManager.sharedInstance.timeModifier) 
    }
    
    func signalTimeDeducted() {
        socket.emit("timeDeducted", GameManager.sharedInstance.timeModifier)
    }
    
    func establishConnection() {
        socket = SocketIOClient(socketURL: URL(string: serverIP)!, config: [.log(false), .forcePolling(true), .nsp("/\(roomName!)")])
        socket.connect()
        registerHandler();
    }
    func closeConnection() {
        socket.disconnect()
    }
    
    
    
    
    
    func fetchData() {
        let gameManager = GameManager.sharedInstance;
        
        delegate?.fetchDataStarted();
        Alamofire.request(serverIP+roomName! + "/data").responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                self.delegate?.fetchDataFailed();
                return
            }
            
            guard let JSON = response.result.value as? [String:Any]
                else {
                    print("DataMalFormed")
                    return
            }
            
            //print("JSON: \(JSON)")
            gameManager.gameTitle = JSON["gameTitle"] as! String
            gameManager.difficulty = JSON["difficulty"] as! Int
            gameManager.successRate = JSON["successRate"] as! Int
            
            gameManager.runningTime = JSON["runningTime"] as! Int
            
            gameManager.hintPenalty = JSON["hintPenalty"] as! Int
            gameManager.chatPenalty = JSON["chatPenalty"] as! Int
            gameManager.penaltyIncrement = JSON["penaltyIncrement"] as! Int
            
            let objsRawdata = JSON["objectives"] as! [Any]
            
            
            for obj in objsRawdata{
                var data = obj as![String:Any]
                
                let id = data["id"] as! Int
                let objText = data["objectiveText"] as! String
                let hintText = data["hintText"] as! String
                let requires = data["required"] as! [Int]
                let enables = data["enables"] as! [Int]
                let newObj = GameObjective.init(Id: id, ObjText: objText, HintText: hintText, Requires: requires, Enables: enables)
                gameManager.objectives.append(newObj);
                
            }
            gameManager.stepCompleteTime = [Int?](repeating: nil, count:gameManager.objectives.count)
            gameManager.penaltyIncrement = JSON["penaltyIncrement"] as! Int
            self.delegate?.fetchDataSuccess();
        }
    }
    
}
