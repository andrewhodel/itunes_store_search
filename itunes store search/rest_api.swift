//
//  rest_api.swift
//  Clean Budget
//
//  Created by Andrew Hodel on 12/26/18.
//  Copyright © 2018. All rights reserved.
//

import Foundation

class rest_api: NSObject {
    
    let url: String = "https://itunes.apple.com/"
    
    struct movie: Decodable {
        var wrapperType: String?
        var kind: String?
        var previewUrl: String?
        var artworkUrl100: String?
        var artistName: String?
        var trackName: String?
        var trackPrice: Double?
    }
    
    struct result: Decodable {
        var resultCount: Int
        var results: [movie]?
    }
    
    // this is a get_request response
    struct get_request_resp {
        
        var error = true;
        var error_string = ""
        var response_code = 0
        var headers: [AnyHashable: Any] = [:]
        var data: Data = Data();
        
    }
    
    func get_request_async(endpoint: String, args: [String:String] = [:], completion: @escaping (_ result: (Bool, Data)) -> Void) -> URLSessionDataTask {
        
        // safe urlencode, swift doesn't get =, + and / which can exist in base64
        var arg_string = ""
        for (key, val) in args {
            
            var new_val = val
            
            var qs = ""
            for char in val {
                if (char == " ") {
                    // this api wants + for spaces
                    qs = qs + "+"
                } else {
                    qs = qs + String(char)
                }
            }
            
            new_val = qs
            
            var enc_key = (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) ?? ""
            var enc_val = (new_val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) ?? ""
            
            qs = ""
            for char in enc_key {
                if (char == "=") {
                    qs = qs + "%3D"
                } else if (char == "+") {
                    qs = qs + "%2B"
                } else if (char == "/") {
                    qs = qs + "%2F"
                } else {
                    qs = qs + String(char)
                }
            }
            
            enc_key = qs
            
            qs = ""
            for char in enc_val {
                if (char == "=") {
                    qs = qs + "%3D"
                } else if (char == "/") {
                    qs = qs + "%2F"
                } else {
                    qs = qs + String(char)
                }
            }
            
            enc_val = qs
            
            arg_string = arg_string + "&" + enc_key + "=" + enc_val
        }
        
        var resp = get_request_resp();
        
        let method = "GET"
        
        // setup the request
        let req_url = URL(string: self.url + endpoint + "?entity=movie&media=movie" + arg_string)
        print(req_url)
        var request = URLRequest(url: req_url!);
        
        // set the method
        request.httpMethod = method;
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                //print("error with https request", error)
                resp.error = true
                completion((true, data ?? Data()))
            }
            let httpResponse = response as? HTTPURLResponse
            if (httpResponse == nil || data == nil) {
                // this will happen when the request is cancelled
                // or there is a failure with the request
                //print("https request failure")
                return
            }
            if (200...299).contains(httpResponse!.statusCode) {
                // good response
                
                // all of the object information is in the response headers
                //print(httpResponse?.allHeaderFields)
                // data is the object as Data
                
                resp.headers = (httpResponse?.allHeaderFields)!;
                resp.data = data!;
                
                resp.error = false;
                completion((false, data!))
                
            } else {
                print("got bad https response code", httpResponse!.statusCode)
                print("response", response as Any)
                resp.error = true
                
                // set data to the statusCode
                // should be able to figure that out since apple can't manage to provide this in the completion handler
                // and they can't manage to get delegates and completion handlers to work together
                let custom_data = String(httpResponse!.statusCode).data(using: String.Encoding.utf8)
                
                let string: String = String(data: data!, encoding: .utf8)!;
                //print(string)
                completion((true, custom_data ?? Data()))
                
            }
            
        }
        
        task.resume();
        
        return task;
        
    }
    
}
