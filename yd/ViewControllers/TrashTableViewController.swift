//
//  TrashTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 11/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class TrashTableViewController: UITableViewController {

    @IBOutlet var trashButton: UIBarButtonItem!
    
    @IBAction func trashButtonAction(_ sender: Any) {
        removeResource(path: currentPath, byButton: true)
    }
    
    var currentPath = "/"
    var trashResource: TrashResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Swipe up to reload data")
        refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        if currentPath != "/" {
            navigationItem.setRightBarButton(trashButton, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentResource(path: currentPath)
    }
    
    @objc func reloadData() {
        self.loadCurrentResource(path: self.currentPath)
    }
    
    func loadCurrentResource(path: String) {
        let request = trashResourceRequest(path: path)
        let globalQueue = DispatchQueue.global(qos: .utility)
        globalQueue.async {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        self.trashResource = try JSONDecoder().decode(TrashResource.self, from: data)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                            self.trashButton.isEnabled = true
                        }
                    } catch {
                        print(error)
                    }
                }
                }.resume()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if trashResource?._embedded == nil {
            return 0
        } else {
            return trashResource!._embedded!.items!.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trashCell", for: indexPath) as! PublicTableViewCell
        cell.initTrashResourceInCell(trashResource: (trashResource?._embedded?.items![indexPath.row])!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if trashResource!._embedded!.items![indexPath.row].type == "dir" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrashTVCID") as! TrashTableViewController
            vc.currentPath = currentPath + ((trashResource?._embedded?.items![indexPath.row].name)!) + "/"
            vc.navigationItem.title = trashResource!._embedded!.items![indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let restore = UIContextualAction(style: .normal, title: "Restore") { (action, view, completion) in
            self.restoreResource(path: self.currentPath + (self.trashResource?._embedded?.items![indexPath.row].name)!, resource: (self.trashResource?._embedded?.items![indexPath.row])!)
             completion(true)
        }
        restore.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [restore])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeForever = UIContextualAction(style: .normal, title: "Remove") { (action, view, completion) in
            self.removeResource(path: self.currentPath + (self.trashResource?._embedded?.items![indexPath.row].name)!, byButton: false)
            completion(true)
        }
        removeForever.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [removeForever])
    }
    
    func restoreResource(path: String, resource: TrashResource) {
        var name: String?
        if resource.type != "dir" {
            let dotIndex = resource.name!.lastIndex(of: ".")
            let format = resource.name![dotIndex!..<resource.name!.endIndex]
            name = String(resource.name![resource.name!.startIndex..<dotIndex!])
            if (resource.name?.contains("(r)"))! {
                name = name! + String(format)
            } else {
                name = name! + "(r)" + String(format)
            }
        } else {
            name = resource.name!
            if !(resource.name?.contains("(r)"))! {
                name = name! + "(r)"
            }
        }
        let request = restoreResourceRequest(path: path, name: name!)
        let _alert = UIAlertController(title: "Restoring...", message: "", preferredStyle: .alert)
        self.present(_alert, animated: true, completion: nil)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            _alert.dismiss(animated: true, completion: nil)
            let alert = UIAlertController(title: "Success!", message: "Resource was restored", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
                self.reloadData()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }.resume()
    }
    
    func removeResource(path: String, byButton: Bool) {
        let alert = UIAlertController(title: "Remove forever?", message: "Resource will be deleted forever!", preferredStyle: .alert)
        let remove = UIAlertAction(title: "Remove", style: .destructive) { (alertAction) in
            let request = emptyTrashRequest(path: path)
            let _alert = UIAlertController(title: "Removing...", message: "", preferredStyle: .alert)
            self.present(_alert, animated: true, completion: nil)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                _alert.dismiss(animated: true, completion: nil)
                if byButton {
                    self.navigationController?.popViewController(animated: true)
                }
                self.reloadData()
            }.resume()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
        }
        alert.addAction(remove)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
