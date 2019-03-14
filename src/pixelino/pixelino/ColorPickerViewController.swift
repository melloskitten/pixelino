//
//  ColorPickerViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 31.07.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit
import Pikko
import CoreData

class ColorPickerViewController: UIViewController {

    weak var colorChoiceDelegate: ColorChoiceDelegate?
    var colorHistoryCollectionView: UICollectionView!
    var pikko: Pikko!
    var colorHistory = [UIColor]()

    init(initialColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        setUpColorPicker()
        setColorOnPicker(color: initialColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setUpColorPicker() {
        // TODO: Adjust the position of the color picker dynamically.
        pikko = Pikko(dimension: 360)
        pikko.center = CGPoint(x: view.frame.width / 2.0, y: 360 / 2 + 20)
        setCurrentColorOnColorPicker()
        view.addSubview(pikko)
    }

    fileprivate func setCurrentColorOnColorPicker() {
        guard let mostRecentColor = self.colorHistory.first else {
            return
        }

        pikko.setColor(mostRecentColor)
    }

    fileprivate func setColorOnPicker(color: UIColor) {
        pikko.setColor(color)
    }

    fileprivate func setUpGestureRecognizer() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    fileprivate func setUpColorHistoryCollectionView() {
        // Initialise horizontal scrolling layout.
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal

        // TODO: Adjust the position of the collection view dynamically.
        colorHistoryCollectionView = UICollectionView(frame: CGRect(x: 0, y: 425, width: SCREEN_WIDTH, height: 50), collectionViewLayout: flowLayout)
        colorHistoryCollectionView.backgroundColor = .clear
        colorHistoryCollectionView.showsVerticalScrollIndicator = false
        colorHistoryCollectionView.showsHorizontalScrollIndicator = false

        // Set all needed indirections for collection view & register custom cell type.
        colorHistoryCollectionView.delegate = self
        colorHistoryCollectionView.dataSource = self
        colorHistoryCollectionView.register(ColorHistoryCollectionViewCell.self, forCellWithReuseIdentifier: "colorHistoryCell")

        view.addSubview(colorHistoryCollectionView)
    }

    override func viewDidLoad() {
        // Set up all data for the view.
        loadColorHistory()

        // Set up all visuals.
        self.view.backgroundColor = LIGHT_GREY
        setUpColorPicker()
        setUpColorHistoryCollectionView()
        setUpGestureRecognizer()
    }

    /// User dismissed the color picker view.
    @objc func dismissView(_ sender: UISwipeGestureRecognizer) {
        let color = pikko.getColor()
        colorWasSelected(color: color)
        dismiss(animated: true, completion: nil)
    }

    // Fetch the color history from core data.
    private func loadColorHistory() {
        guard let loadedColorHistory = CoreDataManager.loadColorHistory() else {
            return
        }
        self.colorHistory = loadedColorHistory
    }

    // Saves current color history to CoreData while respecting the number of occurences. (max. 1)
    private func saveColorInColorHistoryOnce(color: UIColor) {
        // Check whether the saved color is in our current color history.
        if colorHistory.contains(color) {
            // Delete the last occurence of the color.
            CoreDataManager.deleteColorInColorHistory(color: color)

            // Save the current color.
            CoreDataManager.saveColorInColorHistory(color: color)
        } else {
            CoreDataManager.saveColorInColorHistory(color: color)
        }
    }

    /// Update the color that was selected by the user (either from the picker or from the history).
    private func colorWasSelected(color: UIColor) {
        saveColorInColorHistoryOnce(color: color)
        colorChoiceDelegate?.colorChoicePicked(color)

        // Update the Pikko color since this method might be called after a history color was loaded.
        pikko.setColor(color)
    }
}

extension ColorPickerViewController: UICollectionViewDelegate {
}

extension ColorPickerViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Currently there is a hard coded amount of color history slots.
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorHistoryCell", for: indexPath) as! ColorHistoryCollectionViewCell

        if indexPath.row >= colorHistory.count || colorHistory.isEmpty {
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = colorHistory[indexPath.row]
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= colorHistory.count || colorHistory.isEmpty {
            // If user attempts to click an empty element in the color history, do nothing.
            return
        } else {
            colorWasSelected(color: self.colorHistory[indexPath.row])
        }
    }
}

extension ColorPickerViewController: UICollectionViewDelegateFlowLayout {
}
