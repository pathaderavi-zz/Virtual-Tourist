//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/22/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController:UIViewController,MKMapViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource{
    var longitude:Double!
    var lattitude:Double!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapViewPhotos: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var allPics = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        configureMapView()
        DispatchQueue.global(qos: .userInitiated).async {
            getImages(lattitude: self.lattitude, longitude: self.longitude){ (status,results) in
                if status{
                    self.allPics = results
                    DispatchQueue.main.async {
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                        self.collectionView.reloadData()
                    }
                    
                }
            }
        }
    }
}

extension PhotosViewController{
    func configureMapView(){
        let location = CLLocationCoordinate2DMake(lattitude,longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1,0.1)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapViewPhotos.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        self.mapViewPhotos.addAnnotation(annotation)
        mapViewPhotos.isUserInteractionEnabled = false
    }
}

extension PhotosViewController{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let url = allPics[indexPath.row]
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        DispatchQueue.global(qos: .userInitiated).async {
            downloadImage(image: url) { (success, data) in
                DispatchQueue.main.async {
                    if success!{
                        cell.imageView.image = UIImage(data:data!)
                        cell.loadingIndicator.stopAnimating()
                    }
                }
                
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPics.count
    }
}
