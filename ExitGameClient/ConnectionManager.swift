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
    var gameManager = GameManager.sharedInstance;
    var socket:SocketIOClient!
    var roomName:String?
    
    
    override private init() {
        socket = SocketIOClient(socketURL: URL(string: serverIP)!, config: [.log(false), .forcePolling(true)])
        socket.connect();
        super.init();
        registerHandler();
    }
    
    
    func registerHandler() {
        socket.on("connect") {data, ack in
            print("socket connected ipad ipad ipad ipad")
        }
        
//        socket.on("currentAmount") {data, ack in
//            if let cur = data[0] as? Double {
//                socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//                    socket.emit("update", ["amount": cur + 2.50])
//                }
//                
//                ack.with("Got your currentAmount", "dude")
//            }
//        }
        
        socket.on("s_startAirplaneGame") { data, ack in
            print("game START message received")
            if (self.gameManager.gameManagerDelegate != nil){
                self.gameManager.startGame();
            }
            
        }
        
        socket.on("s_stopAirplaneGame") { data, ack in
            print("game STOP message received")
            self.gameManager.stopGame();
        }
        
        socket.on("timeUpdate") { data, ack in
            print(data[0])
            let info = data[0] as! [String:Int]
//            print(info["currTime"])
            self.gameManager.currTime = info["currTime"]!
            
        }
        
        socket.on("helpProcessed") {data, ack in
            self.gameManager.liveHelpPending = false;
        }
        
        socket.on("enableBuyTime") {data, ack in
            self.gameManager.allowExtraTime = true;
        }
        
        socket.on("disableBuyTime") {data, ack in
            self.gameManager.allowExtraTime = false;
        }
    }
    

    func notifyBoughtExtraTime(_ time:Int) {
        let parameters: Parameters = [
            "extraTime" : time,
            "currTime" : gameManager.currTime,
            "isRunning" : gameManager.isRunning
        ]
        
        let a = Alamofire.request(serverIP+self.roomName!+"/BuyTime", method: .post, parameters: parameters).responseJSON
            {
                (response) in
                if response.result.value is NSNull
                {
                    print("nil")
                    return
                }else{
                    print(response.data);
                }
        }
        print(parameters);
        
        
    }
    
    func postForUpdate() {
        let parameters: Parameters = [
            "currTime": gameManager.currTime,
            "currObjectiveText" : gameManager.currObjectiveText,
            "hintUsed" : gameManager.hintUsed
        ]
        
        let a = Alamofire.request(serverIP+self.roomName!+"/updateStatus", method: .post, parameters: parameters).responseJSON
            {
                (response) in
                    if response.result.value is NSNull
                    {
                        print("nil")
                        return
                    }else{
                        print(response.data);
                    }
            }
        print(parameters);
    }
    func postForHelp(){
        let parameters: Parameters = [
            "currTime": gameManager.currTime,
            "currObjectiveText" : gameManager.currObjectiveText,
            "hintUsed" : gameManager.hintUsed
        ]
        
        let a = Alamofire.request(serverIP+self.roomName!+"/requestHelp", method: .post, parameters: parameters).responseJSON
            {
                (response) in
                if response.result.value is NSNull
                {
                    print("nil")
                    return
                }else{
                    print(response.data);
                }
        }
        print(parameters);
    }
    
    func fetchData(room: String) {
        delegate?.fetchDataStarted();
        Alamofire.request(serverIP+room).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(response.result.error)")
                self.delegate?.fetchDataFailed();
                return
            }

            guard let JSON = response.result.value as? [String:Any]
            else {
                print("DataMalFormed")
                return
            }
            
            
//            print("JSON: \(JSON)")
            
            
            let objsRawdata = JSON["objectives"] as! [Any]
            
            for obj in objsRawdata{
                var data = obj as![String:Any]
                
                let id = data["id"] as! Int
                let objText = data["objectiveText"] as! String
                let hintText = data["hintText"] as! String
                let requires = data["required"] as! [Int]
                let enables = data["enables"] as! [Int]
                let newObj = GameObjective.init(Id: id, ObjText: objText, HintText: hintText, Requires: requires, Enables: enables)
                self.gameManager.objtest.append(newObj);
                
            }
            
           // self.gameManager.objectives = JSON["objectives"] as! [String]
           // self.gameManager.hints = JSON["hints"] as! [String]
            
            self.gameManager.gameTitle = JSON["gameTitle"] as! String
            self.gameManager.runningTime = JSON["runningTime"] as! Int
            //self.gameManager.currTime = JSON["currTime"] as! Int
            
            self.gameManager.isRunning = JSON["isRunning"] as! Bool
            
            self.gameManager.penaltyDefault = JSON["hintPenalty"] as! Int
            self.gameManager.hintPenalty = JSON["hintPenalty"] as! Int
            self.gameManager.chatPenalty = JSON["chatPenalty"] as! Int
            self.gameManager.penaltyIncrement = JSON["penaltyIncrement"] as! Int
            self.gameManager.incrementDefault = JSON["penaltyIncrement"] as! Int
            
            self.gameManager.difficulty = JSON["difficulty"] as! Int
            self.gameManager.successRate = JSON["successRate"] as! Int

            self.roomName = JSON["endpointName"] as! String
            self.delegate?.fetchDataSuccess();
        }
    }
    
}
