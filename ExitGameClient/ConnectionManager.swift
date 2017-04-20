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
        

        
        socket.on("s_startAirplaneGame") { data, ack in
            print("game START message received")
            if (gameManager.gameManagerDelegate != nil){
                let info = data[0] as! String
                print(info)

                gameManager.startGame();
            }
            
        }
        
        socket.on("s_stopAirplaneGame") { data, ack in
            print("game STOP message received")
            gameManager.stopGame();
        }
        
        socket.on("timeUpdate") { data, ack in
            print(data[0])
            let info = data[0] as! [String:Int]
//            print(info["currTime"])
            gameManager.currTime = info["currTime"]!
            
        }
        
        socket.on("helpProcessed") {data, ack in
            gameManager.liveHelpPending = false;
        }
        
        socket.on("enableBuyTime") {data, ack in
            gameManager.allowExtraTime = true;
        }
        
        socket.on("disableBuyTime") {data, ack in
            gameManager.allowExtraTime = false;
        }
    }
    
    func signalGameStarted() {
        socket.emit("gameStarted",Int(GameManager.sharedInstance.startTime!.timeIntervalSince1970))
    }
    
    func signalGameFinished()  {
        socket.emit("gameFinished", "game has finished");
    }

    func signalObjChanged()  {
        let gm = GameManager.sharedInstance;
        
        let data = ["currTime" : gm.currTime,
                    "currObjectiveText" : gm.currObjectiveText,
                    "currObjectiveTime": gm.currObjectiveTime] as [String : Any]
        
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
        socket.emit("chatHintUsed", data)
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
            
            //            print("JSON: \(JSON)")
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
            gameManager.penaltyIncrement = JSON["penaltyIncrement"] as! Int
            self.delegate?.fetchDataSuccess();
        }
    }
    
}
