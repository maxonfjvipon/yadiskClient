//
//  SettingsTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 08/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {

    @IBOutlet var closeButton: UIBarButtonItem!

    var disk: Disk?
    
    func downloadUserDiskData() {
        let request = userDiskRequest()
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            self.disk = try JSONDecoder().decode(Disk.self, from: data)
                            self.tableView.reloadData()
                        } catch {
                            print(error)
                        }
                    }
                }
            }).resume()
        }
    }
    
    func emptyAllTrash() {
        let request = emptyTrashRequest(path: "")
        let alert = UIAlertController(title: "Cleaning...", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            alert.dismiss(animated: true, completion: nil)
        }.resume()
    }
    
    func emptyTrash() {
        let alert = UIAlertController(title: "Empty trash?", message: "Files will be deleted forever!", preferredStyle: .alert)
        let emptyAction = UIAlertAction(title: "Empty", style: .destructive) { (alertAction) in
            self.emptyAllTrash()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
        }
        alert.addAction(emptyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadUserDiskData()
        self.tableView.isScrollEnabled = false
        self.navigationItem.title = "Info"
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoTableViewCell
        if self.disk != nil {
            cell.initInfoCell(disk: self.disk!, indexPath: indexPath)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 3 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            emptyTrash()
        }
    }
    
}
