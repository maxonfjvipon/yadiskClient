//
//  FilesTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 25/04/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class FilesTableViewController: UITableViewController, loadResourceProtocol {
    
    func presentMoveCopyController(operation: String, indexPath: IndexPath) {
        let mcNC = self.storyboard?.instantiateViewController(withIdentifier: "MoveCopyNCID") as! UINavigationController
        let mcVC = mcNC.topViewController as! MoveCopyTableViewController
        mcVC.operation = operation
        var from = self.currentPath + (self.resource?._embedded?.items![indexPath.row].name)!
        if (self.resource?._embedded?.items![indexPath.row].type)! == "dir" {
            from = from + "/"
        }
        mcVC.from = from
        mcVC.resourceName = (self.resource?._embedded?.items![indexPath.row].name)!
        self.present(mcNC, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (alertAction) in
            self.loadCurrentResource(path: self.currentPath)
        })
        alert.addAction(doneAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadResource() {
        self.loadCurrentResource(path: self.currentPath)
    }

    var currentPath: String = rootPath
    var resource: Resource?
    
    @IBOutlet var infoButton: UIBarButtonItem!

    // "+" - upload
    @IBAction func uploadButtonPressed(_ sender: Any) {
        let uploadVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadTVCID") as! UploadTableViewController
        uploadVC.sectionName = self.navigationItem.title
        uploadVC.navigationItem.title = "Upload"
        uploadVC.currentPath = self.currentPath
        uploadVC.delegate = self
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Swipe up to reload data")
        refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        if currentPath == rootPath {
            self.navigationItem.setLeftBarButton(infoButton, animated: true)
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
        let request = getResourcesRequest(path: path)
        let globalQueue = DispatchQueue.global(qos: .utility)
        globalQueue.async {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        self.resource = try JSONDecoder().decode(Resource.self, from: data)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
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
        if resource?._embedded == nil {
            return 0
        } else {
            return resource!._embedded!.items!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilesCell", for: indexPath) as! FilesTableViewCell
        cell.initResourceInCell(resource: (resource?._embedded?.items![indexPath.row])!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch resource!._embedded!.items![indexPath.row].type {
        case "dir":
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilesTVCID") as! FilesTableViewController
            vc.currentPath = currentPath + ((resource?._embedded?.items![indexPath.row].name)!) + "/"
            vc.navigationItem.title = resource!._embedded!.items![indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
        case "file":
            let media_type = resource!._embedded!.items![indexPath.row].media_type
            switch media_type {
            case "image":
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PresentImageVCID") as! PresentImageViewController
                vc.previewPath = resource!._embedded!.items![indexPath.row].file // fixme
                vc.navigationItem.title = resource!._embedded!.items![indexPath.row].name
                vc.currentPath = currentPath + ((resource?._embedded?.items![indexPath.row].name)!)
                navigationController?.pushViewController(vc, animated: true)
            case "video":
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVCID") as! PlayerViewController
                vc.videoPath = self.resource?._embedded?.items![indexPath.row].file
                vc.currentPath = currentPath + ((resource?._embedded?.items![indexPath.row].name)!)
                navigationController?.pushViewController(vc, animated: true)
            case "document": break
            default: break
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: "Move") { (action, view, completion) in
            self.presentMoveCopyController(operation: "Move", indexPath: indexPath)
            completion(true)
        }
        let copy = UIContextualAction(style: .normal, title: "Copy") { (action, view, compretion) in
            self.presentMoveCopyController(operation: "Copy", indexPath: indexPath)
            compretion(true)
        }
        move.backgroundColor = .blue
        copy.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [move,copy])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            let alert = UIAlertController(title: "Delete resource?", message: "Resource will be deleted!", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
                let request = deleteResourceRequest(path: self.currentPath + (self.resource?._embedded?.items![indexPath.row].name)!)
                let _alert = UIAlertController(title: "Deleting...", message: "", preferredStyle: .alert)
                self.present(_alert, animated: true, completion: nil)
                DispatchQueue.global(qos: .utility).async {
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        DispatchQueue.main.async {
                            _alert.dismiss(animated: true, completion: nil)
                            self.loadCurrentResource(path: self.currentPath)
                        }
                    }.resume()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            }
            alert.addAction(delete)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
        var title: String?
        if self.resource?._embedded?.items![indexPath.row].public_url != nil {
            title = "Unpublish"
        } else {
            title = "Publish"
        }
        let publish = UIContextualAction(style: .normal, title: title) { (action, view, completion) in
            if title == "Publish" {
                let request = publishResourceRequest(path: self.currentPath + (self.resource?._embedded?.items![indexPath.row].name!)!)
                URLSession.shared.dataTask(with: request) {_,_,_ in
                    self.presentAlert(title: "Published", message: "Resource was published!")
                }.resume()
            } else {
                let request = unpublishResourceRequest(path: self.currentPath + (self.resource?._embedded?.items![indexPath.row].name!)!)
                URLSession.shared.dataTask(with: request) {_,_,_ in
                    self.presentAlert(title: "Unpublished", message: "Resource was unpublished!")
                }.resume()
            }
            completion(true)
        }
        delete.backgroundColor = .red
        publish.backgroundColor = .orange
        let configuration = UISwipeActionsConfiguration(actions: [delete, publish])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoNCID")
        present(vc!, animated: true, completion: nil)
    }
}

extension FilesTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
