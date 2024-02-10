//
//  chatTableViewCell.swift
//  AskAnything
//
//  Created by Touchzing media on 28/01/24.
//

import UIKit

class chatTableViewCell: UITableViewCell {

    @IBOutlet weak var msgInsideRight: NSLayoutConstraint!
    @IBOutlet weak var msgInsideLeft: NSLayoutConstraint!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var msgAsstiGap: NSLayoutConstraint!
    @IBOutlet weak var msgusergap: NSLayoutConstraint!
    @IBOutlet weak var message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatView.clipsToBounds = true
        message.clipsToBounds = true
        chatView.layer.cornerRadius = 15
        chatView.layer.borderWidth = 0
     chatView.layer.borderColor = #colorLiteral(red: 0.4005850109, green: 0.4057765152, blue: 0.3922994525, alpha: 1)
        
       
        
//        chatView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}
