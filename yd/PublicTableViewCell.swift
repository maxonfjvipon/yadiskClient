//
//  PublicTableViewCell.swift
//  yd
//
//  Created by Максим Трунников on 08/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class PublicTableViewCell: UITableViewCell {

    @IBOutlet weak var _image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var publicResourceCell: Resource?
    
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
    }
    
    func initTrashResourceInCell(trashResource: TrashResource) {
        nameLabel.text = trashResource.name
        sizeLabel.text = ""
        if trashResource.size != nil {
            sizeLabel.text = String(trashResource.size! / 1024 / 1024) + "." + String(trashResource.size! / 1024 % 1024) + "mb"
        }
        if trashResource.preview != nil {
            let request = getResourceRequest(url: trashResource.preview!)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self._image.image = UIImage(data: data)
                    }
                }
                }.resume()
        } else {
            if trashResource.media_type == "compressed" {
                self._image.image = UIImage(named: "zip.png")
            } else {
                self._image.image = UIImage(named: "folder.png")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
