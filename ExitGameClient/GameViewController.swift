//
//  GameViewController.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-03-30.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var gameManager = GameManager.sharedInstance;
    
    
    @IBOutlet weak var liveHelpButton: UIButton!

    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectiveTable: UITableView!
    @IBOutlet weak var logTable: UITableView!
    @IBOutlet weak var logViewTrailing: NSLayoutConstraint!
        
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameManager.gameManagerDelegate = self;

        self.objectiveTable.dataSource = self;
        self.objectiveTable.delegate = self;
        self.objectiveTable.estimatedRowHeight = 44
        self.objectiveTable.rowHeight = UITableViewAutomaticDimension
        
        self.logTable.dataSource = self;
        self.logTable.delegate = self;
        self.logTable.estimatedRowHeight = 44
        self.logTable.rowHeight = UITableViewAutomaticDimension
        
        //self.gameManager.currStep = 1;
        
//        self.gameManager.objectivesShown.append(0);
        
        liveHelpButton.isHidden = true;
        timerLabel.text = generateTimeText(gameManager.runningTime);
        


        
    }
    
    func updateTimerLabel() {
        //gameManager.tickGame();

        timerLabel.text = generateTimeText(gameManager.runningTime - gameManager.currTime);
    }

        
        
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //return self.gameManager.currStep;
        
//        var objShownCount = 0
//        for obj in self.gameManager.objtest{
//            for objId in obj.requiredObj{
//                self.gameManager.completedObjIds.contains(objId);
//            }
//            
//            if obj.isShown!{
//                objShownCount = objShownCount + 1
//            }
//        }
        if tableView.isEqual(self.logTable){
            return gameManager.gameLogs.count;
        }else{
            return gameManager.objectivesShown.count;
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.isEqual(self.logTable){
            let log = gameManager.gameLogs[indexPath.row]
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogTableViewCell") as! LogTableViewCell
            cell.messageLabel.text = log.text!
            cell.backgroundColor = cell.contentView.backgroundColor;

            cell.typeLabel.text = "[\(log.type!)]"
            cell.timeLabel.text = "[\(generateTimeText(log.time!))]"
            
            return cell;
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectiveTableViewCell") as! ObjectiveTableViewCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            cell.tag = gameManager.objectivesShown[indexPath.row];
            cell.delegate = self;
            cell.objLabel.text = gameManager.objtest[cell.tag].objText
            
            if (gameManager.objtest[cell.tag].isHintShown!){
                cell.hintButton.backgroundColor = UIColor.gray
            }else{
                cell.hintButton.backgroundColor = UIColor.init(rgb: 0xE54D42)
            }
            
            if (gameManager.objtest[cell.tag].isComplete!){
                cell.objCheckMark.isHidden = false;
            }else{
                cell.objCheckMark.isHidden = true;
            }
            return cell;

        }
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func logButtonPressed(_ sender: Any) {
        if (self.logViewTrailing.constant == -31){
            hideLogView();
        }else{
            showLogView();
        }
    }
    
    
    @IBAction func liveHelpPressed(_ sender: Any) {
        if gameManager.liveHelpPending {
            let alertController = UIAlertController(title: "Live Help", message: "You already a help request pending, please wait for our staff to respond.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return;
        }
        
        
        let alertController = UIAlertController(title: "Live Help", message: "In order to get help from our staff you must scarifice your play time, current penalty is \(self.gameManager.penaltyIncrement * gameManager.hintUsed + gameManager.chatPenalty) seconds, are you sure?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            
            self.gameManager.deductTimeForChat();
            self.gameManager.liveHelpPending = true;
            
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLogView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.logViewTrailing.constant = -31
            self.logButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            self.view.layoutIfNeeded()
        },completion: nil)
    }
    
    func hideLogView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.logViewTrailing.constant = -480
            self.logButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(2*M_PI));
            self.view.layoutIfNeeded()
        },completion: nil)
    }

    func generateTimeText(_ time:Int) -> String {
        let minutes = time / 60;
        let seconds = time % 60
        
        let minText = minutes >= 10 ? "\(minutes)" : "0\(minutes)"
        let secText = seconds >= 10 ? "\(seconds)" : "0\(seconds)"
        
        return "\(minText):\(secText)"
    }
    
}

extension GameViewController : ObjectiveTableViewCellDelegate{
    func checkButtonPressed(_ id:Int) {
        if gameManager.objtest[id].isComplete! {
            gameManager.uncheckObjective(id);
        }else{
            gameManager.checkObjective(id);
        }
        objectiveTable.reloadData();
    }
    
    func hintButtonPressed(_ id:Int) {
        let currObj = gameManager.objtest[id];
        
        if !currObj.isHintShown!{
            
            let alertController = UIAlertController(title: "Get a hint", message: "In order to get a hint you must scarifice your play time, current penalty is \(self.gameManager.penaltyIncrement * gameManager.hintUsed + gameManager.penaltyDefault) seconds, are you sure?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                currObj.isHintShown = true
                self.gameManager.deductTimeForHint();
                
                
                let newLog = GameLog.init(Text: currObj.hintText, Time: self.gameManager.runningTime - self.gameManager.currTime, Type: "Hint")
                self.gameManager.gameLogs.append(newLog)
                
                UIView.performWithoutAnimation {
                    self.logTable.reloadData();
                    self.logTable.beginUpdates();
                    self.logTable.endUpdates();
                }
                self.logTable.scrollToBottom()
                self.objectiveTable.reloadData();
                self.showLogView();

                
            }
            
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            self.showLogView();

        }
    }
}

extension GameViewController : GameManagerDelegate{
    func gameStarted() {
        logTable.reloadData();
        objectiveTable.reloadData();
        liveHelpButton.isHidden = false;
        timerLabel.isHidden = false;
        objectiveTable.isUserInteractionEnabled = true;
        logTable.isUserInteractionEnabled = true;
    }
    
    func gameStopped() {
        logTable.reloadData();
        objectiveTable.reloadData();
        liveHelpButton.isHidden = true;
        timerLabel.isHidden = true;
    }
    
    func gameFinished() {
        objectiveTable.isUserInteractionEnabled = false;
        logTable.isUserInteractionEnabled = false;
    }
    
    func gameTicked() {
        updateTimerLabel()
    }
}


