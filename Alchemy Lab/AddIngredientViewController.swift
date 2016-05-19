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
    
    @IBOutlet weak var outletIngredientName: NSPopUpButton!
    @IBOutlet weak var IngredientPopup: NSPopUpButton!
    @IBOutlet weak var recipeIngredientNotes: NSTextField!
   // @IBOutlet weak var temperatureSlider: NSSlider!
    @IBOutlet weak var temperatureLabel: NSTextField!
    @IBOutlet weak var percentageLabel: NSTextField!
    
    @IBOutlet weak var percentageInputTextOutlet: NSTextField!
    @IBOutlet var ingredientArrayController: NSArrayController!
    
    @IBOutlet weak var outletSequenceValue: NSTextField!
    
    @IBAction func IngredientPopupAction(sender: NSPopUpButton) {
        let selectedIngredient = ingredientLibrary[IngredientPopup.indexOfSelectedItem];
        print(selectedIngredient.Name);
        // need to find the ingredient associated with this..
    }
    
   // @IBAction func TemperatureSliderAction(sender: NSSlider) {
   //     temperatureLabel.stringValue = String(format:"Temperature: %d",temperatureSlider.integerValue);
   // }
    @IBOutlet weak var outletNoteTextField: NSTextField!
    
    @IBOutlet weak var outletTemperatureTextField: NSTextField!
    dynamic var ingredientLibrary : [Ingredient] = [Ingredient]();
    @IBOutlet weak var outletSaveCancelButton: NSSegmentedControl!
    override func viewDidLoad() {
        print("view did load....mode is " + mode);
     //   temperatureLabel.stringValue = String(format:"Temperature: %d",temperatureSlider.integerValue);
        super.viewDidLoad();
        print("loaded view...");
        
        // Do view setup here.
    }
    
    func RefreshForEdit()
    {
        if (mode == "EDIT")
        {
            print ("editing ingredient.  need to select the right one and setup our values.");
            outletIngredientName.enabled = false;
            recipeIngredientNotes.stringValue = ingredientToEdit.Notes;
            outletTemperatureTextField.doubleValue = ingredientToEdit.Temperature;
            if (ingredientToEdit.TempScale == "C")
            {
                tempSegmentOutlet.selectedSegment = 1;
            }
            if (ingredientToEdit.TempScale == "F")
            {
                tempSegmentOutlet.selectedSegment = 0;
            }
            //temperatureSlider.doubleValue = Double(ingredientToEdit.Temperature);
            percentageInputTextOutlet.doubleValue = ingredientToEdit.Percentage;
            let recipeIngredient = getIngredientByUUID(ingredientToEdit.RecipeIngredientID, ingredientLibrary: ingredientLibrary)
            print("ingredient we're editing: " + recipeIngredient!.Name);
            // need to find the right ingredient in our library..
            print("Looking for ID " + recipeIngredient!.ID);
            let indexOfIngredient = getIngredientIndexInLibraryByUUID((recipeIngredient?.ID)!,ingredientLibrary: ingredientLibrary);
            print("index is " + String(indexOfIngredient));
            if (indexOfIngredient != -1)
            {
                IngredientPopup.selectItemAtIndex(indexOfIngredient)
            }
            outletSequenceValue.integerValue = ingredientToEdit.Sequence;
        }
    }
    
    @IBAction func dismissAddIngredientWindow(sender: NSButton) {
        let application = NSApplication.sharedApplication()
        application.stopModal()
    }
    
    @IBOutlet weak var tempSegmentOutlet: NSSegmentedControl!

    @IBOutlet weak var outletStatusLabel: NSTextField!
    @IBAction func saveCancelSegmentAction(sender: NSSegmentedControl) {
        print ("attempting to save ingredient!");
            if (sender.selectedSegment == 1)
            {
                print ("we should be saving here.");
                // need to check if our ingredient is a base (PG/VG/NIC) and if it is, we can't add it if it's already there.
                var targetIngredient : RecipeIngredient = RecipeIngredient();
                if (mode == "EDIT") {
                    targetIngredient = ingredientToEdit;
                }
                targetIngredient.Percentage = percentageInputTextOutlet.doubleValue;
                targetIngredient.Temperature = Double(outletTemperatureTextField.doubleValue);
                //targetIngredient.Temperature = temperatureSlider.doubleValue;
                targetIngredient.Sequence=0; // temp
                targetIngredient.TempScale = (tempSegmentOutlet.selectedSegment == 0 ? "F" : "C");
                let ingredientFromLibrary = getIngredientByUUID(ingredientLibrary[IngredientPopup.indexOfSelectedItem].ID, ingredientLibrary: ingredientLibrary);
                
                targetIngredient.RecipeIngredientID = (ingredientFromLibrary?.ID)!;
                targetIngredient.Notes = recipeIngredientNotes.stringValue;
                targetIngredient.Sequence = outletSequenceValue.integerValue;
                var rejectItem : Bool = false;
                print("checking for " + ingredientFromLibrary!.Type.uppercaseString);
                print ("checking for conflicting base: " + (ingredientFromLibrary?.Type)!);
                if (mode == "ADD")
                {
                    switch (ingredientFromLibrary!.Type.uppercaseString)
                    {
                        case "NICOTINE":
                            for ing in incomingRecipe.RecipeIngredients
                            {
                                let ingredientToCheck = getIngredientByUUID(ing.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
                                if ingredientToCheck?.Type.uppercaseString == "NICOTINE"
                                {
                                    print("found a nicotine base present in recipe.");
                                    rejectItem = true;
                                }
                            }
                        case "PG":
                            for ing in incomingRecipe.RecipeIngredients
                            {
                                let ingredientToCheck = getIngredientByUUID(ing.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
                                if ingredientToCheck?.Type.uppercaseString == "PG"
                                {
                                    print("found a nicotine base present in recipe.");
                                    rejectItem = true;
                                }
                        }

                        case "VG":
                            for ing in incomingRecipe.RecipeIngredients
                            {
                                let ingredientToCheck = getIngredientByUUID(ing.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
                                if ingredientToCheck?.Type.uppercaseString == "VG"
                                {
                                    print("found a nicotine base present in recipe.");
                                    rejectItem = true;
                                }
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
                    print("should be saving ingredient using ingredient library id " + targetIngredient.RecipeIngredientID);
                    ViewController.sharedInstance?.ingredientViewController(self, ingredient: targetIngredient, ingredientLibrary: ingredientLibrary, mode: mode);
                    print("delegate has been called.");
                    self.dismissViewController(self);
                }
            }
            if (sender.selectedSegment == 0)
            {
                print("cancel chosen - bail.");
                self.dismissViewController(self);

            }
        
        //           let application = NSApplication.sharedApplication()
//            application.stopModal()

        }
}