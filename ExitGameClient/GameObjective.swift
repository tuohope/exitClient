//
//  Objective.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-04-03.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit

class GameObjective: NSObject {
    var id:Int!
    var objText:String!
    var hintText:String = "";
    var isComplete:Bool!
    var isHintShown:Bool!
    var requiredObj:[Int]!
    var enableObj:[Int]!
    var completeTime:Int?
    
    
    init(Id id:Int, ObjText obj:String, HintText hint:String, Requires req:[Int], Enables enb:[Int]){
        self.id = id;
        self.objText = obj;
        self.hintText = hint;
        self.requiredObj = req;
        self.isComplete = false;
        self.isHintShown = false;
        self.enableObj = enb;
        self.completeTime = -1;
        super.init();
    }
}
