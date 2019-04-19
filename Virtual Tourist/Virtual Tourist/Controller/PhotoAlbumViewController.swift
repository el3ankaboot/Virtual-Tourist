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
                print("has images")
                photos = result
            }
            else { //MARK: Downloading Images from Flickr
                print("has NOO images")
                FlickrClient.downloadImages(longitude: "\(thePin!.longitude)", latitude: "\(thePin!.latitude)", page: 1) { (success, errMsg) in
                    guard success != nil else {
                        let alertVC = UIAlertController(title: errMsg , message: "", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertVC, animated: true)
                        return
                    }
                  print("Loaded Images")
                }
            }
        }
    }
    
    
    //MARK: CollectionView stubs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageReusable", for: indexPath) as! PhotoCell
        let photo = self.photos[(indexPath as NSIndexPath).row]
        
        
        cell.image?.image = UIImage(data:photo.data!,scale:1.0)
        
        return cell
    }
    
}
