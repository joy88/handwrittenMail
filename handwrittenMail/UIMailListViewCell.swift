//
//  UIMailListViewCell.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/9.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class UIMailListViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mailSubjectLbl.lineBreakMode=NSLineBreakMode.ByTruncatingTail
    }
    @IBOutlet weak var mailSubjectLbl: UILabel!

    @IBOutlet weak var mailDigestLbl: UILabel!
    @IBOutlet weak var mailAttatchImgFlag: UIImageView!
    @IBOutlet weak var mailDateLbl: UILabel!
    @IBOutlet weak var mailFromLbl: UILabel!
    @IBOutlet weak var mailFlagImg: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
