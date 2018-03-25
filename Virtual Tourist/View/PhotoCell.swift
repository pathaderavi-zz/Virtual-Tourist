//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/22/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell:UICollectionViewCell{
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    var deleteStatus:Bool = false
}
