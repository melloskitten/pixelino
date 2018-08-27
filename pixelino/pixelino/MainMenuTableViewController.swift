//
//  MainMenuTableViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 25.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {
    
    var drawingThumbnailArray: [DrawingThumbnail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load all saved images.
        setUpThumbnailArray()
        
        setUpViews()
    }
    
    fileprivate func setUpThumbnailArray() {
        // Load the actual image from core data.
        self.drawingThumbnailArray = [DrawingThumbnail(), DrawingThumbnail(), DrawingThumbnail()]
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
        return drawingThumbnailArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MainMenuDrawingTableViewCell(drawingThumbnail: drawingThumbnailArray[indexPath.row])
        return cell
    }
    
    @objc func addButtonPressed(_ sender: UIButton) {
        // FIXME: Perhaps a different segue animation is more fitting? Need feedback.
        let drawingViewController = DrawingViewController()
        self.present(drawingViewController, animated: true, completion: nil)
    }
    
}
