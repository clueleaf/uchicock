//
//  AlbumCollectionViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/15.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var recipeNameBackgroundView: UIView!
    @IBOutlet weak var recipeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        highlightView.backgroundColor = UIColor.clear
    }
}
