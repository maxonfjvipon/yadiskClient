//
//  PresentPublicImageViewController.swift
//  yd
//
//  Created by Максим Трунников on 09/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class PresentPublicImageViewController: UIViewController {

    var previewPath: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var shareButton: UIBarButtonItem!
    
    @IBAction func shareButtonPressed(_ sender: Any) {
    let activityController = UIActivityViewController(activityItems: [self.imageView.image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        present(activityController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = getResourceRequest(url: previewPath!)
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                        self.shareButton.isEnabled = true
                    }
                }
                }.resume()
        }
        self.navigationItem.setRightBarButton(shareButton, animated: true)
        self.tabBarItem.isEnabled = false
    }
}
