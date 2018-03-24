//
//  Requests.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/22/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import Foundation

func getImages(lattitude:Double,longitude:Double,completionHandler:@escaping(_ success:Bool,_ allPics:[String]) -> Void){
    var sample:[String] = []
    let parameters:[String:Any] = [
        Constants.APIKeys.Method:Constants.APIValues.SearchMethod,
        Constants.APIKeys.API_KEY:Constants.APIValues.API_KEY_HERE,
        Constants.APIKeys.Lattitude:lattitude,
        Constants.APIKeys.longitude:longitude,
        Constants.APIKeys.Radius:Constants.APIValues.Radius_Value,
        Constants.APIKeys.Radius_Units:Constants.APIValues.Radius_Unit_Value,
        Constants.APIKeys.Extras:Constants.APIValues.Extras_Value,
        Constants.APIKeys.Format:Constants.APIValues.Format_Value,
        Constants.APIKeys.NoJSONCallback:Constants.APIValues.DisableJSONCallback,
        Constants.APIKeys.Per_Page:Constants.APIValues.Per_Page_Value
    ]
    let session = URLSession.shared
    let request = URLRequest(url:createUrlFromParameters(parameters: parameters))
    
    let task = session.dataTask(with: request) { (data, response, error) in
        
        guard (error == nil) else{
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            return
        }
        
        let parsedResult:[String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            
        }catch{
            fatalError("Cannot Serialize")
        }
        
        // guard error for response code
        
        if let photos = parsedResult["photos"] as? [String:AnyObject] {
            if  photos["total"] as! String == "0" {
                completionHandler(false,sample)
                return
            } else {
                if let allPhotos = photos["photo"] as? [[String:AnyObject]]{
                    for pic in allPhotos {
                        sample.append(pic["url_m"] as! String)
                    }
                    completionHandler(true,sample)
                }
            }
        }else{
            //Error Code
           print(parsedResult)
        }
    }
    task.resume()
}
func downloadImage(image:String,completionHandler:@escaping(_ success:Bool?,_ imageData:Data?) -> Void){
    let session = URLSession.shared
    let imageUrl = NSURL(string:image)
    let request: NSURLRequest = NSURLRequest(url:imageUrl! as URL)
    
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        if data == nil {
            completionHandler(false,nil)
        }else{
            completionHandler(true,data)
        }
    }
    task.resume()
}
func createUrlFromParameters(parameters:[String:Any])->URL{
    var components = URLComponents()
    components.scheme = Constants.FlickrUrl.Scheme
    components.host = Constants.FlickrUrl.Host
    components.path = Constants.FlickrUrl.Path
    components.queryItems = [URLQueryItem]()
    
    for(key,value) in parameters{
        let queryItem = URLQueryItem(name:key,value:"\(value)")
        components.queryItems?.append(queryItem)
    }
    return components.url!
}
