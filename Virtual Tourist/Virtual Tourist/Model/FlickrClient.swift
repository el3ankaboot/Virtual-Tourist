//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Gamal Gamaleldin on 4/12/19.
//  Copyright © 2019 el3ankaboot. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FlickrClient {
    
    static let apiKey = "079b2f7ad0e5b05ccf1ccac21432365e"
//    let secret = "feaaeda0963fd3e5"
    
    enum endPoints {
        static let baseURL = "URL: https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)"
        
        case search(String,String)
        
        var stringValue : String {
            switch self {
            case .search(let longitude, let latitude):
                return endPoints.baseURL + "&lat=\(latitude)&lon=\(longitude)&radius=10&format=json&nojsoncallback=1&per_page=9"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
}
