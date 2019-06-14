//
//  InfoTableViewCell.swift
//  yd
//
//  Created by Максим Трунников on 08/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var _textLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func initInfoCell(disk: Disk, indexPath: IndexPath) {
        var cellLabeltext: String?
        switch indexPath.row {
        case 0:
            cellLabeltext = disk.user?.login
        case 1:
            if disk.unlimited_autoupload_enabled == true {
                cellLabeltext = "unlimited auto-uploading"
            } else {
                cellLabeltext = "limited auto-uploading"
            }
        case 2:
            let usedSpace = String(disk.used_space! / 1024 / 1024) + " MB"
            let totalSpace = String(disk.total_space! / 1024 / 1024 / 1024) + " GB"
            cellLabeltext = "Used " + usedSpace + " / " + totalSpace
        case 3:
            cellLabeltext = "Empty trash"
        default:
            break
        }
        _textLabel.text = cellLabeltext
        if cellLabeltext == "Empty trash" {
            _textLabel.textColor = UIColor.blue
        }
    }
    
    func setCellTextLabel(text: String) {
        _textLabel.text = text
        if text == "Empty trash" {
            _textLabel.textColor = UIColor.blue
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
