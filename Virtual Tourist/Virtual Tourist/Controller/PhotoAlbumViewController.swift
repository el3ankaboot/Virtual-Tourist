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
                FlickrClient.downloadImages(longitude: "\(thePin!.longitude)", latitude: "\(thePin!.latitude)", page: pageNo) { (imagesURLs, errMsg) in
                    guard let imagesURLs = imagesURLs else {
                        let alertVC = UIAlertController(title: errMsg , message: "", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertVC, animated: true)
                        return
                    }
                    print("Loaded Images")
                    self.imageURLs = imagesURLs
                    self.pageNo += 1
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: CollectionView stubs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageReusable", for: indexPath) as! PhotoCell
        
        cell.image.image = UIImage(named: "Unknown")
        
        
        let url = URL(string: imageURLs[(indexPath as NSIndexPath).row].getURL())
        let downloadQueue = DispatchQueue(label: "download", attributes: [])
        downloadQueue.async { () -> Void in

            // download Data
            if let url = url {
                let imgData = try? Data(contentsOf: url)
                // Turn it into a UIImage
                if let imgData = imgData {
                    let image = UIImage(data: imgData)

                    // display it
                    DispatchQueue.main.async(execute: { () -> Void in
                        if let img = image {
                            cell.image.image = img
                        }
                        else {
                            print("NO")
                        }
                    })
                }
            }


        }
        
        return cell
    }
    
}
