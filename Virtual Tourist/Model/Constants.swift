//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/22/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import Foundation

class Constants{
    
    struct FlickrUrl{
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
    }
    
    struct APIKeys{
        static let Method = "method"
        static let API_KEY = "api_key"
        static let Lattitude = "lat"
        static let longitude = "lon"
        static let Radius = "radius"
        static let Radius_Units = "radius_units"
        static let Extras = "extras"
        static let Per_Page = "per_page"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct APIValues{
        static let SearchMethod = "flickr.photos.search"
        static let API_KEY_HERE = "309b44c81c2e03ee56a8f8013059c4cc"
        static let Radius_Value = "20"
        static let Radius_Unit_Value = "mi"
        static let Extras_Value = "url_m"
        static let Per_Page_Value = "500"
        static let Format_Value = "json"
        static let DisableJSONCallback = "1"
    }
    
    struct ResponseKeys{
        
    }
    
    struct ResponseValues{
        
    }
}

