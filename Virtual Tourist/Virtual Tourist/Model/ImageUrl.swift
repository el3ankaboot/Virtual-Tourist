//
//  ImageUrl.swift
//  Virtual Tourist
//
//  Created by Gamal Gamaleldin on 4/19/19.
//  Copyright © 2019 el3ankaboot. All rights reserved.
//

import Foundation

class ImageUrl {
    var farmID: Int
    var serverID: String
    var id: String
    var secret: String
    
    init(farmID: Int , serverID: String , id:String , secret: String) {
        self.farmID = farmID
        self.serverID = serverID
        self.id = id
        self.secret = secret
    }
    
    func getURL() -> String {
        return "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret).jpg"
    }
    

}
