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

class PhotoAlbumViewController : UIViewController {
    
    //MARK: Injections from TravelLocationsViewController
    var thePin: Pin!
    var dataController : DataController!
    
    //MARK: Instance Variables
    var photos:[Photo] = []
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            }
        }
    }
}
