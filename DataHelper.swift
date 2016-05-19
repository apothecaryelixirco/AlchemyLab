//
//  DataHelper.swift
//  AlchemyLab
//
//  Created by Randy Williams on 5/13/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Foundation


func getIngredientByUUID(UUID : String, ingredientLibrary : [Ingredient]) -> Ingredient?
{
    // i feel like we should be returning a copy of the ingredient to avoid problems...
    // change 05.19.2016 - copy ingredient instead of returning the actual one.
    print ("looking for ingredient " + UUID)
    if let i = ingredientLibrary.indexOf({$0.ID == UUID})
    {
        let ingredientToReturn = Ingredient();
        ingredientToReturn.Base = ingredientLibrary[i].Base;
        ingredientToReturn.Cost = ingredientLibrary[i].Cost;
        ingredientToReturn.Gravity = ingredientLibrary[i].Gravity;
        ingredientToReturn.ID = ingredientLibrary[i].ID;
        ingredientToReturn.Manufacturer = ingredientLibrary[i].Manufacturer;
        ingredientToReturn.Name = ingredientLibrary[i].Name;
        ingredientToReturn.Notes = ingredientLibrary[i].Notes;
        ingredientToReturn.PGRatioForIngredient = ingredientLibrary[i].PGRatioForIngredient;
        ingredientToReturn.Strength = ingredientLibrary[i].Strength;
        ingredientToReturn.Type = ingredientLibrary[i].Type;
        ingredientToReturn.VGRatioForIngredient = ingredientLibrary[i].VGRatioForIngredient;
        print ("found ingredient.");
        return ingredientToReturn;
//        return ingredientLibrary[i];
    }
    print ("did not find ingredient.");
    return nil;
}


func getIngredientUUIDInLibraryByIndex(index : Int, ingredientLibrary : [Ingredient]) -> String?
{
    if (index>0 && index<=ingredientLibrary.count)
    {
        return ingredientLibrary[index].ID;
    }
    return nil;
}

func getIngredientIndexInLibraryByUUID(UUID : String, ingredientLibrary : [Ingredient]) -> Int
{
    
    if let i = ingredientLibrary.indexOf({$0.ID == UUID})
    {
        return i;
    }
    return -1;
}

/* added 05.19.2016 */
func getRecipeIndexInLibraryByUUID(UUID : String, recipeLibrary : [Recipe]) -> Int
{
    if let i = recipeLibrary.indexOf({$0.ID == UUID})
    {
        return i;
    }
    return -1;
}