//
//  UserInfoQRCodeCell.swift
//  Swift_Demo
//
//  Created by nbcb on 2016/11/11.
//  Copyright © 2016年 周清城. All rights reserved.
//

import UIKit

class UserInfoQRCodeCell: UITableViewCell {

    @IBOutlet weak var leftLab: UILabel!
    
    @IBOutlet weak var qrCodeLab: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
