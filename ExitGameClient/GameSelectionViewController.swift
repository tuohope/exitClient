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
    var cm = ConnectionManager.sharedInstance;

    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        cm.delegate = self;
    }


    @IBAction func AirplanePressed(_ sender: Any) {
        cm.fetchData(room: "Airplane")
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
