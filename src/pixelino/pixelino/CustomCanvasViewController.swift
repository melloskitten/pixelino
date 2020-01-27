//
//  CustomCanvasViewController.swift
//  pixelinoo
//
//  Created by Sandra Grujovic on 27.01.20.
//  Copyright © 2020 Sandra Grujovic. All rights reserved.
//

import UIKit
import Hero

class CustomCanvasViewController: UIViewController {

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // TODO
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO
    }

    private func setUpView() {

        // Transparency related settings.
        view.isOpaque = false
        view.backgroundColor = TRANSPARENT_MID_GREY

        // Set up navigation bar and button.
        navigationItem.title = "Select Custom Canvas"
        let dismissButton = UIButton(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: 0, height: 0)))
        dismissButton.layer.cornerRadius = 20
        dismissButton.titleLabel?.text = "X"
        dismissButton.backgroundColor = DARK_GREY
        dismissButton.setImage(UIImage(named: "Exit"), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        self.view.addSubview(dismissButton)

        // Set up Title.
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.font = UIFont(name: CustomFonts.roboto.rawValue, size: 25)
        titleLabel.text = "Custom Canvas"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        self.view.addSubview(titleLabel)

        // TODO: add rest of constraints.

        // Dismiss button.
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(
            equalTo: view!.topAnchor, constant: 100.0).isActive = true
        dismissButton.rightAnchor.constraint(
            equalTo: view!.rightAnchor, constant: -50.0).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Title label.
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(
            equalTo: dismissButton.centerYAnchor).isActive = true
        titleLabel.rightAnchor.constraint(
            equalTo: dismissButton.leftAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

    }

    @objc func dismissButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }

}
