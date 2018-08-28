//
//  ShareViewController.swift
//  
//
//  Created by Sandra Grujovic on 26.08.18.
//

import UIKit

class ShareViewController: UIViewController {
    
    var drawing: Drawing? {
        didSet {
            guard let setDrawing = drawing else {
                pictureExporter = nil
                return
            }
            pictureExporter = PictureExporter(colorArray: setDrawing.colorArray, canvasWidth: setDrawing.width, canvasHeight: setDrawing.height)
        }
    }
    
    var pictureExporter: PictureExporter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    fileprivate func setUpView(){
        view.backgroundColor = DARK_GREY
        
        setUpButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50), title: "Share With...", action: #selector(shareButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50), title: "Save to App", action: #selector(saveButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 300, width: 200, height: 50), title: "Return", action: #selector(returnButtonPressed(_:)))
    }
    
    fileprivate func setUpButton(frame: CGRect, title: String, action: Selector) {
        let button = UIButton(frame: frame)
        button.backgroundColor = LIGHT_GREY
        button.titleLabel?.textColor = .white
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func shareButtonPressed(_ sender: UIButton) {
        guard let pictureExporter = pictureExporter else {
            return
        }

        // FIXME: Hardcoded values!
        let sharedImage = pictureExporter.generateUIImageFromCanvas(width: 300, height: 300)
        
        let objectsToShare = [sharedImage]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.openInIBooks, UIActivityType.copyToPasteboard, UIActivityType.openInIBooks]
        activityVC.popoverPresentationController?.sourceView = sender
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func returnButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonPressed(_ sender: UIButton) {
        guard let pictureExporter = pictureExporter,
            let thumbnail = pictureExporter.generateThumbnailFromCanvas() else {
            // FIXME: Show some error message here.
            return
        }
        
        
    }
    
}
