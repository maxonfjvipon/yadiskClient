//
//  UploadTableViewController.swift
//  yd
//
//  Created by Максим Трунников on 20/05/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit


class UploadTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate, UITextFieldDelegate {

    var delegate: loadResourceProtocol?
    var sectionName: String?
    var currentPath: String?
    var imagePicker = UIImagePickerController()
    var link: ResourceUploadLink?
    var _link: Link?
    var imageData: Data?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet var imageToUpload: UIImageView!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.tableView.isScrollEnabled = false
        self.navigationItem.setLeftBarButton(cancelButton!, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // camera roll
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        case 1:
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        case 2: // new folder
            print("New folder")
            let newFolderVC = self.storyboard?.instantiateViewController(withIdentifier: "NewFolderTVCID") as! NewFolderTableViewController
            newFolderVC.title = "New folder"
            newFolderVC.currentPath = self.currentPath
            navigationController?.pushViewController(newFolderVC, animated: true)
        case 3: // upload from url
            let alert = UIAlertController(title: "Upload from URL", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Paste URL here..."
            }
            let okAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
                let text = alert.textFields?.first?.text
                if !text!.contains("filename") {
                    return
                } else {
                    let alert = UIAlertController(title: "Uploading...", message: "", preferredStyle: .alert)
                    self.present(alert,animated: true, completion: nil)
                    let fileName: String?
                    var startIndex = text!.firstIndex(of: "&")
                    startIndex = text!.index(after: startIndex!)
                    let sufString = text![startIndex!..<text!.endIndex]
                    let lastIndex = sufString.firstIndex(of: "&")
                    startIndex = sufString.index(after: sufString.firstIndex(of: "=")!)
                    fileName = String(sufString[startIndex!..<lastIndex!])
                    DispatchQueue.global(qos: .utility).async {
                        let downloadedData = try! Data(contentsOf: URL.init(string: text!)!)
                        self.uploadImageFromURL(downloadedData: downloadedData, _fileName: fileName!, alert: alert)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert,animated: true, completion: nil)
        default: break
        }
    }
    
    func uploadImageFromURL(downloadedData: Data, _fileName: String, alert: UIAlertController) {
        var fileName = _fileName
        if !fileName.contains(".png") && !fileName.contains(".jpg") && !fileName.contains(".jpeg") {
            fileName += ".png"
        }
        var request = uploadURLRequest(path: self.currentPath! + fileName)
        URLSession.shared.dataTask(with: request) { (data,_, error) in
            if let data = data {
                do {
                    let uploadLink = try JSONDecoder().decode(ResourceUploadLink.self, from: data)
                    request = uploadResourceRequest(path: uploadLink.href)
                    URLSession.shared.uploadTask(with: request, from: downloadedData) { (data, response, error) in
                        DispatchQueue.main.async {
                            alert.dismiss(animated: true, completion: nil)
                            let al = UIAlertController(title: "Success", message: "Resource was uploaded", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .cancel) { (_) in
                                self.navigationController?.popViewController(animated: true)
                            }
                            al.addAction(ok)
                            self.present(al, animated: true, completion: nil)
                        }
                    }.resume()
                } catch {
                    alert.dismiss(animated: true, completion: nil)
                    let errorAlert = UIAlertController(title: "Error", message: "File with the same name already exist at specified path", preferredStyle: .alert)
                    errorAlert.addTextField(configurationHandler: {(textField) in
                        textField.text = fileName
                        textField.placeholder = "Enter other file name:"
                    })
                    let OKAction = UIAlertAction(title: "Done", style: .default, handler: { (alertAction) in
                        self.present(alert, animated: true, completion: nil)
                        self.uploadImageFromURL(downloadedData: downloadedData, _fileName: (errorAlert.textFields?.first!.text)!, alert: alert)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                        return
                    })
                    errorAlert.addAction(OKAction)
                    errorAlert.addAction(cancelAction)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }.resume()
    }
    
    func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter the title:"
        })
        let OKAction = UIAlertAction(title: "Done", style: .default, handler: { (alertAction) in
            self.getUploadURL(name: alert.textFields![0].text!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            return
        })
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func uploadImage() {
        let request = uploadResourceRequest(path: self.link!.href)
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.uploadTask(with: request, from: self.imageData) { (data, response, error) in
                DispatchQueue.main.async {
                    self.delegate?.loadResource()
                }
                }.resume()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func getUploadURL(name: String) {
        let pathToUpload = self.currentPath! + name + ".png"
        if name == "" {
            errorAlert(message: "File name can't be empty")
            return
        }
        let request = uploadURLRequest(path: pathToUpload)
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request) { (data,_, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            self.link = try JSONDecoder().decode(ResourceUploadLink.self, from: data)
                            self.uploadImage()
                        } catch {
                            print(error)
                            self.errorAlert(message: "File with the same name already exist at specified path")
                        }
                    }
                }
            }.resume()
        }
    }
    
    func upload() {
        let alert = UIAlertController(title: "Title", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter the title:"
        })
        let OKAction = UIAlertAction(title: "Done!", style: .default, handler: { (alertAction) in
            self.getUploadURL(name: alert.textFields![0].text!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            return
        })
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageToUpload.image = image
            self.imageData = image.pngData()!
            upload()
        }
    }
}
