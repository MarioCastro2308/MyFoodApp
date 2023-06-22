//
//  NutritionDataManager.swift
//  MyFoodApp
//
//  Created by Mario Castro on 19/06/23.
//

import Foundation

struct NutritionDataManager {
    var delegate : NutritionDataManagerDelegate?
    let baseUrl :  String = "https://api.edamam.com/api/nutrition-data?app_id=52dc1797&app_key=%205bc417cef9f54c5a9897bf2730313c46&nutrition-type=cooking"
    
    func fetchNutritionData (for complement : String) {
        let replacedComplement = complement.replacingOccurrences(of: " ", with: "%20")
        let completeUrl : String = "\(baseUrl)&ingr=\(replacedComplement)"
        performRequest(with: completeUrl)
    }
    
    func performRequest(with urlString : String){
        // 1. Create URL
        if let url = URL(string: urlString) {
            // 2. Create URLSession
            let session = URLSession(configuration: .default)
            // 3. Give URLSession a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let data = parseJSON(safeData) {
                        delegate?.didUpdateComplementData(self, complementData: data)
                    }
                }
            }
            // 4. Start task
            task.resume()
        } else {
            print("sorry")
        }
    }
    
    func parseJSON(_ nutritionData : Data) -> NutritionModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(NutritionData.self, from: nutritionData)
            // General Data
            let foodMatch = decodeData.ingredients[0].parsed[0].foodMatch
            let quantity = decodeData.ingredients[0].parsed[0].quantity
            let measure = decodeData.ingredients[0].parsed[0].measure
            // Macro Nutrients
            let kcal = decodeData.ingredients[0].parsed[0].nutrients.ENERC_KCAL.quantity
            let proteins = decodeData.ingredients[0].parsed[0].nutrients.PROCNT.quantity
            let fats = decodeData.ingredients[0].parsed[0].nutrients.FAT.quantity
            let carbs = decodeData.ingredients[0].parsed[0].nutrients.CHOCDF.quantity
            
            let complementData = NutritionModel(foodMatch: foodMatch.uppercased(), quantity: quantity, measure: measure, proteins: proteins, fats: fats, carbs: carbs, kcal: kcal)
            
            return complementData
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

protocol NutritionDataManagerDelegate {
    func didUpdateComplementData(_ nutritionDataManager : NutritionDataManager, complementData : NutritionModel)
    func didFailWithError(error : Error)
}

