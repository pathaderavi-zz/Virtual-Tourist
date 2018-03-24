//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/22/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController:UIViewController,MKMapViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate{
    var longitude:Double!
    var lattitude:Double!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapViewPhotos: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var dataController:DataController!
    var allPics = [String]()
    var saveImages:Images!
    var allImages:[Images]!
    var pin:Pin!
    var fetchedResultsController:NSFetchedResultsController<Images>!
    
    fileprivate func setupFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
    }
    func fetchResults(){
        let fetchRequest:NSFetchRequest<Images> = Images.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"photo",ascending:false)]
        let predicate = NSPredicate(format:"(pin == %@)",pin)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            allImages = fetchedResultsController.fetchedObjects
            print(allImages.count)
        }catch{
            fatalError("Cannot fetch")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowLayout()
        configureMapView()
        fetchResults()
        
        DispatchQueue.global(qos: .userInitiated).async {
            getImages(lattitude: self.lattitude, longitude: self.longitude){ (status,results) in
                if status{
                    self.allPics = results
                    DispatchQueue.main.async {
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                        self.collectionView.reloadData()
                    }
                    if self.allImages.count == 0 && self.allPics.count != 0 {
                        var count = 1
                        for pic in self.allPics{
                            downloadImage(image: pic, completionHandler: { (success, data) in
                                if success!{
                                    //print(count)
                                    
                                    self.saveImages = Images(context:self.dataController.viewContext)
                                    self.saveImages.photo = data
                                    self.saveImages.pin = self.pin
                                    do{
                                        try self.dataController.viewContext.save()
                                        print("inserted")
                                    }
                                    catch{
                                        fatalError("Could Not Add")
                                    }
                                    
                                }
                            })
                            if count < 12 {
                                count += 1
                                print(count)
                                
                            }else{
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PhotosViewController {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        if allImages.count != 0 {
            
            let image = allImages[indexPath.row].photo as! Data
            cell.imageView.image = UIImage(data:image)
            cell.loadingIndicator.stopAnimating()
        }else{
            let url = allPics[indexPath.row]
            
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
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(allPics.count,12)
    }
}
