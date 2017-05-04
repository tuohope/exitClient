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
    var serverIP = "http://192.168.1.5:3001";
    var delegate:ConnectionManagerDelegate?
    var socket:SocketIOClient!
    var roomName:String?
    var roomID:Int?
    var connected = false;

    
    
    override private init() {
        super.init();
    }
    
    
    func registerHandler() {
        let gameManager = GameManager.sharedInstance;
        socket.on("connect") {data, ack in
            print("connected")
            self.socket.emit("addGameClient", self.roomName!)
        }
        
        socket.on("roomRegistered") {data in
            self.connected = true;
            gameManager.gameStatus = .ready
            
        }
        
        socket.on("gameStarted"){
            data, ack in
            let d = data[0] as! [String:Any]
            gameManager.updateSessionData(d)
            gameManager.startGame();
        }
        
        socket.on("gameStopped"){
            data, ack in
            let d = data[0] as! [String:Any]
            gameManager.updateSessionData(d)
            gameManager.stopGame();
            
        }
        
        socket.on("gameFinished"){
            data,ack in
            let d = data[0] as! [String:Any]
            gameManager.updateSessionData(d)
            gameManager.finishGame();
        }
        socket.on("timeModified"){
            data, ack in
            let d = data[0] as! [String:Any]
            gameManager.updateSessionData(d)
            
            
        }
        socket.on("CYGChanged"){
            data, ack in
            let d = data[0] as! [String:Any]
            gameManager.updateSessionData(d)
            
        }
        
        socket.on("LiveHelpReplied"){
            data, ack in
            let reply = data[0] as! String
            gameManager.showReplyMessage(reply);
        }

        socket.on("extraTimeBought"){
            data,ack in
            let d = data[0] as! [String:Any]
            gameManager.updateSessionData(d)
        }
//        socket.on("startGame") {
//            data in
//            gameManager.startGame();
//        }
//        
//        socket.on("stopGame") {
//            data in
//            gameManager.stopGame();
//        }
//        
//        socket.on("disableCYG") {data, ack in
//            gameManager.disableCYG();
//        }
//        
//        socket.on("enableCYG") {data, ack in
//            gameManager.enableCYG();
//        }
        
//        socket.on("addTime") {data, ack in
//            let time = data[0] as! Int
//            gameManager.addTime(time);
//        }
//        socket.on("deductTime") {data, ack in
//            let time = data[0] as! Int
//            gameManager.deductTime(time);
//        }
        
//        socket.on("replyLiveHelp") {data, ack in
//            let reply = data[0] as! String
//            gameManager.showReplyMessage(reply);
//        
//        }
        
    }
    
//    func signalCYGEnabled() {
//        socket.emit("CYGEnabled", "")
//    }
//    
//    func signalCYGDisabled() {
//        socket.emit("CYGDisabled", "")
//    }
//    
//    func signalGameStarted() {
//        socket.emit("gameStarted",Int(GameManager.sharedInstance.startTime!.timeIntervalSince1970))
//    }
    
//    func signalGameFinished()  {
//        socket.emit("gameFinished", "game has finished");
//    }
//    func signalGameStopped() {
//        socket.emit("gameStopped", "game stopped and resetted");
//    }

    func signalStartGame()  {
        socket.emit("startGame");
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
    func signalBoughtExtraTime(_ t: Int) {
        let gm = GameManager.sharedInstance;
        let data = ["CYGTime" : t]
        socket.emit("BuyCYGTime", data)
    }
    
//    func signalTimeAdded() {
//        socket.emit("timeAdded", GameManager.sharedInstance.timeModifier) 
//    }
//    
//    func signalTimeDeducted() {
//        socket.emit("timeDeducted", GameManager.sharedInstance.timeModifier)
//    }
    func signalLiveHelpMessage() {
        socket.emit("liveHelpRequested", GameManager.sharedInstance.liveHelpMsg);
    }
    func signalReplyReceived(){
        socket.emit("replyReceived");
    }
    
    func establishConnection() {
        socket = SocketIOClient(socketURL: URL(string: serverIP)!, config: [.log(false), .forcePolling(false), .nsp("/\(roomName!)")])
        socket.connect()
        registerHandler();
    }
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func fetchData() {
        let gameManager = GameManager.sharedInstance;
//        let url = serverIP+roomName! + "/data"
        
//        http://192.168.0.160:3001/api/rooms/0
        let url = serverIP + "/api/rooms/\(roomID!)"
        
        delegate?.fetchDataStarted();
        Alamofire.request(url).responseJSON { response in
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
            gameManager.gameTitle = JSON["gametitle"] as! String
//            gameManager.difficulty = JSON["difficulty"] as! Int
//            gameManager.successRate = JSON["successRate"] as! Int
            
            gameManager.runningTime = JSON["runtime"] as! Int
            
            gameManager.hintPenalty = JSON["hintpenalty"] as! Int
            gameManager.chatPenalty = JSON["chatpenalty"] as! Int
            gameManager.penaltyIncrement = JSON["penaltyincrement"] as! Int
            
            let objsRawdata = JSON["objectives"] as! [Any]
            
            
            for obj in objsRawdata{
                var data = obj as![String:Any]
                
                let id = data["oid"] as! Int
                let objText = data["objectivetext"] as! String
                let hintText = data["hinttext"] as! String
                let requires = data["require"] as! [Int]
                let enables = data["enable"] as! [Int]
                let newObj = GameObjective.init(Id: id, ObjText: objText, HintText: hintText, Requires: requires, Enables: enables)
                gameManager.objectives.append(newObj);
                
            }
            gameManager.stepCompleteTime = [Int?](repeating: nil, count:gameManager.objectives.count)
            self.delegate?.fetchDataSuccess();
        }
    }
    
}
