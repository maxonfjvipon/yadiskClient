//
//  NewFolderTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 23/05/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class NewFolderTableViewController: UITableViewController, UITextFieldDelegate {

    var link: Link?
    var currentPath: String?
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var keyboardDoneButton: UIBarButtonItem!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        let request = createFolderRequest(path: currentPath! + folderNameTextField.text!)
        let globalQueue = DispatchQueue.global(qos: .utility)
        globalQueue.async {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    print(response as Any)
                    do {
                        self.link = try JSONDecoder().decode(Link.self, from: data)
                        DispatchQueue.main.async {
                            let vc = self.navigationController?.popViewController(animated: true)
                            vc?.navigationController?.popViewController(animated: true)
                        }
                    } catch {
                        let responseData = String(data: data, encoding: String.Encoding.utf8)
                        if (responseData?.contains("с таким именем"))! {
                            self.folderAlreadyExists()
                        }
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func folderAlreadyExists() {
        let alert = UIAlertController(title: "Error", message: "Folder with the same name already exists", preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: "OK!", style: .default, handler: { (alertAction) in
        })
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var folderNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setRightBarButton(doneButton!, animated: true)
        addDoneButtonOnKeyboard()
    }

    func addDoneButtonOnKeyboard()
    {
        tableView.isScrollEnabled = false
        self.folderNameTextField.delegate = self
        self.keyboardDoneButton.isEnabled = false
        folderNameTextField.layer.cornerRadius = 10
        let toolBar = UIToolbar()
        toolBar.sizeToFit() // рамка вокруг
        let flexsibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneButtonOnKeyboardPressed))
        toolBar.setItems([flexsibleSpace,doneButton], animated: true)
        folderNameTextField.inputAccessoryView = toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.endEditing(true)
    }
    
    @objc func doneButtonOnKeyboardPressed() {
        view.endEditing(true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
