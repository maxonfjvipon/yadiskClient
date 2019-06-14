//
//  MoveCopyTableViewCell.swift
//  yd
//
//  Created by Максим Трунников on 29/05/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class MoveCopyTableViewCell: UITableViewCell  {

    @IBOutlet weak var _image: UIImageView!
    @IBOutlet weak var folderName: UILabel!
    
    var itemInCell: Resource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func initResourceInCell(resource: Resource) {
        itemInCell = resource
        folderName.text = resource.name
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
