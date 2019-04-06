//
//  ShareViewController.swift
//
//

import UIKit

class ShareViewController: UITableViewController {

    // MARK: - UI related constants.

    var progressBar: CircularProgressIndicator?
    var fileName: String?

    // MARK: - Export-related attributes.

    var pictureExporter: PictureExporter?

    var drawing: Drawing? {
        didSet {
            guard let setDrawing = drawing else {
                pictureExporter = nil
                return
            }
            pictureExporter = PictureExporter(colorArray: setDrawing.colorArray, canvasWidth: Int(setDrawing.width), canvasHeight: Int(setDrawing.height))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setupProgressIndicator()
        fileName = drawing?.thumbnail.fileName
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: TableViewController methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SettingsCell")
        cell.backgroundColor = DARK_GREY
        cell.contentView.backgroundColor = DARK_GREY
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .gray
        cell.separatorInset = UIEdgeInsets.zero
        cell.setSelectedColor(color: .black)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Rename Canvas"
            if let fileName = fileName {
                if fileName == "" {
                    cell.detailTextLabel?.text = "Untitled"
                } else {
                    cell.detailTextLabel?.text = fileName
                }
            } else {
                cell.detailTextLabel?.text = "Untitled"
            }
        case 1:
            cell.textLabel?.text = "Save Canvas"
        case 2:
            cell.textLabel?.text = "Share Canvas"
        case 3:
            cell.textLabel?.text = "Exit Canvas"
        default:
            ()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            renameButtonPressed()
        case 1:
            saveButtonPressed()
        case 2:
            shareButtonPressed()
        case 3:
             menuButtonPressed()
        default:
            ()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    fileprivate func setUpView() {
        // Set up navigation bar and button.
        navigationItem.title = "Canvas Information"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(returnButtonPressed))

        // Set up table view controller.
        tableView.backgroundColor = DARK_GREY
        tableView.separatorColor = LIGHT_GREY
        tableView.rowHeight = 100
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

        // Dismiss the current view.
        returnButtonPressed()
    }

    func renameButtonPressed() {
        // Show filename input prompt.
        showTextInputAlert(title: "Rename Canvas",
                           message: "Please select a name for your canvas.",
                           textFieldPlaceholder: "Untitled") { (fileName) in
                           self.fileName = fileName
                           self.saveButtonPressed()
        }
    }

    func shareButtonPressed() {
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
        activityVC.popoverPresentationController?.sourceView = self.view

        self.present(activityVC, animated: true) {
            self.showProgressIndicator(false)
        }
    }

    @objc func returnButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    func saveButtonPressed() {
        guard let pictureExporter = pictureExporter,
            let thumbnailImage = pictureExporter.generateThumbnailFromDrawing(),
            let imageData = UIImagePNGRepresentation(thumbnailImage) else {
                // FIXME: Show some error message here.
                return
        }

        var actualFileName = "Untitled"

        if let fileName = fileName, fileName != "" {
            actualFileName = fileName
        }

        self.saveToApp(imageData, actualFileName)
    }

    @objc func menuButtonPressed() {

        // Delete the changes done to the drawing if user returns to the menu
        // without saving. This is needed because else the managedObjectContext
        // keeps the changes done to the drawing, even though the user did not specifically
        // choose to save the image.
        drawing?.managedObjectContext?.reset()
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

    /// Creates and adds the progress indicator to the view.
    func setupProgressIndicator() {
        progressBar = CircularProgressIndicator(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
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

    /// Updates the progress indicator's progress to the specific percentage.
    ///
    /// - Parameter to: percentage of progress, e.g. 0.5 for 50%.
    func updateProgressIndicator(_ to: Double) {
        if let progressBar = progressBar {
            progressBar.setProgress(to: to, withAnimation: false)
        }
    }

}
