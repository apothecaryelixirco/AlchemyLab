//
//  IngredientLibraryIngredientEditorViewController.swift
//  AlchemyLab
//
//  Created by Randy Williams on 5/13/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Cocoa

//protocol RecipeEditorDelegate: class {
//func RecipeViewDelegate(controller: RecipeEditorViewController, recipe: Recipe, mode : String)
//}

protocol IngredientLibraryEditorDelegate : class {
    func IngredientEditorDelegate(controller: IngredientLibraryIngredientEditorViewController, ingredient : Ingredient, mode :String)
}

class IngredientLibraryIngredientEditorViewController: NSViewController {
    //    weak var delegate: AddRecipeIngredientDelegate?

    weak var delegate: RecipeEditorDelegate?
    
    @IBOutlet weak var outletCostPerML: NSTextField!
    @IBOutlet weak var outletIngredientStrength: NSTextField!
    
    @IBOutlet weak var outletNotes: NSTextField!
    @IBOutlet weak var outletName: NSTextField!
    @IBOutlet weak var outletManufacturer: NSComboBox!
    @IBOutlet weak var outletType: NSComboBox!
    @IBOutlet weak var outletBase: NSSegmentedControl!
    
    var ingredientToWorkWith : Ingredient = Ingredient();
    var mode : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBOutlet weak var outletGravityTextField: NSTextField!
    
    @IBAction func outletIngredientNameActionHandler(sender: NSTextField) {
        ingredientToWorkWith.Name = sender.stringValue;
    }
    @IBAction func outletManufacturerActionHandler(sender: NSComboBox) {
        ingredientToWorkWith.Manufacturer = sender.stringValue;
    }
    
    @IBAction func outletTypeActionHandler(sender: NSComboBox) {
        switch (sender.stringValue.uppercaseString)
        {
            case "PROPYLENE GLYCOL (PG)":
                ingredientToWorkWith.Type = "PG";
                break;
            case "VEGETABLE GLYCERIN (VG)":
                ingredientToWorkWith.Type = "VG";
                break;
            default:
            ingredientToWorkWith.Type = sender.stringValue.uppercaseString;
            break;
        }
        
        if ["PG","VG","NICOTINE","FLAVOR","ADDITIVE"].contains(sender.stringValue.uppercaseString)
        {
            
            ingredientToWorkWith.Type = sender.stringValue.uppercaseString;
        }
    }
    @IBAction func outletBaseActionHandler(sender: NSSegmentedControl) {
        ingredientToWorkWith.Base = sender.selectedSegment == 0 ? "PG" : "VG";
    }
    
    
    @IBAction func outletCostPerMLActionHandler(sender: NSTextField) {
        ingredientToWorkWith.Cost = sender.doubleValue;
    }
    @IBAction func outletGravityTextActionHandler(sender: NSTextField) {
        ingredientToWorkWith.Gravity = sender.doubleValue;
    }
    
    @IBAction func outletStrengthActionHandler(sender: NSTextField) {
        ingredientToWorkWith.Strength = sender.doubleValue;
    }
    
    func UpdateUIControls()
    {
        outletBase.selectedSegment = ingredientToWorkWith.Base.uppercaseString == "PG" ? 0 : 1;
        outletName.stringValue = ingredientToWorkWith.Name;
        outletType.stringValue = ingredientToWorkWith.Type;
        outletGravityTextField.stringValue = String(format:"%2.2f",ingredientToWorkWith.Gravity);
        outletNotes.stringValue = ingredientToWorkWith.Notes;
        outletCostPerML.stringValue = String(format: "%2.2f",ingredientToWorkWith.Cost);
        outletManufacturer.stringValue = ingredientToWorkWith.Manufacturer;
        outletIngredientStrength.stringValue = String(format: "%2.2f",ingredientToWorkWith.Strength);
    }
    
    @IBAction func outletNotesActionHandler(sender: NSTextField) {
        ingredientToWorkWith.Notes = sender.stringValue;
    }
    
    @IBAction func outletSegmentControlActionHandler(sender: NSSegmentedControl) {
        if (sender.selectedSegment == 1)
        {
            print("save ingredient.");
            ViewController.sharedInstance?.IngredientEditorDelegate(self, ingredient: ingredientToWorkWith, mode: mode);
            dismissViewController(self);

        }
        if (sender.selectedSegment == 0)
        {
            print("cancel");
            dismissViewController(self);

        }
    }
    func RefreshForEdit()
    {
        // call when editing.
        if (mode=="EDIT")
        {
            // TODO: Need to validate values I suppose..
            UpdateUIControls();
        }
    }
}
