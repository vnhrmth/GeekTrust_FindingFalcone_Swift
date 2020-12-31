//
//  DataExtractor.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import Foundation

protocol Extractor {
    func getPlanets(url:String, completion: @escaping (_ response: Planets?) -> Void)
    func getVehicles(url:String, completion: @escaping (_ response: Vehicles?)->Void)
    func getGetToken(url:String, completion:@escaping(_ response:TokenModel?)->Void)
    func findFalcone(url:String,body:PathFinder,completion:@escaping(_ response:FindFalconeStatus?)->Void)
}

class DataExtractor : Extractor {
      func getVehicles(url:String,completion: @escaping (_ response: Vehicles?) -> Void){
        let url = URL(string: url)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do{
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(Vehicles.self, from: data!)
                completion(responseModel)
            }
            catch{
                 print("Exception occured")
                 completion(nil)
            }
        }

        task.resume()
    }
    
    func getPlanets(url:String,completion: @escaping (_ response: Planets?) -> Void){
        let url = URL(string: url)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do{
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(Planets.self, from: data!)
                completion(responseModel)
            }
            catch{
                 print("Exception occured")
                 completion(nil)
            }
        }
        task.resume()
    }
    
    func getGetToken(url:String,completion:@escaping(_ response:TokenModel?)->Void){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(TokenModel.self, from: data)
                completion(responseModel)
            } catch let error as JSONError {
                print(error)
                completion(nil)
            }
                catch let error as NSError {
                print(error.debugDescription)
                completion(nil)
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
        
//        if (!JSONSerialization.isValidJSONObject()) {
//            print("is not a valid json object")
//            return
//        }
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
//            completion(nil, error)
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
            
            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString)")
            
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
//                completion(responseModel)
            }
            catch let error as NSError{
                print(error)
                completion(nil)
            }
//
            


//            do {
//                guard let data = data else {
//                    throw JSONError.NoData
//                }
//
////                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
////                    throw JSONError.ConversionFailed
////                }
//
//                let jsonDecoder = JSONDecoder()
//                let responseModel = try jsonDecoder.decode(FindFalconeStatus.self, from: data)
//                completion(responseModel)
//            } catch let error as JSONError {
//                print(error)
//                completion(nil)
//            }
//                catch let error as NSError {
//                print(error.debugDescription)
//                    completion(nil)
//            }
        }
        task.resume()
    }
}


enum JSONError: Error {
    case NoData
    case ConversionFailed
}
