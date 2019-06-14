//
//  PlayerViewController.swift
//  yd
//
//  Created by Максим Трунников on 04/06/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit
import AVKit
import Photos

class PlayerViewController: UIViewController {
    
    var videoPath: String?
    var currentPath: String?
    var isFiles = true
    
    @IBOutlet var trashButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        do {
            let activityController = UIActivityViewController(activityItems: [self.destinationURL!], applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete", message: "Do you really want to delete this video", preferredStyle: UIAlertController.Style.alert)
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
    
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying = false
    var destinationURL: URL?
    var videoWasDownloaded = false
    var loc: URL?
    var link: Link?
    var downloadSessionTask: URLSessionDownloadTask?
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFiles {
            downloadFromMyDisk()
            self.navigationItem.setRightBarButtonItems([trashButton, actionButton], animated: true)
        }
        player = AVPlayer(url: URL.init(string: videoPath!)!)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        videoView.layer.addSublayer(playerLayer)
    }
    
    func downloadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Downloading...", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            self.downloadSessionTask?.cancel()
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancelAction)
        return alert
    }
 
    func download(videoURL: URL, alert: UIAlertController) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        self.downloadSessionTask = URLSession.shared.downloadTask(with: videoURL) { (location, response, error) in
            // use guard to unwrap your optional url
            guard let loc = location else { return }
            // create a deatination url with the server response suggested file name
            self.destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
            //            print(documentsDirectoryURL)
            //            print(self.destinationURL)
            do {
                try FileManager.default.moveItem(at: loc, to: self.destinationURL!)
            } catch { //print(error)
                //
            }
            self.videoWasDownloaded = true
            self.actionButton.isEnabled = true
            alert.dismiss(animated: true, completion: nil)
        }
        self.downloadSessionTask?.resume()
    }
    
    func downloadFromMyDisk() {
        let alert = downloadingAlert()
        self.present(alert, animated: true, completion: nil)
        let request = downloadURLRequest(path: currentPath!)
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        self.link = try JSONDecoder().decode(Link.self, from: data)
                        guard let videoURL = URL(string: self.link!.href) else { return }
                        self.download(videoURL: videoURL, alert: alert)
                    } catch {
                        return
                    }
                }
            }).resume()
        }
    }
    
    deinit {
        player.currentItem?.removeObserver(self, forKeyPath: "duration")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if videoWasDownloaded {
            do {
                try FileManager.default.removeItem(at: self.destinationURL!)
            } catch {
                print("Remove item error")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        if isVideoPlaying {
            player.pause()
            sender.setTitle("Play", for: .normal)
        }else {
            player.play()
            sender.setTitle("Pause", for: .normal)
        }
        isVideoPlaying = !isVideoPlaying
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        guard let duration = player.currentItem?.duration else {return}
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 5.0
        if newTime < (CMTimeGetSeconds(duration) - 5.0) {
            let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    
    @IBAction func backwardsPressed(_ sender: Any) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 5.0
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
        player.seek(to: time)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLabel.text = getTimeString(from: player.currentItem!.duration)
        }
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
}
