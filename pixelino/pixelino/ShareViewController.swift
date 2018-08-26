//
//  ShareViewController.swift
//  
//
//  Created by Sandra Grujovic on 26.08.18.
//

import UIKit

class ShareViewController: UIViewController {
    
    var pictureExporter: PictureExporter?
    var shareButton: UIButton!
    var returnButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Set up the buttons.
        shareButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        shareButton.backgroundColor = .red
        shareButton.setTitle("Share With...", for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonPressed(_:)), for: .touchUpInside)
        shareButton.titleLabel?.textColor = .black
    
        returnButton = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 50))
        returnButton.backgroundColor = .blue
        returnButton.setTitle("Return", for: .normal)
        returnButton.addTarget(self, action: #selector(returnButtonPressed(_:)), for: .touchUpInside)
        returnButton.titleLabel?.textColor = .black
        
        self.view.addSubview(shareButton)
        self.view.addSubview(returnButton)
    }
    
    @objc func shareButtonPressed(_ sender: UIButton) {
        
        guard let pictureExporter = pictureExporter,
            let sharedImage = pictureExporter.generateUIImageFromCanvas(width: 300, height: 300) else {
            return
        }
        
        let objectsToShare = [sharedImage]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.openInIBooks,
                                            UIActivityType.copyToPasteboard, UIActivityType.openInIBooks]
        activityVC.popoverPresentationController?.sourceView = sender
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func returnButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
