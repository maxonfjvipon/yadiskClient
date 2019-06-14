//
//  MoveCopyTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 29/05/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class MoveCopyTableViewController: UITableViewController, UITextFieldDelegate{

    var currentPath: String = rootPath
    var resource: Resource?
    var operation: String?
    var link: Link?
    var from: String?
    var resourceName: String?
    var theSameResourceCount = 1
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var flexibleSpace: UIBarButtonItem!
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        moveCopy()
    }
    
    func moveCopy() {
        var request: URLRequest!
        if self.operation == "Move" {
            request = moveResourceRequest(from: from!, to: currentPath + resourceName!)
        } else {
            request = copyResourceRequest(from: from!, to: currentPath + resourceName!)
        }
        let globalQueue = DispatchQueue.global(qos: .utility)
        globalQueue.async {
            URLSession.shared.dataTask(with: request!) { (data, response, error) in
                if let data = data {
                    //                    print(response as Any)
                    do {
                        self.link = try JSONDecoder().decode(Link.self, from: data)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } catch {
                        let responseData = String(data: data, encoding: String.Encoding.utf8)
                        if (responseData?.contains("уже существует"))! || (responseData?.contains("не существует"))! {
                            self.resourceAlreadyExists()
                        }
                        print(error)
                    }
                }
                }.resume()
        }
    }
    
    func resourceAlreadyExists() {
        let alert = UIAlertController(title: "Error", message: "Resource with the same name already exists", preferredStyle: UIAlertController.Style.alert)
        let format = String(self.resourceName![(self.resourceName?.lastIndex(of: "."))!..<self.resourceName!.endIndex])
        alert.addTextField { (textField) in
            textField.placeholder = "Enter new name here..."
        }
        let OKAction = UIAlertAction(title: operation!, style: .default, handler: { (alertAction) in
            self.resourceName = (alert.textFields?.first!.text)! + format
            self.moveCopy()
        })
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .system)
        button.setTitle(operation, for: .normal)
        self.doneButton.customView = button
        cacheCurrentItem(path: currentPath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resource?._embedded == nil {
            return 0
        } else {
            return resource!._embedded!.items!.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveCopyTVCell", for: indexPath) as! MoveCopyTableViewCell
        cell.initResourceInCell(resource: (resource?._embedded?.items![indexPath.row])!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resource?._embedded?.items![indexPath.row].type == "dir" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoveCopyTVCID") as! MoveCopyTableViewController
            vc.currentPath = currentPath + ((resource?._embedded?.items![indexPath.row].name)!) + "/"
            vc.navigationItem.title = resource!._embedded!.items![indexPath.row].name
            vc.operation = self.operation!
            vc.from = self.from!
            vc.resourceName = self.resourceName!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cacheCurrentItem(path: String) {
        let request = getResourcesRequest(path: path)
        let globalQueue = DispatchQueue.global(qos: .utility)
        globalQueue.async {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        self.resource = try JSONDecoder().decode(Resource.self, from: data)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
