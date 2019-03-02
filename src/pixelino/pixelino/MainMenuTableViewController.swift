//
//  MainMenuTableViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 25.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {

    var thumbnailArray: [Thumbnail] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load all saved images.
        setUpThumbnailArray()
        setUpViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpThumbnailArray()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }

    /// Load thumbnails for preview.
    fileprivate func setUpThumbnailArray() {
        guard let thumbnails = CoreDataManager.loadAllThumbnails() else {
            thumbnailArray = []
            return
        }

        self.thumbnailArray = thumbnails

    }

    fileprivate func setUpViews() {
        // Set up navigation bar and button.
        navigationItem.title = "Main Menu"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))

        // Set up table view controller.
        tableView.backgroundColor = DARK_GREY
        tableView.separatorColor = LIGHT_GREY
        tableView.rowHeight = 150
    }

    // MARK: - Table view data source

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

    @objc func addButtonPressed(_ sender: UIButton) {
        // FIXME: Perhaps a different segue animation is more fitting? Need feedback.
        let drawingViewController = DrawingViewController()
        self.present(drawingViewController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedThumbnail = thumbnailArray.remove(at: indexPath.row)
            // Delete corresponding Core Data entry.
            CoreDataManager.deleteDrawing(correspondingThumbnail: deletedThumbnail)

            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }

}
