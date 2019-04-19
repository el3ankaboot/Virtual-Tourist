//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Gamal Gamaleldin on 4/12/19.
//  Copyright © 2019 el3ankaboot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoAlbumViewController : UIViewController, UICollectionViewDataSource , UICollectionViewDelegate {

    
    //MARK: Injections from TravelLocationsViewController
    var thePin: Pin!
    var dataController : DataController!
    
    //MARK: Instance Variables
    var photos:[Photo] = []
    var imageURLs:[ImageUrl] = []
    var pageNo = 1
    var cellLookAtPhotos = false
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Fetch Photos
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", thePin)
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if result.count > 0 { //MARK: Fetching Images from Persistent Store
                photos = result
                cellLookAtPhotos = true
            }
            else { //MARK: Downloading Images from Flickr
                downloadImagesFromFlickr()
            }
        }
    }
    
    //MARK: Function to Download Images:
    func downloadImagesFromFlickr () {
        //Delete the Core Data Saved Images
        for photo in self.photos {
            dataController.viewContext.delete(photo)
        }
        photos = []
        try? dataController.viewContext.save()
        cellLookAtPhotos = false
        FlickrClient.downloadImages(longitude: "\(thePin!.longitude)", latitude: "\(thePin!.latitude)", page: pageNo) { (imagesURLs, errMsg) in
            guard let imagesURLs = imagesURLs else {
                let alertVC = UIAlertController(title: errMsg , message: "", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertVC, animated: true)
                return
            }
            self.imageURLs = imagesURLs
            self.pageNo += 1
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: CollectionView stubs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(!cellLookAtPhotos){return self.imageURLs.count}
        else {return self.photos.count}
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageReusable", for: indexPath) as! PhotoCell
        
        cell.image.image = UIImage(named: "Unknown")
        
        if(!cellLookAtPhotos){
            let url = URL(string: imageURLs[(indexPath as NSIndexPath).row].getURL())
            let downloadQueue = DispatchQueue(label: "download", attributes: [])
            downloadQueue.async { () -> Void in

      
                if let url = url {
                    let imgData = try? Data(contentsOf: url)
                    if let imgData = imgData {
                        // CoreData
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.data = imgData
                        photo.pin = self.thePin
                        self.photos.append(photo)
                        try? self.dataController.viewContext.save()
                        let image = UIImage(data: imgData)
                        DispatchQueue.main.async(execute: { () -> Void in
                            if let img = image {
                                cell.image.image = img
                            }
                            
                        })
                    }
                }


            }
        }
        else {
            let data = photos[(indexPath as NSIndexPath).row]
            let image = UIImage(data: data.data!)
            DispatchQueue.main.async(execute: { () -> Void in
                if let img = image {
                    cell.image.image = img
                }
                
            })
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        //MARK: Deleting photo by clicking on it
        let alertVC = UIAlertController(title: "Are You sure you want to delete this image ?", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertVC] (_) in
            let photoToRemove = self.photos.remove(at: (indexPath as NSIndexPath).row)
            self.dataController.viewContext.delete(photoToRemove)
            try? self.dataController.viewContext.save()
            self.cellLookAtPhotos = true
            collectionView.reloadData()
            
        }))
        self.present(alertVC, animated: true)
    }

    
    //MARK: IBActions
    
    @IBAction func loadNewImages(_ sender: Any) {

        self.downloadImagesFromFlickr()
    }
    
}
