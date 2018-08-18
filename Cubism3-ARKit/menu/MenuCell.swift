//
//  MenuCell.swift
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

import Foundation
import UIKit

final class MenuCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .lightGray
            } else {
                backgroundColor = .clear
            }
        }
    }
    
    func bind(menu: MenuItem) {
        imageView.image = menu.image
        label.text = menu.title
    }
}
