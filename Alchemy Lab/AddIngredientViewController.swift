//
//  AddIngredientViewController.swift
//  AlchemyLab
//
//  Created by Randy Williams on 5/11/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Cocoa

protocol AddRecipeIngredientDelegate: class {
    func ingredientViewController(controller: AddIngredientViewController, ingredient: RecipeIngredient, ingredientLibrary : [Ingredient], mode : String)
}


class AddIngredientViewController: NSViewController {
    @IBOutlet var outletIngredientArrayController: NSArrayController!
    
    weak var delegate: AddRecipeIngredientDelegate?
    var incomingRecipe : Recipe = Recipe();
    var mode : String = "";
    var ingredientToEdit : RecipeIngredient = RecipeIngredient();
    
    @IBOutlet weak var IngredientPopup: NSPopUpButton!
    @IBOutlet weak var recipeIngredientNotes: NSTextField!
    @IBOutlet weak var temperatureSlider: NSSlider!
    @IBOutlet weak var temperatureLabel: NSTextField!
    @IBOutlet weak var percentageLabel: NSTextField!
    
    @IBOutlet weak var percentageInputTextOutlet: NSTextField!
    @IBOutlet var ingredientArrayController: NSArrayController!
    
    @IBAction func IngredientPopupAction(sender: NSPopUpButton) {
        let selectedIngredient = ingredientLibrary[IngredientPopup.indexOfSelectedItem];
        print(selectedIngredient.Name);
        // need to find the ingredient associated with this..
    }
    
    @IBAction func TemperatureSliderAction(sender: NSSlider) {
        temperatureLabel.stringValue = String(format:"Temperature: %d",temperatureSlider.integerValue);
    }
    @IBOutlet weak var outletNoteTextField: NSTextField!
    
    dynamic var ingredientLibrary : [Ingredient] = [Ingredient]();
    @IBOutlet weak var outletSaveCancelButton: NSSegmentedControl!
    override func viewDidLoad() {
        print("view did load....mode is " + mode);
        temperatureLabel.stringValue = String(format:"Temperature: %d",temperatureSlider.integerValue);
        super.viewDidLoad();
        print("loaded view...");
        
        // Do view setup here.
    }
    
    func RefreshForEdit()
    {
        if (mode == "EDIT")
        {
            print ("editing ingredient.  need to select the right one and setup our values.");
            recipeIngredientNotes.stringValue = ingredientToEdit.Notes;
            temperatureSlider.doubleValue = Double(ingredientToEdit.Temperature);
            percentageInputTextOutlet.doubleValue = ingredientToEdit.Percentage;
            print("ingredient we're editing: " + ingredientToEdit.RecipeIngredient.Name);
            // need to find the right ingredient in our library..
            print("Looking for ID " + ingredientToEdit.RecipeIngredient.ID);
            var indexOfIngredient : Int = 0;
            for i in ingredientLibrary
            {
               // print ("Ingredient:" + i.Name + " (" + i.ID + ")");
                if i.ID == ingredientToEdit.RecipeIngredient.ID
                {
                    indexOfIngredient = ingredientLibrary.indexOf(i)!;
                    break;
                }
            }
            print("index is " + String(indexOfIngredient));
            IngredientPopup.selectItemAtIndex(indexOfIngredient)
        }
    }
    
    @IBAction func dismissAddIngredientWindow(sender: NSButton) {
        let application = NSApplication.sharedApplication()
        application.stopModal()
    }
    
    @IBOutlet weak var tempSegmentOutlet: NSSegmentedControl!

    @IBOutlet weak var outletStatusLabel: NSTextField!
    @IBAction func saveCancelSegmentAction(sender: NSSegmentedControl) {
            if (sender.selectedSegment == 0)
            {
                print ("we should be saving here.");
                // need to check if our ingredient is a base (PG/VG/NIC) and if it is, we can't add it if it's already there.
                var targetIngredient : RecipeIngredient = RecipeIngredient();
                if (mode == "EDIT") {
                    targetIngredient = ingredientToEdit;
                }
                targetIngredient.Percentage = percentageInputTextOutlet.doubleValue;
                targetIngredient.Temperature = temperatureSlider.doubleValue;
                targetIngredient.Sequence=0; // temp
                targetIngredient.TempScale = (tempSegmentOutlet.selectedSegment == 0 ? "F" : "C");
                targetIngredient.RecipeIngredient = ingredientLibrary[IngredientPopup.indexOfSelectedItem];
                targetIngredient.Notes = recipeIngredientNotes.stringValue;
                var rejectItem : Bool = false;
                print("checking for " + targetIngredient.RecipeIngredient.Type.uppercaseString);
                for i in incomingRecipe.RecipeIngredients
                {
                    let x = i.RecipeIngredient.Name + " (" + i.RecipeIngredient.Type + ")";
                    print(x);
                }
                print ("checking for conflicting base: " + targetIngredient.RecipeIngredient.Type);
                if (mode == "ADD")
                {
                    switch (targetIngredient.RecipeIngredient.Type.uppercaseString)
                    {
                        case "NICOTINE":
                            for baseType in incomingRecipe.RecipeIngredients where baseType.RecipeIngredient.Type.uppercaseString == "NICOTINE"
                            {
                                print("found a nicotine base present in recipe.");
                                rejectItem = true;
                            }
                        case "PG":
                            for baseType in incomingRecipe.RecipeIngredients where baseType.RecipeIngredient.Type.uppercaseString == "PG"
                            {
                                rejectItem = true;
                            }

                        case "VG":
                            for baseType in incomingRecipe.RecipeIngredients where baseType.RecipeIngredient.Type.uppercaseString == "VG"
                            {
                                rejectItem = true;
                            }
                        default:
                        rejectItem=false;
                    }
                }
                if (mode == "EDIT" )
                {
                    rejectItem = false;
                }
                if (rejectItem)
                {
                    print("not adding item -- duplicate base.");
                    outletStatusLabel.stringValue = "Cannot add item.  Base already exists.";
                }
                else
                {
                    print("call our delegate!");
                    ViewController.sharedInstance?.ingredientViewController(self, ingredient: targetIngredient, ingredientLibrary: ingredientLibrary, mode: mode);
                    print("delegate has been called.");
                    self.dismissViewController(self);
                }
            }
            if (sender.selectedSegment == 1)
            {
                print("cancel chosen - bail.");
                self.dismissViewController(self);

            }
        
        //           let application = NSApplication.sharedApplication()
//            application.stopModal()

        }
}