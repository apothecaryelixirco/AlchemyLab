//
//  DataLoader.swift
//  Alchemy Lab
//
//  Created by Randy Williams on 5/11/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Foundation
/*
func LoadPlaceHolderIngredients() -> [Ingredient]
{
    var ingredients = [Ingredient]();
    
    let nic = Ingredient(name: "CTX PG Nicotine Base", manufacturer: "Carolina Extracts", type: "Nicotine", base: "PG", gravity: 1.01, cost: 0.37, strength: 100, notes: "");
    let nic2 = Ingredient(name: "CTX VG Nicotine Base", manufacturer: "Carolina Extracts",type: "Nicotine", base: "VG",
                          gravity: 1.01, cost: 0.37, strength: 100, notes: "");
    let vg = Ingredient(name: "ED Vegetable Glycerin", manufacturer: "Essential Depot (Amazon)", type: "VG", base: "VG", gravity: 1.26, cost: 0.04, strength: -1, notes: "");
    let pg = Ingredient(name: "ED Propylene Glycol", manufacturer: "Essential Depot (Amazon)", type: "PG", base: "PG", gravity: 1.038, cost: 0.04, strength: -1, notes: "");
    let flavor1 = Ingredient(name: "LA Banana Cream", manufacturer: "Lor Ann", type: "Flavor", base: "PG", gravity: 1.017, cost: 0.12, strength: -1, notes: "");
    let flavor2 = Ingredient(name: "TFA Dragon Fruit", manufacturer: "The Flavors Apprentice", type: "Flavor", base: "PG", gravity: 1.0240, cost: 0.04, strength: -1, notes: "");
    let flavor3 = Ingredient(name: "TFA Strawberry", manufacturer: "The Flavors Apprentice", type: "Flavor", base: "PG", gravity: 1.0410, cost: 0.04, strength: -1, notes: "");
    ingredients.append(nic);
    ingredients.append(nic2);
    ingredients.append(vg);
    ingredients.append(pg);
    ingredients.append(flavor1);
    ingredients.append(flavor2);
    ingredients.append(flavor3);
    return ingredients;
}
 */

func LoadDefaultRecipe(ingredientLibrary : [Ingredient]) -> [Recipe]
{
    var recipes = [Recipe]();
    var ingredients = ingredientLibrary;
    ingredients.removeAtIndex(1);
    ingredients.removeAtIndex(4);
    let nanaberry : Recipe = Recipe();
    nanaberry.RecipeAuthor = "Randy Williams";
    nanaberry.RecipeCategory = "Fruits";
    nanaberry.RecipeDate = NSDate();
    nanaberry.RecipeName = "NanaBerry";
    recipes.append(nanaberry);
    
    let r2 = Recipe();
    r2.RecipeName = "Seven Seas";
    r2.RecipeCategory = "Menthol";
    let r3 = Recipe();
    r3.RecipeName = "Haley Menthol";
    r3.RecipeCategory = "Menthol";
    let r4 = Recipe();
    r4.RecipeName = "Strawberry Milk";
    r4.RecipeCategory = "Custards";
    recipes.append(r2);
    recipes.append(r3);
    recipes.append(r4);
    return recipes;
}
/*
func LoadIngredientLibraryFromXML()
{
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
}*/
