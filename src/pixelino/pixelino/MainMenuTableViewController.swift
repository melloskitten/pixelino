//
//  MainMenuTableViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 25.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {

    // MARK: - Data Source.

    var thumbnailArray: [Thumbnail] = []

    // MARK: - ViewDidLoad.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load all saved images.
        setUpThumbnailArray()
        setUpViews()

    }

    // MARK: - ViewDidAppear.

    override func viewWillAppear(_ animated: Bool) {

        // Only reload the TableView if there was an actual change in data, otherwise
        // it looks very odd.
        if thumbnailArrayChanged() {
            setUpThumbnailArray()
            self.tableView.reloadData()
        }

    }

    // MARK: - View and data source configuration and setup methods.

    fileprivate func setUpViews() {
        // Set up navigation bar and button.
        navigationItem.title = "Main Menu"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))

        // Set up table view controller.
        tableView.backgroundColor = DARK_GREY
        tableView.separatorColor = LIGHT_GREY
        tableView.rowHeight = 150
    }

    /// Checks whether the thumbnailArray changed between the last and current load from
    /// Core Data.
    fileprivate func thumbnailArrayChanged() -> Bool {
        let oldArray = thumbnailArray
        let newArray = loadThumbnails()
        return true
    }

    /// Populates the thumbnailArray with thumbnails.
    fileprivate func setUpThumbnailArray() {
        self.thumbnailArray = loadThumbnails()
    }

    /// Loads thumbnails from Core Data.
    fileprivate func loadThumbnails() -> [Thumbnail] {
        guard let thumbnails = CoreDataManager.loadAllThumbnails() else {
            return []
        }
        return thumbnails
    }

    // MARK: - Button handler methods.

    @objc func addButtonPressed(_ sender: UIButton) {
        // FIXME: Perhaps a different segue animation is more fitting? Need feedback.
        let drawingViewController = DrawingViewController()
        self.present(drawingViewController, animated: true, completion: nil)
    }

    // MARK: - Table view data source.

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thumbnailArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MainMenuDrawingTableViewCell(thumbnail: thumbnailArray[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let drawingVC = DrawingViewController()
        drawingVC.previousDrawing = thumbnailArray[indexPath.row].drawing
        present(drawingVC, animated: true, completion: nil)
    }

    /// Gets the duplication action, for a specific row in the table.
    ///
    /// - Parameter indexPath: the indexPath at which the original swiping was done.
    /// - Returns: the duplicate contextual action.
    private func getDuplicateAction(forIndexPath indexPath: IndexPath) -> UIContextualAction {

        let duplicateAction = UIContextualAction(style: .normal, title: "Duplicate") { _, _, completionHandler in

            // Grab the current cell.
            let currentDrawing = self.thumbnailArray[indexPath.row].drawing
            let currentThumbnail = currentDrawing.thumbnail

            // Create new thumbnail.
            let duplicatedDrawing = Drawing(drawing: currentDrawing)
            let duplicatedThumbnail = Thumbnail(thumbnail: currentThumbnail)

            // Reset relationships.
            duplicatedDrawing.thumbnail = duplicatedThumbnail
            duplicatedThumbnail.drawing = duplicatedDrawing

            // Duplicate drawing in CoreData.
            CoreDataManager.duplicateDrawing(duplicatedDrawing: duplicatedDrawing)
            self.setUpThumbnailArray()
            self.tableView.reloadData()

            completionHandler(true)

        }

        return duplicateAction
    }

    /// Convenience getter for a preconfigured UIContextualAction that is used to
    /// delete a drawing.
    ///
    /// - Parameter indexPath: table view index path
    /// - Returns: a UIContextualAction that deletes the drawing that is displayed in
    ///   the cell that is identified by the indexPath.
    private func getDeleteAction(forIndexPath indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in

            // Grab deleted thumbnail, remove it from the array
            // and delete the corresponding CoreData entry.
            let deletedThumbnail = self.thumbnailArray.remove(at: indexPath.row)
            CoreDataManager.deleteDrawing(correspondingThumbnail: deletedThumbnail)
            self.tableView.reloadData()
            completionHandler(true)
        }

        return deleteAction
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // Setup swipe actions.
        let duplicateAction = getDuplicateAction(forIndexPath: indexPath)
        let deleteAction = getDeleteAction(forIndexPath: indexPath)

        duplicateAction.backgroundColor = UIColor.darkGray
        deleteAction.backgroundColor = UIColor.red

        return UISwipeActionsConfiguration(actions: [deleteAction, duplicateAction])
    }

}
