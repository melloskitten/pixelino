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
            pictureExporter = PictureExporter(colorArray: setDrawing.colorArray, canvasWidth: Int(setDrawing.width), canvasHeight: Int(setDrawing.height))
        }
    }

    var pictureExporter: PictureExporter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    fileprivate func setUpView() {
        view.backgroundColor = DARK_GREY
        setUpButtons()
    }

    fileprivate func setUpButtons() {
        setUpButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50), title: "Share With...", action: #selector(shareButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50), title: "Save to App", action: #selector(saveButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 300, width: 200, height: 50), title: "Return", action: #selector(returnButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 400, width: 200, height: 50), title: "Return to Menu", action: #selector(menuButtonPressed(_:)))
    }

    fileprivate func setUpButton(frame: CGRect, title: String, action: Selector) {
        let button = UIButton(frame: frame)
        button.backgroundColor = LIGHT_GREY
        button.titleLabel?.textColor = .white
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }

    fileprivate func saveToApp(_ imageData: Data) {
        // FIXME: Gather all other data needed for creation of thumbnail, e.g. through prompts.
        let thumbnail = Thumbnail(fileName: "derp", date: "\(Date.init())", imageData: imageData)

        // Establish the relationships and save them in CoreData.
        let oldThumbnail = drawing?.thumbnail
        drawing?.thumbnail = thumbnail
        thumbnail.drawing = drawing!

        // Save drawing.
        CoreDataManager.saveDrawing(drawing: drawing!, oldThumbnail: oldThumbnail)
    }

    @objc func shareButtonPressed(_ sender: UIButton) {
        guard let pictureExporter = pictureExporter else {
            return
        }

        // FIXME: Hardcoded values - take them as input (through a prompt) from the user.
        let sharedImage = pictureExporter.generateUIImagefromDrawing(width: 300, height: 300)
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
            let thumbnailImage = pictureExporter.generateThumbnailFromDrawing(),
            let imageData = UIImagePNGRepresentation(thumbnailImage) else {
            // FIXME: Show some error message here.
            return
        }

        saveToApp(imageData)
    }

    @objc func menuButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
