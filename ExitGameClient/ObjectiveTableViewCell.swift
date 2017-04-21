//
//  ObjectiveTableViewCell.swift
//  ExitGameClient
//
//  Created by Tuo on 2017-03-31.
//  Copyright © 2017 Exit. All rights reserved.
//

import UIKit

protocol ObjectiveTableViewCellDelegate {
    func hintButtonPressed(_ id:Int)
    func checkButtonPressed(_ id:Int)
}


class ObjectiveTableViewCell: UITableViewCell {

    var delegate:ObjectiveTableViewCellDelegate?
    
    var gm = GameManager.sharedInstance;
    var objTable:UITableView!
    
    
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var objCheckMark: UIImageView!
    @IBOutlet weak var objLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.clear;
    }


    @IBAction func checkButtonPressed(_ sender: Any) {
        delegate?.checkButtonPressed(self.tag);
    }
    
    
    @IBAction func hintButtonPressed(_ sender: Any) {
        delegate?.hintButtonPressed(self.tag);
    }

}
