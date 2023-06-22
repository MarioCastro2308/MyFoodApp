//
//  NutritionData.swift
//  MyFoodApp
//
//  Created by Mario Castro on 19/06/23.
//

import Foundation

struct NutritionData : Decodable {
    let ingredients : [Ingredients]
}

struct Ingredients : Decodable {
    let parsed : [IngredientsData]
}

struct IngredientsData : Decodable{
    let foodMatch : String
    let quantity : Int
    let measure : String
    let nutrients : NutrientList
}

struct NutrientList : Decodable {
    let ENERC_KCAL : NutrientData
    let PROCNT : NutrientData
    let FAT : NutrientData
    let CHOCDF : NutrientData
}

struct NutrientData : Decodable {
    let label : String
    let quantity : Float
    let unit : String
}

