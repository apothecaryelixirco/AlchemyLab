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
        if (i > -1)
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
        }
        //        return ingredientLibrary[i];
    }
    print ("did not find ingredient.");
    return nil;
}


func getActualIngredientByUUID(UUID : String, ingredientLibrary : [Ingredient]) -> Ingredient?
{
    // i feel like we should be returning a copy of the ingredient to avoid problems...
    // change 05.19.2016 - copy ingredient instead of returning the actual one.
    print ("looking for ingredient " + UUID)
    if let i = ingredientLibrary.indexOf({$0.ID == UUID})
    {
        if (i > -1)
        {
            return ingredientLibrary[i];
        }
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

func getRecipeIngredientIndexInLibraryByUUID(UUID : String, recipeIngredients : [RecipeIngredient]) -> Int
{
    if let i = recipeIngredients.indexOf({$0.RecipeIngredientID == UUID})
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

/* added 05.20.2016 */ /* may not be needed. */
func getRecipeByUUID(UUID : String, recipeLibrary: [Recipe]) -> Recipe?
{
    print("looking for recipe..");
    if let i = recipeLibrary.indexOf({$0.ID == UUID})
    {
        return recipeLibrary[i];
    }
    return nil;
}