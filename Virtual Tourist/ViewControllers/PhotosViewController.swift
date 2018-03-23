//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/22/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController:UIViewController,MKMapViewDelegate{
    var longitude:Double!
    var lattitude:Double!
    
    @IBOutlet weak var mapViewPhotos: MKMapView!
    var allPics:[String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        
        DispatchQueue.global(qos: .userInitiated).async {
            getImages(lattitude: self.lattitude, longitude: self.longitude){ (status,results) in
                if status{
                    self.allPics = results
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
