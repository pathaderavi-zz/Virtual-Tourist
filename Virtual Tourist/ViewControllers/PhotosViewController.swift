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
    var count = 0
    var longitude:Double!
    @IBOutlet weak var noPinsToViewLabel: UILabel!
    var lattitude:Double!
    var deleteStatus:Bool = false
    var deleteIndices = [IndexPath]()
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapViewPhotos: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var dataController:DataController!
    var allPicUrls = [String]()
    var saveImages:Images!
    var allImages = [Images]()
    var pin:Pin!
    var fetchedResultsController:NSFetchedResultsController<Images>!
    var countButton:Int = 0
    var deleteImages = [Images]()
    var newCollectionStatusFlag:Bool = false
    var loadingIndicators = [Int]()
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
    var newCollectionStatus:Int = 0
    fileprivate func setupView() {
        loadingIndicators = []
        noPinsToViewLabel.isHidden = true
        fetchResults()
        setupFlowLayout()
        configureMapView()
        if allImages.count == 0{
            DispatchQueue.global(qos: .userInitiated).async {
                getImages(lattitude: self.lattitude, longitude: self.longitude){ (status,results) in
                    if status{
                        self.allPicUrls = results
                        DispatchQueue.main.async {
                            self.collectionView.delegate = self
                            self.collectionView.dataSource = self
                            self.collectionView.reloadData()
                            
                            if self.allPicUrls.count < 15 {
                                self.newCollectionButton.isEnabled = false
                            }else{
                                self.newCollectionButton.isEnabled = true
                            }
                        }
                        
                    }
                }
            }
            
        }else{
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }
    }
    @IBAction func newCollectionButton(_ sender: Any) {
        loadingIndicators = []
        newCollectionButton.setTitle("New Collection", for: .normal)
        newCollectionButton.isEnabled = false
        if dataController.viewContext.hasChanges{
            try? dataController.viewContext.save()
        }
        if deleteStatus{
      
            fetchResults()
            for i in deleteIndices{
                dataController.viewContext.delete(allImages[i.row])
            }
            try? dataController.viewContext.save()
            fetchResults()
            deleteStatus = false
            deleteIndices = []
            if fetchedResultsController.fetchedObjects?.count == 0 {
                //newCollectionButton(sender)
                //setupView()
                noPinsToViewLabel.isHidden = false
                collectionView.reloadData()
            }else{
                newCollectionStatusFlag = true
                collectionView.reloadData()
            }
            newCollectionButton.isEnabled = true
            return
        }
        newCollectionStatusFlag = false
        fetchResults()
        for images in allImages {
            dataController.viewContext.delete(images)
        }
        try? dataController.viewContext.save()
        allImages = []
        
        if newCollectionStatus == 0 && collectionView.visibleCells.count == 0{
            setupView()
            newCollectionStatus = 1
        }else{
            fetchResults()
            let removeItems:Int = min(allPicUrls.count,15)
            allPicUrls.removeFirst(removeItems)
        }
        collectionView.reloadData()
        if (allPicUrls.count == 0 ){
            noPinsToViewLabel.isHidden = false
            newCollectionStatus = 0
        }
        newCollectionButton.isEnabled = true
        
    }
    func fetchResults(){
        newCollectionButton.isEnabled = false
        let fetchRequest:NSFetchRequest<Images> = Images.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"photo",ascending:false)]
        let predicate = NSPredicate(format:"(pin == %@)",pin)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            allImages = fetchedResultsController.fetchedObjects!
        }catch{
            fatalError("Cannot fetch")
        }
        newCollectionButton.isEnabled = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        if !loadingIndicators.contains(indexPath.row){
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = UIColor.white
            let contain:Bool = deleteIndices.contains(indexPath)
            if contain{
                cell?.contentView.alpha = 1
                deleteIndices.remove(at: deleteIndices.index(of: indexPath)!)
            }
            else{
                deleteIndices.append(indexPath)
                cell?.contentView.alpha = 0.4
            }
            if deleteIndices.count != 0 {
                newCollectionButton.setTitle("Delete Selected", for: .normal)
                deleteStatus = true
            }else{
                newCollectionButton.setTitle("New Collection", for: .normal)
                deleteStatus = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.loadingIndicator.startAnimating()
        loadingIndicators.append(indexPath.row)
        cell.deleteStatus = false
        if !deleteIndices.contains(indexPath){
            cell.contentView.alpha = 1
        }else{
            cell.backgroundColor = UIColor.white
            cell.contentView.alpha = 0.4
        }
        if allImages.count != 0 {
            let image = allImages[indexPath.row].photo as! Data
            cell.imageView.image = UIImage(data:image)
            cell.loadingIndicator.stopAnimating()
            loadingIndicators.remove(at: loadingIndicators.index(of: indexPath.row)!)
            //            if !deleteIndices.contains(indexPath){
            //
            //                cell.contentView.alpha = 1
            //            }
            
        }else{
            let url = allPicUrls[indexPath.row]
            cell.imageView.image = nil
            if self.count < 9{
                self.newCollectionButton.isEnabled = false
            }
            DispatchQueue.global(qos: .userInitiated).async {
                downloadImage(image: url) { (success, data) in
                    DispatchQueue.main.async {
                        if success!{
                            cell.imageView.image = UIImage(data:data!)
                            cell.loadingIndicator.stopAnimating()
                            if self.loadingIndicators.contains(indexPath.row){
                                self.loadingIndicators.remove(at: self.loadingIndicators.index(of: indexPath.row)!)
                            }
                            self.count += 1
                            if self.count > 0 {
                                self.noPinsToViewLabel.isHidden = true
                            }
                            
                            if self.count > 9 || self.count == self.allPicUrls.count{
                                self.newCollectionButton.isEnabled = true
                            }
                            if self.count < 15 {
                                self.saveImages = Images(context:self.dataController.viewContext)
                                self.saveImages.photo = data
                                self.saveImages.pin = self.pin
           
                                do{
                                    try self.dataController.viewContext.save()
                                }
                                catch{
                                    fatalError("Could Not Add")
                                }
                            }
                            if self.count == self.collectionView.visibleCells.count{
                                self.count = 0
                            }
                        }
                    }
                    
                }
                
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if newCollectionStatusFlag{
            return min(allImages.count, 15)
        }
        
        return max(min(allPicUrls.count,15),min(allImages.count,15))
    }
}


