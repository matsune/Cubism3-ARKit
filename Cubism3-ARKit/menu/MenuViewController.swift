//
//  MenuViewController.swift
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

import Foundation
import UIKit

struct MenuItem {
    let title: String
    let image: UIImage
}

protocol MenuViewControllerDelegate: class {
    func didSelectRestart()
    func didChange(isHiddenFace: Bool)
    func didSelctChangeAvatar()
}

final class MenuViewController: UICollectionViewController {
    
    public var isHiddenFace = false
    public weak var delegate: MenuViewControllerDelegate?
    
    private let items: [MenuItem] = [MenuItem(title: "Restart", image: #imageLiteral(resourceName: "restart")),
                                     MenuItem(title: "Face", image: #imageLiteral(resourceName: "none")),
                                     MenuItem(title: "Change", image: #imageLiteral(resourceName: "avatar"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = CGSize(width: 200, height: 70)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as? MenuCell else {
            fatalError("could not dequeue menuCell")
        }
        let menu = items[indexPath.row]
        cell.bind(menu: menu)
        if indexPath.row == 1 {
            cell.isSelected = isHiddenFace
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.didSelectRestart()
        } else if indexPath.row == 1 {
            delegate?.didChange(isHiddenFace: !isHiddenFace)
        } else {
            delegate?.didSelctChangeAvatar()
        }
        dismiss(animated: true, completion: nil)
    }
}
