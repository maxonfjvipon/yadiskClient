//
//  FilesTableViewCell.swift
//  yd
//
//  Created by Максим Трунников on 05/05/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class FilesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var _image: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var publicResImage: UIImageView!
    
    func initResourceInCell(resource: Resource) {
        nameLabel.text = resource.name
        sizeLabel.text = ""
        if resource.size != nil {
            sizeLabel.text = String(resource.size! / 1024 / 1024) + "." + String(resource.size! / 1024 % 1024) + "mb"
        }
        if resource.preview != nil {
            let request = getResourceRequest(url: resource.preview!)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self._image.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            if resource.media_type == "compressed" {
                self._image.image = UIImage(named: "zip.png")
            } else {
                self._image.image = UIImage(named: "folder.png")
            }
        }
        if resource.public_url != nil {
            self.publicResImage.image = UIImage(named: "chains.png")
        } else {
            self.publicResImage.image = UIImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
