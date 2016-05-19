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
    print ("looking for ingredient " + UUID)
    if let i = ingredientLibrary.indexOf({$0.ID == UUID})
    {
        print ("found ingredient.");
        return ingredientLibrary[i];
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