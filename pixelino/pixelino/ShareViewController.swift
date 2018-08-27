//
//  ShareViewController.swift
//  
//
//  Created by Sandra Grujovic on 26.08.18.
//

import UIKit

class ShareViewController: UIViewController {
    
    var drawing: Drawing?

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
        guard let exportedDrawing = drawing else {
            return
        }
        
        let pictureExporter = PictureExporter(colorArray: exportedDrawing.colorArray, canvasWidth: Int(exportedDrawing.width), canvasHeight: Int(exportedDrawing.height))
        
        // FIXME: Hardcoded values!
        let sharedImage = pictureExporter.generateUIImageFromCanvas(width: 300, height: 300)
        
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
    
    @objc func saveButtonPressed(_ sender: UIButton) {
        guard let saveDrawing = drawing else {
            // FIXME: Show some error message here.
            return
        }
        // Save Color array to Core Data.
        CoreDataManager.saveDrawing(colorArray: saveDrawing.colorArray, width: saveDrawing.width, height: saveDrawing.height)
    }
    
}
