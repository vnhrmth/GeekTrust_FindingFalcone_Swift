//
//  DataExtractor.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import Foundation

protocol Extractor {
    func findFalcone(url: String, body: Any, completion: @escaping (FindFalconeStatus?,_ error:JSONError?) -> Void)
    func postDataWithBody<T:Codable>(url:String,body:[AnyHashable:Any],completion:@escaping(_ response:T?,_ error:JSONError?)->Void)
    func getData<T:Codable>(url:String,completion:@escaping (_ response:T?,_ error:JSONError?)->Void)
}

class DataExtractor : Extractor {
    var session : URLSession!

    func getData<T:Codable>(url:String,completion:@escaping (_ response:T?,_ error:JSONError?)->Void){
        let url = URL(string: url)
        let task = session.dataTask(with: url!) { (data, response, error) in
            do{
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {
                    print("error", error ?? "Unknown error")
                    throw JSONError.NoData
                }

                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    throw JSONError.Unknown
                }
                
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(T.self, from: data)
                completion(responseModel,nil)

            }
            catch let error as JSONError {
                print(error)
                completion(nil,error)
            }
            catch let error as NSError {
                print(error.debugDescription)
                completion(nil,(error as! JSONError))
            }
        }
        task.resume()
    }
    
    //    func postData<T:Codable>(url:String,completion:@escaping(_ response:T?,_ error:JSONError?)->Void){
    //        var request = URLRequest(url: URL(string: url)!)
    //        request.httpMethod = "POST"
    //
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.setValue("application/json", forHTTPHeaderField: "Accept")
    //        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    //            do {
    //                guard let data = data,
    //                        let response = response as? HTTPURLResponse,
    //                        error == nil else {
    //                        print("error", error ?? "Unknown error")
    //                        throw JSONError.NoData
    //                }
    //
    //                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
    //                    print("statusCode should be 2xx, but is \(response.statusCode)")
    //                    print("response = \(response)")
    //                    throw JSONError.Unknown
    //                }
    //
    //                let jsonDecoder = JSONDecoder()
    //                let responseModel = try jsonDecoder.decode(T.self, from: data)
    //                completion(responseModel,nil)
    //            } catch let error as JSONError {
    //                print(error)
    //                completion(nil,error)
    //            }
    //                catch let error as NSError {
    //                print(error.debugDescription)
    //                completion(nil,error as? JSONError)
    //            }
    //        }
    //        task.resume()
    //    }
    
    func postDataWithBody<T:Codable>(url:String,body:[AnyHashable: Any],completion:@escaping(_ response:T?,_ error:JSONError?)->Void){
        var request = URLRequest(url: URL(string: url)!)
        print(request)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body , options: .prettyPrinted)
        } catch {
            completion(nil,JSONError.SerializationError)
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {
                    print("error", error ?? "Unknown error")
                    throw JSONError.NoData
                }
                
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    throw JSONError.Unknown
                }
                
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(T.self, from: data)
                print(responseModel)
                completion(responseModel,nil)
            } catch let error as JSONError {
                print(error)
                completion(nil,error)
            }
            catch let error as NSError {
                print(error.debugDescription)
                completion(nil,error as? JSONError)
            }
        }
        
        task.resume()
    }
    
    func findFalcone(url: String, body: Any, completion: @escaping (FindFalconeStatus?,_ error:JSONError?) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            completion(nil,JSONError.SerializationError)
            return
        }
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                print("error", error ?? "Unknown error")
                completion(nil,JSONError.NoData)
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                completion(nil,JSONError.ResponseError)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do{
                let responseModel = try jsonDecoder.decode(Status.self, from: data)
                if(responseModel.status == "false"){
                    let findFalconeStatus = FindFalconeStatus(planetName: "", status: "false")
                    completion(findFalconeStatus,nil)
                }
                else{
                    let responseModel = try jsonDecoder.decode(FindFalconeStatus.self, from: data)
                    completion(responseModel,nil)
                }
            }
            catch let error as NSError{
                print(error)
                completion(nil,error as? JSONError)
            }
        }
        task.resume()
    }    
}

enum JSONError: Error {
    case NoData
    case ConversionFailed
    case Unknown
    case SerializationError
    case ResponseError
}
