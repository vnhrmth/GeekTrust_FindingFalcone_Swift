//
//  DataExtractor.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import Foundation

protocol Extractor {
    func findFalcone(url:String,body:PathFinder,completion:@escaping(_ response:FindFalconeStatus?)->Void)
    func postData<T:Codable>(url:String,completion:@escaping(_ response:T?)->Void)
    func getData<T:Codable>(url:String,completion:@escaping (_ response:T?,_ error:JSONError?)->Void)
}

class DataExtractor : Extractor {
    func getData<T:Codable>(url:String,completion:@escaping (_ response:T?,_ error:JSONError?)->Void){
        let url = URL(string: url)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do{
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
    
    func postData<T:Codable>(url:String,completion:@escaping(_ response:T?)->Void){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
    
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                completion(responseModel)
            } catch let error as JSONError {
                print(error)
                completion(error as? T)
            }
                catch let error as NSError {
                print(error.debugDescription)
                    completion(error as? T)
            }
        }
        task.resume()
    }
    
    func findFalcone(url: String, body: PathFinder, completion: @escaping (FindFalconeStatus?) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let bodyParameters = ["token":body.token,"planet_names":body.planetNames,"vehicle_names":body.vehicleNames] as [String : Any]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
            
                let jsonDecoder = JSONDecoder()
                do{
                    let responseModel = try jsonDecoder.decode(Status.self, from: data)
                    if(responseModel.status == "false"){
                        let findFalconeStatus = FindFalconeStatus(planetName: "", status: "false")
                        completion(findFalconeStatus)
                    }
                    else{
                        let responseModel = try jsonDecoder.decode(FindFalconeStatus.self, from: data)
                        completion(responseModel)
                    }
                }
                catch let error as NSError{
                    print(error)
                    completion(nil)
                }
        }
        task.resume()
    }
}

enum JSONError: Error {
    case NoData
    case ConversionFailed
    case Unknown
}
