//
//  DataServices.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 02/01/21.
//

import Foundation
protocol DataServicesProtocol {
    func getVehicles(completion:@escaping (Bool,String)->Void)
    func getPlanets(completion:@escaping(Bool,String)->Void)
    func findFalconeWithBody(body:FindFalconeMessageBody,completion: @escaping(Bool,String)->Void)
}

class DataService : DataServicesProtocol{
    var vehicleArray = [Vehicle]()
    var originalVehicleArray = [Vehicle]()
    var planetArray = [Planet]()
    var status:FindFalconeStatus?
    let api = Api()
    let extractor = DataExtractor()
    
    func getVehicles(completion:@escaping (Bool,String)->Void){
        extractor.getData(url: api.getVehiclesUrl) { (vehicles:Vehicles?, error:JSONError?)->Void in
            
            if let error = error{
                let errorDesc = "\(error)"
                completion(false,errorDesc)
            }
            
            if let allVehicles = vehicles{
                allVehicles.forEach({ (vehicleElement) in
                    self.vehicleArray.append(vehicleElement)
                    self.originalVehicleArray.append(vehicleElement)
                })
                completion(true,"")
                return
            }
            completion(false,"No Data")
        }
    }
    
    func getPlanets(completion:@escaping(Bool,String)->Void){
        extractor.getData(url: api.getPlanetsUrl) { (planet: Planets?,error:JSONError?)->Void in
            
            if let error = error{
                let errorDesc = "\(error)"
                completion(false,errorDesc)
            }
            
            if let aPlanet = planet{
                aPlanet.forEach({ (planetElement) in
                    self.planetArray.append(planetElement)
                })
                completion(true,"")
                return
            }
            completion(false,"No Data")
        }
    }
    
    fileprivate func findFalconWithToken(_ token:String,_ planetNames: [String], _ vehicleNames: [String], completion: @escaping(Bool,String)->Void) {
        if !token.isEmpty{
            self.extractor.findFalcone(url: self.api.findFalconeUrl, body: PathFinder(token: token, planetNames: planetNames, vehicleNames:vehicleNames)) { (status:FindFalconeStatus?,error:JSONError?) in
                
                if let error = error{
                    let errorDesc = "\(error)"
                    completion(false,errorDesc)
                }
                
                if let aStatus = status{
                    print("status\(aStatus)")
                    self.status = aStatus
                    completion(true,"")
                    return
                }
                completion(false,"No Data")
            }
        }
    }
    
    func findFalconeWithBody(body:FindFalconeMessageBody,completion: @escaping(Bool,String)->Void){
        
        let tokenbody = ["":""]
        extractor.postDataWithBody(url: api.getTokenUrl, body: tokenbody) { (tokenModel:TokenModel?,error:JSONError?)->Void in
            guard let aToken = tokenModel else{
                print("Retrieving Token Failed")
                
                if let error = error{
                    let errorDesc = "\(error)"
                    completion(false,errorDesc)
                }
                
                return
            }
            var aBody = body
            aBody.token = aToken.token
            
            
            if !aBody.token.isEmpty{
                
                let bodyParameters = ["token":aBody.token,"planet_names":aBody.planetNames,"vehicle_names":aBody.vehicleNames] as [String : Any]

                self.extractor.findFalcone(url: self.api.findFalconeUrl, body: bodyParameters, completion:{(status:FindFalconeStatus?,error:JSONError?) in

                    if let error = error{
                        let errorDesc = "\(error)"
                        completion(false,errorDesc)
                    }

                    if let aStatus = status{
                        print("status\(aStatus)")

                        if(aStatus.status == "false"){
                            let findFalconeStatus = FindFalconeStatus(planetName: "No Planet found", status: "false")
                            self.status = findFalconeStatus
                            completion(true,"")
                        }
                        else{
                                self.status = aStatus
                                completion(true,"")
                        }
                    }
                })
            }
        }
    }    
}
