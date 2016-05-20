//
//  DataTypes.swift
//  Alchemy Lab
//
//  Created by Randy Williams on 5/11/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Foundation
import Cocoa


class Ingredient : NSObject
{
    var ID = NSUUID().UUIDString; // generate an ID for this ingredient.
    var Name : String = "";
    var Manufacturer : String = "";
    var Type : String = "";
    var Base : String = "";
    var Gravity : Double = 0.00;
    var Cost : Double = 0.00;
    var Strength : Double = 0.00;
    var Notes : String = "";
    var VGRatioForIngredient : Double = 0.00;
    var PGRatioForIngredient : Double = 0.00;
    
    init(name : String, manufacturer : String, type: String, base : String, gravity : Double, cost : Double, strength : Double, notes : String, vgratioforingredient : Double, pgratioforingredient : Double)
    {
        self.Name = name;
        self.Manufacturer = manufacturer;
        self.Type = type;
        self.Base = base;
        self.Gravity = gravity;
        self.Cost = cost;
        self.Strength = strength;
        self.VGRatioForIngredient = vgratioforingredient;
        self.PGRatioForIngredient = pgratioforingredient;
        self.Notes = notes;
        super.init();
    }
    override init()
    {
        super.init();
    }
}

class mixLabDisplay : NSObject
{
    var ID = NSUUID().UUIDString;
    var Ingredient : String = "";
    var Volume : String = "";
    var Weight : String = "";
    var Cost : String = "";
    var Percentage : String = "";
    var backgroundPercentage : Double = 0.00;
    var backgroundCost : Double = 0.00;
    var backgroundVolume : Double = 0.00;
    var backgroundWeight : Double = 0.00;
    
    
    override init()
    {
        super.init();
    }
}

class RecipeIngredient : NSObject
{
    var RecipeIngredientID : String = "";
    var Percentage : Double = 0.00;
    var Temperature : Double = 0.00;
    var TempScale : String = "";
    var Sequence : Int = 0;
    var Notes : String = "";
    //TODO: Add init for loading in from object.... (thinking of load/save functionality)
    override init()
    {
        super.init();
    }
}



class RecipeDisplay : NSObject {
    var ID = NSUUID().UUIDString;
    var Ingredient : String = "";
    var Type : String = "";
    var Base : String = "";
    var Percentage : String = "";
    var Strength : String = "";
    var Sequence : Int = 0;
    var backgroundStrength : Double = 0.00;
    var backgroundPercentage : Double = 0.00;
    var backgroundIngredient : RecipeIngredient = RecipeIngredient();
    override init()
    {
        super.init();
    }
}

class Recipe : NSObject
{
    var ID = NSUUID().UUIDString;
    var RecipeName : String = "";
    var RecipeAuthor : String = "";
    var RecipeDate : NSDate = NSDate();
    var RecipeDescription : String = "";
    var RecipeCategory : String = "Default";
    var RecipeIngredients = [RecipeIngredient]();
    var Notes : String = "";
    var PGRatio : Int = 0;
    var VGRatio : Int = 0;
    var maxVG : Bool = false;
    
    //TODO: Add init for loading in with object.... (thinking of load/save functionality)
    override init()
    {
        super.init();
    }
}

class RecipeSourceListHeader : NSObject
{
    var Name : String = "";
    var Icon : NSImage? = NSImage();
    var RecipeCategories : [RecipeSourceListCategory] = [];
}

class RecipeSourceListCategory : NSObject
{
    var CategoryName : String = "";
    var Icon : NSImage? = NSImage();
    var Recipes : [RecipeSourceListRecipe] = [RecipeSourceListRecipe]();
}

class RecipeSourceListRecipe : NSObject
{
    var Name : String = "";
    var RecipeID : String = "";
    var Icon : NSImage? = NSImage();
}


