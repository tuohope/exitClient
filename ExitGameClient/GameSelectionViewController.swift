//
//  GameSelectionViewController.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-03-30.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit
import KVNProgress

class GameSelectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        ConnectionManager.sharedInstance.delegate = self;
    }

    
    
    @IBAction func AirplanePressed(_ sender: Any) {
        let cm = ConnectionManager.sharedInstance;
        cm.roomName = "airplane"
        cm.roomID = 0;
        cm.establishConnection();
        cm.fetchData();
    }
    @IBAction func AtlantisPressed(_ sender: Any) {
        let cm = ConnectionManager.sharedInstance;
        cm.roomName = "atlantis"
        cm.roomID = 1;
        cm.establishConnection();
        cm.fetchData();
    }
    @IBAction func MinePressed(_ sender: Any) {
        let cm = ConnectionManager.sharedInstance;
        cm.roomName = "mine"
        cm.roomID = 2;
        cm.establishConnection();
        cm.fetchData();
    }
    @IBAction func SubwayPressed(_ sender: Any) {
        let cm = ConnectionManager.sharedInstance;
        cm.roomName = "subway"
        cm.roomID = 3;
        cm.establishConnection();
        cm.fetchData();
    }
    @IBAction func TerraPressed(_ sender: Any) {
        let cm = ConnectionManager.sharedInstance;
        cm.roomName = "terracotta"
        cm.roomID = 4;
        cm.establishConnection();
        cm.fetchData();
    }
    
    
}

extension GameSelectionViewController: ConnectionManagerDelegate {
    func fetchDataStarted(){
//        print("started in view")
        KVNProgress.show();
    }
    func fetchDataSuccess(){
        KVNProgress.dismiss();
//        print("success in view")
                
        self.present(self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController, animated: true, completion: nil)
        KVNProgress.dismiss();

    }
    func fetchDataFailed(){
        KVNProgress.dismiss();
        print("fail in view")
    }

}
