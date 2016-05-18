//
//  RecipeEditorViewController.swift
//  AlchemyLab
//
//  Created by Randy Williams on 5/12/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Cocoa


protocol RecipeEditorDelegate: class {
    func RecipeViewDelegate(controller: RecipeEditorViewController, recipe: Recipe, mode : String)
}



class RecipeEditorViewController: NSViewController {

    weak var delegate: RecipeEditorDelegate?

    var mode : String = "";
  //  var PGRatio : Int = 0;
//    var VGRatio : Int = 0;
    // outlets
    
    var workingRecipe : Recipe = Recipe();
//    var EditingRecipe : Recipe = Recipe();
    @IBOutlet weak var outletRecipeName: NSTextField!
    
    @IBOutlet weak var outletMaxVG: NSButton!
    @IBOutlet weak var outletDatePicker: NSDatePicker!
    @IBOutlet weak var outletAuthor: NSTextField!
    
    @IBOutlet weak var outletDescription: NSTextField!
    
    @IBOutlet weak var outletVGRatio: NSTextField!
    
    @IBOutlet weak var outletRecipeNotes: NSTextField!
    @IBOutlet weak var outletPGRatio: NSTextField!
    
    @IBOutlet weak var outletRecipeCategory: NSComboBox!
    
    
    @IBAction func outletMaxVGHandler(sender: NSButton) {
        if (sender.state == 0)
        {
            outletVGRatio.enabled = true;
            outletPGRatio.enabled = true;
            outletVGRatio.editable = true;
            outletPGRatio.editable = true;
            workingRecipe.maxVG = false;
            print("unchecked.");
        }
        if (sender.state == 1)
        {
            outletVGRatio.enabled = false;
            outletVGRatio.enabled = false;
            outletPGRatio.editable = false;
            outletVGRatio.editable = false;
            workingRecipe.maxVG = true;
            print("checked.");
        }
    }
    

    @IBAction func outletPGRatioHandler(sender: NSTextField) {
        workingRecipe.PGRatio = sender.integerValue;
        workingRecipe.VGRatio = 100-workingRecipe.PGRatio;
        UpdateUIWithRecipeValues();
    }
    
    
    @IBAction func outletVGRatioHandler(sender: NSTextField) {
        workingRecipe.VGRatio = sender.integerValue;
        workingRecipe.PGRatio = 100-workingRecipe.VGRatio;
        UpdateUIWithRecipeValues();

    }
    
    @IBAction func outletSaveSegmentHandler(sender: NSSegmentedControl) {
        print("handler!");
        if (sender.selectedSegment == 1)
        {
            // validate control values
            var validatedRecipe : Bool = true;
            var validateReason : String = "";
            if (workingRecipe.RecipeName.characters.count==0)
            {
                print("name error.");
                validatedRecipe = false;
                validateReason = "Recipe must have a name.";
            }
            // required fields are Name and Ratio..
            if ((workingRecipe.PGRatio + workingRecipe.VGRatio != 100) && !workingRecipe.maxVG)
            {
                print("Ratio error.");
                validateReason = "VG/PG must equal 100 or Max VG Option must be selected.";
                validatedRecipe = false;
            }
            if (!validatedRecipe)
            {
                outletErrorText.stringValue = validateReason;
            } else {
                print("save");
                ViewController.sharedInstance?.RecipeViewDelegate(self, recipe: workingRecipe, mode: mode)
                dismissViewController(self);
            }
        }
        if (sender.selectedSegment == 0)
        {
            dismissViewController(self);
            print("cancel");
        }
    }
    @IBOutlet weak var outletErrorText: NSTextField!
    
    @IBAction func outletRecipeDescriptionHandler(sender: NSTextField) {
        workingRecipe.RecipeDescription = sender.stringValue;
        UpdateUIWithRecipeValues();
    }
    
    @IBAction func outletRecipeDateHandler(sender: NSDatePicker) {
        workingRecipe.RecipeDate = sender.dateValue;
        UpdateUIWithRecipeValues();
    }
    
    @IBAction func outletAuthorHandler(sender: NSTextField) {
        workingRecipe.RecipeAuthor = sender.stringValue;
        UpdateUIWithRecipeValues();
    }
    
    @IBAction func outletNameHandler(sender: NSTextField) {
        workingRecipe.RecipeName = sender.stringValue;
        UpdateUIWithRecipeValues();
    }
    
    
    @IBAction func outletRecipeNotesHandler(sender: NSTextField) {
        workingRecipe.Notes = sender.stringValue;
        UpdateUIWithRecipeValues();
    }
    
    @IBAction func outletRecipeCategoryHandler(sender: NSComboBox) {
        workingRecipe.RecipeCategory = sender.stringValue;
        UpdateUIWithRecipeValues();
    }
    
    // end outlets
    
    
    func UpdateUIWithRecipeValues()
    {
        outletPGRatio.integerValue = workingRecipe.PGRatio;
        outletVGRatio.integerValue = workingRecipe.VGRatio;
        outletDescription.stringValue = workingRecipe.RecipeDescription;
        outletDatePicker.dateValue = workingRecipe.RecipeDate;
        outletAuthor.stringValue = workingRecipe.RecipeAuthor;
        outletRecipeName.stringValue = workingRecipe.RecipeName;
        outletRecipeNotes.stringValue = workingRecipe.Notes;
        outletMaxVG.state = workingRecipe.maxVG ? 1 : 0;
        outletRecipeCategory.stringValue = workingRecipe.RecipeCategory;
    }
    
    func RefreshUIForEdit()
    {
        UpdateUIWithRecipeValues();
    }

    override func viewDidLoad() {
        outletDatePicker.dateValue = NSDate();
        if (mode == "EDIT")
        {
            UpdateUIWithRecipeValues();
        }
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
