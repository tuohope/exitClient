//
//  GameViewControllerHelper.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-04-18.
//  Copyright © 2017 Exit. All rights reserved.
//

import Foundation
import UIKit

extension GameViewController{
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //stub
    func setupView() -> () {
        switch GameManager.sharedInstance.gameStatus {
        case .ready:
            startGameButton.isHidden = false;
            objTitleView.isHidden = true;
            afterGameInfoView.isHidden = true
            extraTimeWindowView.isHidden = true
            liveHelpButton.isHidden = true
            timerLabel.isHidden = true
            
            logButton.isUserInteractionEnabled = false
            logTable.isHidden = true
            objectiveTable.isHidden = true
            
        case .ingame:
            startGameButton.isHidden = true;
            objTitleView.isHidden = false;
            afterGameInfoView.isHidden = true
            extraTimeWindowView.isHidden = true
            liveHelpButton.isHidden = false
            timerLabel.isHidden = false
            
            logButton.isUserInteractionEnabled = false
            logTable.isHidden = false
            objectiveTable.isHidden = false

            
        case .paused:
            startGameButton.isHidden = true;
            objTitleView.isHidden = false;
            afterGameInfoView.isHidden = false
            extraTimeWindowView.isHidden = true
            liveHelpButton.isHidden = true
            timerLabel.isHidden = true
            
            logButton.isUserInteractionEnabled = false
            logTable.isHidden = true
            objectiveTable.isHidden = true

            
        case .finished:
            startGameButton.isHidden = false;
            objTitleView.isHidden = true;
            afterGameInfoView.isHidden = true
            extraTimeWindowView.isHidden = true
            liveHelpButton.isHidden = true
            timerLabel.isHidden = true
            
            logButton.isUserInteractionEnabled = false
            logTable.isHidden = true
            objectiveTable.isHidden = true

            
        case .disconnected:
            startGameButton.isHidden = false;
            objTitleView.isHidden = true;
            afterGameInfoView.isHidden = true
            extraTimeWindowView.isHidden = true
            liveHelpButton.isHidden = true
            timerLabel.isHidden = true
            
            logButton.isUserInteractionEnabled = false
            logTable.isHidden = true
            objectiveTable.isHidden = true
        }
    }
    
    
    func updateTimerLabel() {        
        timerLabel.text = generateTimeText(gameManager.runningTime - gameManager.currTime);
    }
    
    func showLogView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.logViewTrailing.constant = -31
            self.logButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.view.layoutIfNeeded()
        },completion: nil)
    }
    
    func hideLogView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.logViewTrailing.constant = -480
            self.logButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(2*Double.pi));
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
