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
    
    enum Endpoints {
        static let baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)"
        
        case search(String,String,Int)
        
        var stringValue : String {
            switch self {
            case .search(let longitude, let latitude, let page):
                return Endpoints.baseURL + "&lat=\(latitude)&lon=\(longitude)&radius=10&format=json&nojsoncallback=1&per_page=9&page=\(page)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    class func downloadImages (longitude:String, latitude: String, page: Int, completion: @escaping (Bool , String) -> Void){
        Alamofire.request(Endpoints.search(longitude, latitude, page).url, method: .get, encoding: JSONEncoding.default, headers: [:])
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Success")
                case .failure(_):
                    completion(false,"Failed to retrieve images.")
                    print("Failure")
                }
            }
            .response { response in
                if let data = response.data {
                    let json = JSON(data)
                    switch response.response?.statusCode {
                    case 200 :
                       completion(true ,"")
                        
                    default :
                        completion(false ,"Failed to retrieve images.")
                    }
                    
                }
        }
        
    }
   
}
