//
//  RequestService.swift
//  EnnoWallet
//
//  Created by Hayrettin İletmiş on 15.03.2023.
//  Copyright © 2023 DigiliraPay. All rights reserved.
//

import Foundation

class RequestService: NSObject {
    
    enum Method: String {
        case put = "PUT"
        case get = "GET"
        case post = "POST"
        
        func val()-> String {
            self.rawValue
        }
    }
     
    class func New<T>(rURL: String, postData: Data? = nil, urlParams: [URLQueryItem] = [], method: Method = .post, sender: T.Type, completion: @escaping (_ result: T?, _ statusCode: Int, _ error: Error?)->()) where T: Decodable {
        
        if let url = URL(string: rURL) {
            
            var request = URLRequest(url: url)
            
            request.httpMethod = method.val()
            
            if let json = postData {
                request.httpBody = json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            if urlParams != [] {
                for item in urlParams {
                    if let url = request.url {
                        request.url? = url.appending(item:item)
                    }
                }
            }
            
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
            
            let task = session.dataTask(with: request) { (data, response, error) in

                if let error = error {
                    completion(nil, error._code, .none)
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if error != nil {
                        completion(nil, 555, error as? Error)
                    } else if data != nil {
                        
                        guard let dataResponse = data, error == nil else {
                            completion(nil, httpResponse.statusCode, error as? Error)
                            return
                        }
                        
                        do{
                            completion(try JSONDecoder().decode(T.self, from: dataResponse), httpResponse.statusCode, nil)
                        } catch let parsingError {
                            completion(nil, httpResponse.statusCode, parsingError as? Error)
                        }
                    }
                }
            }
            task.resume()
        }
        
    }
}
