//
//  MainMenuTableViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 25.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation bar and button.
        self.navigationItem.title = "Main Menu"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        // Set up table view controller.
        self.tableView.register(MainMenuDrawingTableViewCell.self, forCellReuseIdentifier: "mainMenuDrawingTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // FIXME: Hardcoded values.
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuDrawingTableViewCell", for: indexPath)
        cell.textLabel?.text = "derp"
        return cell
    }
}
