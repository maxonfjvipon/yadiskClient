//
//  PublicTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 08/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class PublicTableViewController: UITableViewController, UITextFieldDelegate {

    var publicResourceList: PublicResourcesList?
    var publicResource: PublicResource?
    var isResourceList = true
    var publicUrl: String?
    var link: Link?
    var saveLink: String?
    var isMyResourceList = true
    
    @IBOutlet weak var openButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openAction(_ sender: Any) {
        let alert = UIAlertController(title: "Open public resource", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Paste link to public resource here..."
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
        }
        let done = UIAlertAction(title: "Done", style: .default) { (alertAction) in
            if alert.textFields?.first?.text != "" {
                let mcNC = self.storyboard?.instantiateViewController(withIdentifier: "PublicResourcesNCID") as! UINavigationController
                let mcVC = mcNC.topViewController as! PublicTableViewController
                mcVC.isResourceList = false
                mcVC.isMyResourceList = false
                mcVC.publicUrl = alert.textFields?.first?.text
                self.present(mcNC, animated: true, completion: nil)
            }
        }
        alert.addAction(done)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func loadPublicResource() {
        let request = publicResourceRequest(publicUrl: publicUrl!)
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            self.publicResource = try JSONDecoder().decode(PublicResource.self, from: data)
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        } catch {
                            print(error)
                        }
                    }
                }
            }).resume()
        }
    }
    
    func loadPublicResourceList() {
        let request = publicResourceListRequest()
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            self.publicResourceList = try JSONDecoder().decode(PublicResourcesList.self, from: data)
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        } catch {
                            print(error)
                        }
                    }
                }
            }).resume()
        }
    }
    
    override func viewDidLoad() {
        if isMyResourceList {
            self.navigationItem.setRightBarButton(openButton, animated: true)
        } else {
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Swipe up to reload data")
        refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isResourceList {
            loadPublicResourceList()
        } else {
            loadPublicResource()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isResourceList {
            if self.publicResourceList?.items == nil {
                return 0
            } else {
                return (self.publicResourceList?.items.count)!
            }
        } else {
            if self.publicResource?._embedded?.items == nil {
                return 0
            } else {
                return (self.publicResource?._embedded?.items!.count)!
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicCell", for: indexPath) as! PublicTableViewCell
        if isResourceList {
            cell.initResourceInCell(resource: (publicResourceList?.items[indexPath.row])!)
        } else {
            cell.initResourceInCell(resource: (publicResource?._embedded?.items![indexPath.row])!)
        }
        return cell
    }

    @objc func reloadData() {
        if isResourceList {
            loadPublicResourceList()
        } else {
            loadPublicResource()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var type: String?
        if isResourceList {
            switch publicResourceList!.items[indexPath.row].type {
            case "dir":
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PublicTVCID") as! PublicTableViewController
                vc.isResourceList = false
                vc.publicUrl = publicResourceList!.items[indexPath.row].public_url
                vc.navigationItem.title = publicResourceList!.items[indexPath.row].name
                navigationController?.pushViewController(vc, animated: true)
            case "file":
                let media_type = publicResourceList!.items[indexPath.row].media_type
                switch media_type {
                case "image":
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PresentPublicImageVCID") as! PresentPublicImageViewController
                    vc.previewPath = publicResourceList!.items[indexPath.row].file // fixme
                    vc.navigationItem.title = publicResourceList!.items[indexPath.row].name
                    navigationController?.pushViewController(vc, animated: true)
                case "video":
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVCID") as! PlayerViewController
                    vc.videoPath = publicResourceList?.items[indexPath.row].file
                    vc.isFiles = false
                    vc.navigationItem.title = publicResourceList!.items[indexPath.row].name
                    navigationController?.pushViewController(vc, animated: true)
                case "document": break
                default: break
                }
            default: break
            }
        } else {
            switch publicResource?._embedded?.items![indexPath.row].type {
            case "dir":
                if publicResource?._embedded?.items![indexPath.row].public_url != nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PublicTVCID") as! PublicTableViewController
                    vc.isResourceList = false
                    vc.publicUrl = publicResource?._embedded?.items![indexPath.row].public_url
                    vc.navigationItem.title = publicResource?._embedded?.items![indexPath.row].name
                    vc.isMyResourceList = self.isMyResourceList
                    navigationController?.pushViewController(vc, animated: true)
                }
            case "file":
                let media_type = publicResource?._embedded?.items![indexPath.row].media_type
                switch media_type {
                case "image":
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PresentPublicImageVCID") as! PresentPublicImageViewController
                    vc.previewPath = publicResource?._embedded?.items![indexPath.row].file // fixme
                    vc.navigationItem.title = publicResource?._embedded?.items![indexPath.row].name
                    navigationController?.pushViewController(vc, animated: true)
                case "video":
                    break
                    //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVCID") as! PlayerViewController
                    //                vc.videoPath = self.resource?._embedded?.items![indexPath.row].file
                    //                vc.currentPath = currentPath + ((resource?._embedded?.items![indexPath.row].name)!)
                //                navigationController?.pushViewController(vc, animated: true)
                case "document": break
                default: break
                }
            default: break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let getSaveLink = UIContextualAction(style: .normal, title: "Get save link") { (action, view, completion) in
            var path: String = "/"
            var publicURL: String?
            if !self.isResourceList {
                if (self.publicResource?._embedded?.items![indexPath.row].public_url) == nil {
                    path = (self.publicResource?._embedded?.items![indexPath.row].path)!
                }
                publicURL = self.publicResource?.public_url
            } else {
                publicURL = self.publicResourceList?.items[indexPath.row].public_url
            }
            let request = getSaveResourceLinkRequest(publicUrl: publicURL!, path: path)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        self.link = try JSONDecoder().decode(Link.self, from: data)
                        self.saveLink = self.link?.href
                        let alert = UIAlertController(title: "Link to save:", message: "", preferredStyle: .alert)
                        alert.addTextField(configurationHandler: { (textField) in
                            textField.delegate = self
                            textField.text = self.saveLink
                        })
                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (alertAction) in
                            self.reloadData()
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } catch {
                        print(error)
                    }
                }
            }).resume()
            completion(true)
        }
        getSaveLink.backgroundColor = .brown
        let configuration = UISwipeActionsConfiguration(actions: [getSaveLink])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
