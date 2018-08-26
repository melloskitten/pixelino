//
//  MainMenuDrawingTableViewCell.swift
//  pixelino
//
//  Created by Sandra Grujovic on 25.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit

class MainMenuDrawingTableViewCell: UITableViewCell {
    
    convenience init(drawingThumbnail: DrawingThumbnail) {
        self.init(style: .subtitle, reuseIdentifier: nil)
        
        textLabel?.text = drawingThumbnail.fileName
        // FIXME: This most likely will be changed since the thumbnails will be generated and not part of the assets.
        imageView?.image = UIImage(named: drawingThumbnail.imageReference)
        detailTextLabel?.text = "\(drawingThumbnail.dateLastChanged)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func setUpView() {
        contentView.backgroundColor = DARK_GREY
        textLabel?.textColor = .white
        detailTextLabel?.textColor = .gray
        separatorInset = UIEdgeInsets.zero
    }
}
