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
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var objTitleView: UIView!
    @IBOutlet weak var afterGameInfoView: UIView!
    @IBOutlet weak var extraTimeWindowView: UIView!
    @IBOutlet weak var liveHelpButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var logTable: UITableView!
    @IBOutlet weak var objectiveTable: UITableView!
    
    
    @IBOutlet weak var logViewTrailing: NSLayoutConstraint!
        

    override var prefersStatusBarHidden: Bool {
        return true
    }
    func updateTimerLabel() {
        timerLabel.text = generateTimeText(gameManager.runningTime - gameManager.currTime);
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
       
        startGameButton.isHidden = false;
        objTitleView.isHidden = true;
        afterGameInfoView.isHidden = true
        extraTimeWindowView.isHidden = true
        liveHelpButton.isHidden = true
        timerLabel.isHidden = true
        timerLabel.text = generateTimeText(gameManager.runningTime);
        
//        logButton.isUserInteractionEnabled = false
    }
    
    //Mark TableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
            cell.objLabel.text = gameManager.objectives[cell.tag].objText
            
            if (gameManager.objectives[cell.tag].isHintShown!){
                cell.hintButton.backgroundColor = UIColor.gray
            }else{
                cell.hintButton.backgroundColor = UIColor.init(rgb: 0xE54D42)
            }
            
            if (gameManager.objectives[cell.tag].isComplete!){
                cell.objCheckMark.isHidden = false;
            }else{
                cell.objCheckMark.isHidden = true;
            }
            return cell;
        }
    }

    @IBAction func extraTimeOnePressed(_ sender: Any) {
        gameManager.getExtraTime(15)
    }
        
    @IBAction func extraTimeTwoPressed(_ sender: Any) {
        gameManager.getExtraTime(30)
    }

    @IBAction func logButtonPressed(_ sender: Any) {
        if (self.logViewTrailing.constant == -31){
            hideLogView();
        }else{
            showLogView();
        }
    }

    @IBAction func startGamePressed(_ sender: Any) {
        GameManager.sharedInstance.startGame();
    }
    
    @IBAction func liveHelpPressed(_ sender: Any) {
        let penaltyTime = gameManager.chatPenalty + ((gameManager.textHintUsed + gameManager.chatHintUsed + 1) * gameManager.penaltyIncrement);

        
        if gameManager.liveHelpPending {
            let alertController = UIAlertController(title: "Live Help", message: "You already a help request pending, please wait for our staff to respond.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return;
        }
        
        
        
        if gameManager.currTime + penaltyTime > gameManager.runningTime {
            
            if gameManager.allowExtraTime {
                let alertController = UIAlertController(title: "Live Help", message: "You don't have enough time to get Live Help, do you wish to extend your play time and get Help?", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addTextField {
                    (textField: UITextField!) -> Void in
                    textField.placeholder = "Message"
                }
                
                
                let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
                let lowOption = UIAlertAction(title: "15 Mins ", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    
                    self.gameManager.getExtraTime(15)
                    let message = alertController.textFields!.first!.text
                    if (message!.characters.count > 140){
                        let tooLongWarning = UIAlertController(title: "Live Help", message: "Your message is too long", preferredStyle: UIAlertControllerStyle.alert)
                        tooLongWarning.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive))
                        self.present(tooLongWarning, animated: false, completion: nil);
                        
                        print("too long msg");
                    }else{
                        let confirmAlert = UIAlertController(title: "Live Help", message: "Your message is \"\(message!)\", are you sure", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let sentAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default){
                            (result : UIAlertAction) -> () in
                            self.gameManager.sendHelpWithMessage(message!);
                        }
                        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive))
                        confirmAlert.addAction(sentAction);
                        self.present(confirmAlert, animated: false, completion: nil);
                    }
                }
                let highOption = UIAlertAction(title: "30 Mins ", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.gameManager.getExtraTime(30)
                    let message = alertController.textFields!.first!.text
                    if (message!.characters.count > 140){
                        let tooLongWarning = UIAlertController(title: "Live Help", message: "Your message is too long", preferredStyle: UIAlertControllerStyle.alert)
                        tooLongWarning.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive))
                        self.present(tooLongWarning, animated: false, completion: nil);
                        
                        print("too long msg");
                    }else{
                        let confirmAlert = UIAlertController(title: "Live Help", message: "Your message is \"\(message!)\", are you sure", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let sentAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default){
                            (result : UIAlertAction) -> () in
                            self.gameManager.sendHelpWithMessage(message!);
                        }
                        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive))
                        confirmAlert.addAction(sentAction);
                        self.present(confirmAlert, animated: false, completion: nil);
                    }
                    
                }
                alertController.addAction(lowOption)
                alertController.addAction(highOption)
                alertController.addAction(DestructiveAction)
                self.present(alertController, animated: true, completion: nil)
                return;
            }else{
                let alertController = UIAlertController(title: "Live Help", message: "You don't have enough time to get Live Help", preferredStyle: UIAlertControllerStyle.alert)
                let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
                alertController.addAction(DestructiveAction)
                self.present(alertController, animated: true, completion: nil)
                return;
            }
        }

        
        
        
        let alertController = UIAlertController(title: "Live Help", message: "Scarifice your play time and send one message(140 characters max) to our staff to ask any question. current penalty is \(penaltyTime) seconds, are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Message"
        }
        
        let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
        let okAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            let message = alertController.textFields!.first!.text
            if (message!.characters.count > 140){
                let tooLongWarning = UIAlertController(title: "Live Help", message: "Your message is too long", preferredStyle: UIAlertControllerStyle.alert)
                tooLongWarning.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive))
                self.present(tooLongWarning, animated: false, completion: nil);
                
                print("too long msg");
            }else{
                let confirmAlert = UIAlertController(title: "Live Help", message: "Your message is \"\(message!)\", are you sure", preferredStyle: UIAlertControllerStyle.alert)
                
                let sentAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default){
                    (result : UIAlertAction) -> () in
                    self.gameManager.sendHelpWithMessage(message!);
                }
                confirmAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive))
                confirmAlert.addAction(sentAction);
                self.present(confirmAlert, animated: false, completion: nil);
            }
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension GameViewController : ObjectiveTableViewCellDelegate{
    func checkButtonPressed(_ id:Int) {
        if gameManager.objectives[id].isComplete! {
            gameManager.uncheckObjective(id);
        }else{
            gameManager.checkObjective(id);
        }
        objectiveTable.reloadData();
    }
    
    func hintButtonPressed(_ id:Int) {
        let currObj = gameManager.objectives[id];
        let penaltyTime = gameManager.hintPenalty + (gameManager.textHintUsed + gameManager.chatHintUsed + 1) * gameManager.penaltyIncrement;
        
        if gameManager.currTime + penaltyTime > gameManager.runningTime {
            
            if gameManager.allowExtraTime {
                let alertController = UIAlertController(title: "Get a hint", message: "You don't have enough time to get a hint, do you wish to extend your play time and get a hint?", preferredStyle: UIAlertControllerStyle.alert)
                let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
                let lowOption = UIAlertAction(title: "15 Mins ", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    
                    self.gameManager.getExtraTime(15)
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
                let highOption = UIAlertAction(title: "30 Mins ", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.gameManager.getExtraTime(30)
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
                alertController.addAction(lowOption)
                alertController.addAction(highOption)
                alertController.addAction(DestructiveAction)
                self.present(alertController, animated: true, completion: nil)
                
                
                return;
            }else{
                let alertController = UIAlertController(title: "Get a hint", message: "You don't have enough time to get a hint", preferredStyle: UIAlertControllerStyle.alert)
                let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
                
                alertController.addAction(DestructiveAction)
                self.present(alertController, animated: true, completion: nil)
                return;
            }
        }
        
        
        if !currObj.isHintShown!{
            
            let alertController = UIAlertController(title: "Get a hint", message: "In order to get a hint you must scarifice your play time, current penalty is \(penaltyTime) seconds, are you sure?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
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
        startGameButton.isHidden = true;
        afterGameInfoView.isHidden = true;
        objTitleView.isHidden = false;
        logTable.reloadData();
//        logButton.isUserInteractionEnabled = true;
        objectiveTable.reloadData();
        objectiveTable.isUserInteractionEnabled = true;
        logTable.isUserInteractionEnabled = true;
        liveHelpButton.isHidden = false;
        timerLabel.isHidden = false;
    }
    
    func gamePaused() -> () {}
    
    func gameStopped() {
        
        startGameButton.isHidden = false;
        afterGameInfoView.isHidden = true;
//        logButton.isUserInteractionEnabled = false;
        hideLogView();


        logTable.reloadData();
        objectiveTable.reloadData();
        liveHelpButton.isHidden = true;
        timerLabel.isHidden = true;
    }
    
    func gameFinished() {
        afterGameInfoView.isHidden = false;
        //todo check and ask for extra time option
        
        if (GameManager.sharedInstance.allowExtraTime){
            extraTimeWindowView.isHidden = false;
        }else{
            extraTimeWindowView.isHidden = true;
        }
        
        objectiveTable.isUserInteractionEnabled = false;
        logTable.isUserInteractionEnabled = false;
    }
    
    func gameTicked() {
        updateTimerLabel()
        
        if (gameManager.runningTime - gameManager.currTime == 300 || gameManager.runningTime - gameManager.currTime == 120){
            if gameManager.allowExtraTime {
                let alertController = UIAlertController(title: "Need Extra Time?", message: "Your time is running out. Do you need more time?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
                let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive)
                let lowOption = UIAlertAction(title: "15 Mins ($4.99/Person)", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.gameManager.getExtraTime(15)
                    
                }
                let highOption = UIAlertAction(title: "30 Mins ($9.99/Person)", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.gameManager.getExtraTime(30)
                    
                }
                
                
                alertController.addAction(lowOption)
                alertController.addAction(highOption)
                alertController.addAction(DestructiveAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    func helpReplied(_ r:String){
        
        let newLog = GameLog.init(Text: r, Time: self.gameManager.runningTime - self.gameManager.currTime, Type: "GM")
        self.gameManager.gameLogs.append(newLog)
        
        UIView.performWithoutAnimation {
            self.logTable.reloadData();
            self.logTable.beginUpdates();
            self.logTable.endUpdates();
        }
        self.logTable.scrollToBottom()
        self.objectiveTable.reloadData();

        
        let alertController = UIAlertController(title: "You got a reply from GM", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            self.showLogView();
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil);
    }
    
    
}


