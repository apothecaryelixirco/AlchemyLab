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
    func IngredientEditorDelegate(controller: IngredientLibraryIngredientEditorViewController, ingredient : Ingredient, mode : String, action : String)
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
    
    @IBOutlet weak var outletVGRatioComboBox: NSComboBox!
    
    @IBOutlet weak var outletPGRatioComboBox: NSComboBox!
    
    var targetIngredientLibrary : [Ingredient] = [];
    
    var ingredientToWorkWith : Ingredient = Ingredient();
    var mode : String = "";
    
    override func viewDidLoad() {
        outletPGRatioComboBox.enabled = false;
        outletVGRatioComboBox.enabled = false;
        
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBOutlet weak var outletGravityTextField: NSTextField!
    
    
    @IBAction func outletVGRatioComboBoxActionHandler(sender: NSComboBox) {
        ingredientToWorkWith.VGRatioForIngredient = sender.doubleValue;
        ingredientToWorkWith.PGRatioForIngredient = 100-sender.doubleValue;
        outletPGRatioComboBox.integerValue = Int(ingredientToWorkWith.PGRatioForIngredient);
    }
    
    @IBAction func outletPGRatioComboBoxActionHandler(sender: NSComboBox) {
        ingredientToWorkWith.PGRatioForIngredient = sender.doubleValue;
        ingredientToWorkWith.VGRatioForIngredient = 100-sender.doubleValue;
        outletVGRatioComboBox.integerValue = Int(ingredientToWorkWith.VGRatioForIngredient);

    }
    
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
            if (sender.stringValue.uppercaseString == "NICOTINE" || sender.stringValue.uppercaseString == "FLAVOR")
            {
                outletPGRatioComboBox.enabled = true;
                outletVGRatioComboBox.enabled = true;
            } else
            {
                outletPGRatioComboBox.enabled = false;
                outletVGRatioComboBox.enabled = false;
            }
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
        outletGravityTextField.doubleValue = ingredientToWorkWith.Gravity;
        outletNotes.stringValue = ingredientToWorkWith.Notes;
        outletCostPerML.doubleValue = ingredientToWorkWith.Cost;
        outletManufacturer.stringValue = ingredientToWorkWith.Manufacturer;
        outletIngredientStrength.doubleValue = ingredientToWorkWith.Strength;
        outletPGRatioComboBox.doubleValue = ingredientToWorkWith.PGRatioForIngredient;
        outletVGRatioComboBox.doubleValue = ingredientToWorkWith.VGRatioForIngredient;
        if (outletType.stringValue.uppercaseString == "NICOTINE" || outletType.stringValue.uppercaseString == "FLAVOR")
        {
            outletPGRatioComboBox.enabled = true;
            outletVGRatioComboBox.enabled = true;
        }
        else
        {
            outletPGRatioComboBox.enabled=false;
            outletVGRatioComboBox.enabled=false;
        }
    }
    
    @IBAction func outletNotesActionHandler(sender: NSTextField) {
        ingredientToWorkWith.Notes = sender.stringValue;
    }
    
    @IBAction func outletSegmentControlActionHandler(sender: NSSegmentedControl) {
        if (sender.selectedSegment == 1)
        {
            if ((ingredientToWorkWith.Type.uppercaseString == "NICOTINE" && ingredientToWorkWith.Strength > 0.00) || ["FLAVOR","PG","VG","ADDITIVE"].contains(ingredientToWorkWith.Type.uppercaseString))
            {
            print("save ingredient.");
            print("name is going to be: " + ingredientToWorkWith.Name);
            ViewController.sharedInstance?.IngredientEditorDelegate(self, ingredient: ingredientToWorkWith, mode: mode, action: "SAVE");
            dismissViewController(self);
            } else {
                print("strength needs to be > 0");
                let alert = NSAlert();
                alert.alertStyle = NSAlertStyle.CriticalAlertStyle;
                alert.messageText = "Input issue.";
                alert.informativeText = "For nicotine type ingredients, strength must be > 0";
                alert.runModal();
            }

        }
        if (sender.selectedSegment == 0)
        {
            print("cancel");
            dismissViewController(self);

        }
    }
    
    
    func DetermineAndPopulateIngredientCategories()
    {
        var manufacturers : [String] = [];
        for ing in targetIngredientLibrary {
            if (!manufacturers.contains(ing.Manufacturer.capitalizedString))
            {
                manufacturers.append(ing.Manufacturer.capitalizedString);
            }
        }
        outletManufacturer.addItemsWithObjectValues(manufacturers);
    }
    
    func RefreshForAdd()
    {
        DetermineAndPopulateIngredientCategories();
    }
    func RefreshForEdit()
    {
        // call when editing.
        if (mode=="EDIT")
        {
            DetermineAndPopulateIngredientCategories();
            // TODO: Need to validate values I suppose..
            UpdateUIControls();
        }
    }
}
