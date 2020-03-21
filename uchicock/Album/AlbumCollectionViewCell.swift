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
        
        highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)        
    }
}
