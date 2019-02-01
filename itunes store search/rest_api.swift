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
    
    // make a get request
    func get_request(endpoint: String, args: [String:String] = [:]) -> get_request_resp {
        
        // safe urlencode, swift doesn't get =, + and / which can exist in base64
        var arg_string = ""
        for (key, val) in args {
            var enc_key = (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) ?? ""
            var enc_val = (val.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) ?? ""
            
            var qs = ""
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
                } else if (char == "+") {
                    qs = qs + "%2B"
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
        //print(req_url)
        var request = URLRequest(url: req_url!);
        
        // set the method
        request.httpMethod = method;
        
        // semaphore can make an async call sync with signal() inside the async function and wait() outside
        let semaphore = DispatchSemaphore(value: 0)
        
        // setup the session, we are not using a shared session
        let session = URLSession(configuration: URLSessionConfiguration.default);
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error with https request", error)
                resp.error = true
                resp.error_string = error.localizedDescription
                
                semaphore.signal();
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if (httpResponse == nil || data == nil) {
                // this will happen when the request is cancelled
                // or there is a failure with the request
                resp.error = true
                resp.error_string = "no data returned"
                semaphore.signal();
                return
            }
            if (200...299).contains(httpResponse!.statusCode) {
                // good response
                resp.response_code = httpResponse!.statusCode
                resp.headers = (httpResponse?.allHeaderFields)!;
                resp.data = data!;
                resp.error = false;
                
                semaphore.signal();
                return;
                
            } else {
                //print("got bad https response code", httpResponse!.statusCode)
                //print("response", response as Any)
                
                resp.response_code = httpResponse!.statusCode
                resp.error = true
                resp.error_string = httpResponse.debugDescription
                resp.data = data!;
                
                semaphore.signal();
                return;
            }
            
        }
        
        task.resume();
        
        semaphore.wait()
        return resp;
        
    }
    
}
