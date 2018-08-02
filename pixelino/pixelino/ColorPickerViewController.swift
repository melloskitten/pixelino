//
//  ColorPickerViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 31.07.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit
import ChromaColorPicker

class ColorPickerViewController: UIViewController {
    
    var colorChoiceDelegate : ColorChoiceDelegate?
    var colorHistoryCollectionView : UICollectionView!
    var colorHistory = [UIColor]()
    
    fileprivate func setUpColorPicker() {
        // TODO: Adjust the position of the color picker dynamically.
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        neatColorPicker.delegate = self
        neatColorPicker.padding = 10
        neatColorPicker.stroke = 10
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.center.x = view.center.x
        
        view.addSubview(neatColorPicker)
    }
    
    fileprivate func setUpGestureRecognizer() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    override func viewDidLoad() {
        self.view.backgroundColor = lightGrey
        setUpColorPicker()
        setUpGestureRecognizer()
        
        colorHistory = [.red, .blue, .green, .yellow, .white, .black, .purple]
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        // Add the collection view
        colorHistoryCollectionView = UICollectionView(frame: CGRect(x: 50, y: 50, width: SCREEN_WIDTH, height: 50), collectionViewLayout: flowLayout)
        
        colorHistoryCollectionView.delegate = self
        colorHistoryCollectionView.dataSource = self
        colorHistoryCollectionView.register(ColorHistoryCollectionViewCell.self, forCellWithReuseIdentifier: "colorHistoryCell")
        
        view.addSubview(colorHistoryCollectionView)
        

        
        
        
    }
    
    @objc func dismissView(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension ColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        dismiss(animated: true, completion: nil)
        colorChoiceDelegate?.colorChoicePicked(color)
    }
}

extension ColorPickerViewController: UICollectionViewDelegate {
}

extension ColorPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if colorHistory.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorHistoryCell", for: indexPath) as! ColorHistoryCollectionViewCell
            cell.backgroundColor = .black
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorHistoryCell", for: indexPath) as! ColorHistoryCollectionViewCell
        cell.backgroundColor = colorHistory[indexPath.row]
        return cell 
    }
}

extension ColorPickerViewController: UICollectionViewDelegateFlowLayout {

    
}


