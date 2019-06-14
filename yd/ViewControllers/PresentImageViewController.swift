//
//  PresentImageViewController.swift
//  yd
//
//  Created by Максим Трунников on 17/05/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class PresentImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var previewPath: String?
    var currentPath: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!

    @IBAction func shareButtonPressed(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [self.imageView.image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        present(activityController, animated: true, completion: nil)
        
    }
    @IBAction func trashButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete", message: "Do you really want to delete this image", preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (alertAction) in
            let request = deleteResourceRequest(path: self.currentPath!)
            DispatchQueue.global(qos: .utility).async {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }.resume()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            return
        })
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
        self.navigationItem.setRightBarButtonItems([trashButton, shareButton], animated: true)
        self.tabBarItem.isEnabled = false
    }
}
