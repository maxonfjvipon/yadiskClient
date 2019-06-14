//
//  StartViewController.swift
//  yd
//
//  Created by Максим Трунников on 22/04/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var diskLogoWiev: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        loginButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(yaDiskAPI.token)
        sleep(2)
        if yaDiskAPI.token == "" {
            UIView.animate(withDuration: 1, animations: {
                self.loginButton.alpha = 1
                self.diskLogoWiev.frame.origin.y = 100
                print(yaDiskAPI.token)
            }, completion: nil)
        } else {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AfterLoginVC")
            present(nextVC!, animated: true, completion: nil)
        }
    }
}
