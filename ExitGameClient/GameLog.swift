//
//  GameLog.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-04-04.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit

class GameLog: NSObject {
    var text:String!
    var time:Int!
    var type:String!
    
    
    
    init(Text text:String, Time time:Int, Type type:String){
        self.text = text;
        self.time = time;
        self.type = type;
        super.init();
    }

}
