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
        setupProgressIndicator()
    }

    fileprivate func setUpView() {
        view.backgroundColor = DARK_GREY
        setUpButtons()
    }

    fileprivate func setUpButtons() {
        setUpButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50),
                    title: "Share With...", action: #selector(shareButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50),
                    title: "Save to App", action: #selector(saveButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 300, width: 200, height: 50),
                    title: "Return", action: #selector(returnButtonPressed(_:)))
        setUpButton(frame: CGRect(x: 100, y: 400, width: 200, height: 50),
                    title: "Return to Menu", action: #selector(menuButtonPressed(_:)))
    }

    fileprivate func setUpButton(frame: CGRect, title: String, action: Selector) {
        let button = UIButton(frame: frame)
        button.backgroundColor = LIGHT_GREY
        button.titleLabel?.textColor = .white
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }

    /// Saves a drawing and corresponding email based on imageData and fileName to the app.
    fileprivate func saveToApp(_ imageData: Data, _ fileName: String) {
        let thumbnail = Thumbnail(fileName: fileName, date: "\(Date.init())", imageData: imageData)

        // Establish the object relationships and save them in CoreData.
        let oldThumbnail = drawing?.thumbnail
        drawing?.thumbnail = thumbnail
        thumbnail.drawing = drawing!

        // Save drawing.
        CoreDataManager.saveDrawing(drawing: drawing!, oldThumbnail: oldThumbnail)

    }

    var progressBar: CircularProgressIndicator?

    func setupProgressIndicator() {
        progressBar = CircularProgressIndicator(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        progressBar?.translatesAutoresizingMaskIntoConstraints = false
        progressBar?.lineWidth = 10.0
        self.view.addSubview(progressBar!)
        progressBar?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        progressBar?.heightAnchor.constraint(equalToConstant: 100).isActive = true
        progressBar?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        progressBar?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        showProgressIndicator(false)
    }

    func showProgressIndicator(_ isOn: Bool) {
        if isOn {
            progressBar?.isHidden = false
            progressBar?.isUserInteractionEnabled = true
        } else {
            progressBar?.isHidden = true
            progressBar?.isUserInteractionEnabled = false
            progressBar?.setProgress(to: 0.0, withAnimation: false)
        }
    }

    func updateProgressIndicator(_ to: Double) {
        if let progressBar = progressBar {
            progressBar.setProgress(to: to, withAnimation: false)
        }
    }

    @objc func shareButtonPressed(_ sender: UIButton) {
        showProgressIndicator(true)

        guard let pictureExporter = self.pictureExporter else {
            return
        }

        // FIXME: Hardcoded values - take them as input (through a prompt) from the user.
        let sharedImage = pictureExporter.generateUIImagefromDrawing(width: 1000, height: 1000, uiHandler: self.updateProgressIndicator(_:))

        let objectsToShare = [sharedImage]
        let activityVC = UIActivityViewController(activityItems: objectsToShare as [Any],
                                                  applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList,
                                            UIActivityType.assignToContact,
                                            UIActivityType.openInIBooks,
                                            UIActivityType.copyToPasteboard,
                                            UIActivityType.openInIBooks]
        activityVC.popoverPresentationController?.sourceView = sender

        self.present(activityVC, animated: true) {
            self.showProgressIndicator(false)
        }
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

        // Show filename input prompt.
        showTextInputAlert(title: "Save File",
                           message: "Please select a name for your file.",
                           textFieldPlaceholder: "Untitled") { (fileName) in
            self.saveToApp(imageData, fileName)
        }
    }

    @objc func menuButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true,
                                                                         completion: nil)
    }

    // MARK: - Convenience methods for adjusting alert controller.

    /// Initialises a pixelino-styled UIAlertController.
    fileprivate func initPixelinoAlertController(_ title: String,
                                                 _ message: String) -> (UIAlertController) {

        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.setBackgroundColor(color: LIGHT_GREY)
        alertController.setTitle(title, color: UIColor.white,
                                 customFont: CustomFonts.roboto.rawValue)
        alertController.setMessage(message, color: UIColor.init(white: 1, alpha: 0.9),
                                   font: CustomFonts.roboto.rawValue)
        alertController.view.tintColor = UIColor.white
        return alertController
    }

    /// Convenience method that creates an AlertViewController with a dark-grey background color,
    /// custom title and message, a textField as an input, as well as save and cancel buttons.
    /// actionOnSuccess denotes a callback handler for when the user has pressed on the
    /// save button.
    private func showTextInputAlert(title: String, message: String, textFieldPlaceholder: String,
                                    actionOnSuccess: @escaping (String) -> Void) {

        let alertController = initPixelinoAlertController(title, message)

        // Add textfield.
        alertController.addTextField { (textField) in
            textField.placeholder = textFieldPlaceholder
        }
        // Add save and cancel buttons.
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            if let textField = alertController.textFields?[0] {
                if let text = textField.text, text.count > 0 {
                    actionOnSuccess(text)
                } else {
                    // Write back "Untitled" in case user didn't enter anything.
                    // Note: This is because we don't want to have completely nameless
                    // drawings. Therefore, we provide a placeholder name.
                    actionOnSuccess("Untitled")
                }
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true, completion: nil)

    }

}
