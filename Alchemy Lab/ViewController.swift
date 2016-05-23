//
//  ViewController.swift
//  Alchemy Lab
//
//  Created by Randy Williams on 5/11/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, AddRecipeIngredientDelegate, RecipeEditorDelegate, IngredientLibraryEditorDelegate, NSXMLParserDelegate, NSWindowDelegate  {

    
    var PGRatio : Int = 0;
    var VGRatio : Int = 0;
    var maxVG : Bool = false;
    var desiredNicStrength : Double = 0;
    var amountOfJuice : Int = 0;
    static var sharedInstance : ViewController?;
    // outlets
    
//    @IBOutlet weak var outletRecipeList: NSOutlineView!
    @IBOutlet weak var outletIngredientList: NSOutlineView!
    
    @IBOutlet var outletRecipe: NSArrayController!
    
    @IBOutlet var outletMixLab: NSArrayController!
    
    @IBOutlet weak var outletAmountComboBox: NSComboBox!
    @IBOutlet weak var outletAmountLabel: NSTextField!
    @IBOutlet weak var outletNicotineStrengthLabel: NSTextField!
    @IBOutlet weak var outletPGRatioLabel: NSTextField!
   // @IBOutlet weak var outletNicStrengthSlider: NSSlider!
    
  //  @IBOutlet weak var outletVGRatioSlider: NSSlider!
  //  @IBOutlet weak var outletPGRatioSlider: NSSlider!
    @IBOutlet weak var outletVGRatioLabel: NSTextField!
    
    @IBOutlet weak var outletRecipeTableView: NSTableView!
    @IBOutlet weak var outletRecipeIngredientSegment: NSSegmentedControl!
    
    
    @IBOutlet weak var outletVGRatioTextField: NSTextField!
    @IBOutlet weak var outletPGRatioTextField: NSTextField!
    @IBOutlet weak var outletNicStrengthTextField: NSTextField!
    
    @IBOutlet weak var outletLabelRecipeName: NSTextField!

    @IBAction func outletRefreshButtonAction(sender: NSButton) {
        UpdateRecipeView();
        outletRecipeTableView.reloadData();
        UpdateMixLabView();
        outletMixLabView.reloadData();
    }
    @IBOutlet weak var outletMixLabView: NSTableView!
    
    var ingredientToEdit : RecipeIngredient = RecipeIngredient();

    func IngredientEditorDelegate(controller: IngredientLibraryIngredientEditorViewController, ingredient: Ingredient, mode: String, action: String) {
        if (mode == "ADD")
        {
            ingredientLibrary.append(ingredient);
            print ("add ingredient to library.");
            ingredientLibrary.sortInPlace({$0.Name < $1.Name});
            outletIngredientLibraryTableView.reloadData();

        }
        if (mode == "EDIT")
        {
            let ingIndex = getIngredientIndexInLibraryByUUID(ingredient.ID, ingredientLibrary: ingredientLibrary);
            if (ingIndex > -1)
            {
                ingredientLibrary[ingIndex] = ingredient;
            }
            //[self.managedObjectContext reset];
            //[myArrayController fetch:self];

            UpdateRecipeView();
            UpdateMixLabView();
            outletMixLab.rearrangeObjects();
            outletRecipe.rearrangeObjects();

            outletRecipeTableView.reloadData();
            outletMixLabView.reloadData();
            ingredientLibrary.sortInPlace({$0.Name < $1.Name});
            outletIngredientLibraryTableView.reloadData();
            UpdateLabelsWithRecipeInformation();
            //TODO: Ingredient library isn't sorting properly after adding an ingredient.

        }
    }
    
    func getOutlineViewIndexByRecipeID(RecipeID : String) -> Int
    {
        for index in 0...outletRecipeCategoryOutlineView.numberOfRows
        {
            let object:AnyObject? = outletRecipeCategoryOutlineView.itemAtRow(index);
            if (object is RecipeSourceListRecipe)
            {
                let recipeToCheck = object as! RecipeSourceListRecipe;
                if (recipeToCheck.RecipeID == RecipeID)
                {
                    return(index);
                }
            }
        }
        return -1;
    }
    
    func RecipeViewDelegate(controller: RecipeEditorViewController, recipe: Recipe, mode: String) {
        if (mode == "ADD")
        {
            // we have received a recipe, now we need to add it to our view.
            recipeLibrary.append(recipe);
        }
        LoadRecipesIntoSourceListContainer();
        outletRecipeCategoryOutlineView.reloadData();
        outletRecipeCategoryOutlineView.expandItem(nil, expandChildren: true);


        if (mode == "EDIT")
        {
            LoadRecipesIntoSourceListContainer();
            outletRecipeCategoryOutlineView.reloadData();
            outletRecipeCategoryOutlineView.expandItem(nil, expandChildren: true);

            //dialogAlertUser("coming out of edit.");
            let indexInOutlineView = getOutlineViewIndexByRecipeID(recipe.ID);
            if (indexInOutlineView > -1)
            {
                print("we found an index!");
                let indexSet = NSIndexSet(index: indexInOutlineView);
                outletRecipeCategoryOutlineView.selectRowIndexes(indexSet, byExtendingSelection: false);
            }
            // we've edited a recipe, need to reload it which means we need to select it?
            // need to get the index of the recipe we're working with..
        }
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateMixLabView();
        UpdateRecipeView();
        print("received recipe from recipe view controller.");
    }
    
    @IBAction func outletRecipeTableViewRowSelectedHandler(sender: NSTableView) {
//        let ingredient = getIngredientByUUID(recipeDisplay[sender.selectedRow]?.ID, ingredientLibrary: <#T##[Ingredient]#>)
        print("a recipe row has been selected!");
     //   ingredientToEdit = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
    //    showEditPopOverFromTableRow(sender);
        
    }
    
    
    @IBAction func outletRecipeListDoubleClickRecipeAction(sender: NSOutlineView) {
        ShowRecipeEditorPopOverForRowDoubleClick(sender);
        print("recipe double clicked, edit this bitch.");
    }
    
    func ingredientViewController(controller: AddIngredientViewController, ingredient: RecipeIngredient, ingredientLibrary: [Ingredient], mode: String) {
        if (mode == "EDIT")
        {
            let indexToEdit = currentRecipe.RecipeIngredients.indexOf(ingredient);
            print ("found ingredient at index " + String(indexToEdit));
            currentRecipe.RecipeIngredients[indexToEdit!] = ingredient;
        }
        if (mode == "ADD")
        {
            currentRecipe.RecipeIngredients.append(ingredient);
        }
        UpdateRecipeView();
        UpdateMixLabView();
        print("received an ingredient from the add remove ingredient control");
    }
    
    
    @IBAction func showAddIngredient(sender: AnyObject) {
        
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {

            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.incomingRecipe = currentRecipe;
            addIngredientViewController.mode = "ADD";
            
            //presentViewControllerAsSheet(addIngredientViewController);
            //let application = NSApplication.sharedApplication()
            //application.runModalForWindow(addIngredientWindow)
        }
    }

    @IBAction func outletRecipeRowDoubleClickIngredient(sender: NSTableView) {
        print("row has been double clicked!");
        showRecipeIngredientEditPopOverFromTableRow(sender);
    }
    
    /* Deprecated
    @IBAction func showEditIngredient(sender: AnyObject) {
        
        // 1
        print ("calling show Add Ingredient as popover");

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.mode = "EDIT";
            addIngredientViewController.incomingRecipe = currentRecipe;
            addIngredientViewController.ingredientToEdit = ingredientToEdit;
            
            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            addIngredientViewController.RefreshForEdit();
            // 3
            //let application = NSApplication.sharedApplication()
            //application.runModalForWindow(addIngredientWindow)
        }
    }
 */
    @IBOutlet weak var outletMixLabScrollView: NSScrollView!

    /*
 
 @IBAction func outletRecipeIngredientAddRemoveSegment(sender: NSSegmentedControl) {
 if (sender.selectedSegment == 0)
 {
 print("add button selected!");
 //showAddIngredient(self);
 showAddPopOver(sender);
 }
 if (sender.selectedSegment == 1)
 {
 // we should now delete the selected item from the recipe...
 RemoveSelectedRecipeIngredient();
 print("Delete button selected!");
 }
 if (sender.selectedSegment == 2)
 {
 if (outletRecipeTableView.selectedRow == -1)
 {
 return;
 }
 print("edit button selected");
 // let's find which ingredient we're working with...
 ingredientToEdit = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
 //showEditIngredient(self);
 //            showRecipeIngredientEditPopOver(sender);
 }
 }
*/
 
    @IBAction func outletMixLabSegmentActionhandler(sender: NSSegmentedControl) {
        
        switch (sender.selectedSegment)
        {
        case 0:
            print("add ingredient to recipe.");
            showAddPopOver(sender);
        case 1:
            print("remove ingredient from recipe.");
            RemoveSelectedMixLabRecipeIngredient();
        case 2:
            if (outletMixLabView.selectedRow > -1)
            {
  //              UpdateRecipeView();
//                UpdateMixLabView();
                print("editing row " + outletMixLabView.selectedRow.description);
                if (mixLab[outletMixLabView.selectedRow].RecipeIngredientID != "")
                {
                    showRecipeIngredientEditPopOverFromRecipeIngredientID(mixLab[outletMixLabView.selectedRow].RecipeIngredientID);
                }
            }
            print("modify ingredient in recipe.");
        case 3:
            UpdateRecipeView();
            outletRecipeTableView.reloadData();
            UpdateMixLabView();
            outletMixLabView.reloadData();
            print("refresh view.");
        case 4:
            print("print recipe.");
            let pInfo = NSPrintInfo();
            pInfo.orientation = NSPaperOrientation.Landscape;
            let pOperation = NSPrintOperation(view: self.outletMixLabScrollView, printInfo: pInfo);
            pOperation.runOperation();
        default:
            print("no action selected.");
        }
    }
    
    @IBAction func showIngredientLibraryEditorPopupAsAdd(sender: NSSegmentedControl)
    {
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let ingredientLibraryWindowController = storyboard.instantiateControllerWithIdentifier("Ingredient Library Editor View Controller") as! NSWindowController
        
        if let ingredientLibraryWindow = ingredientLibraryWindowController.window {
            
            print("calling display as popover for ingredient library editor.");
            let ingredientLibraryEditorViewController = ingredientLibraryWindow.contentViewController as! IngredientLibraryIngredientEditorViewController
            ingredientLibraryEditorViewController.mode = "ADD";
            let rectForPopup = outletIngredientLibraryTableView.bounds;
            let viewForPopup = outletIngredientLibraryTableView;
            presentViewController(ingredientLibraryEditorViewController, asPopoverRelativeToRect: rectForPopup, ofView: viewForPopup, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
            //            outletRecipeTableView.selectedCell()?.draw
            //            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            ingredientLibraryEditorViewController.RefreshForEdit();
        }
    }
    
    /*
    @IBAction func showIngredientLibraryEditorPopupAsEditFromTableRow(sender: NSTableView)
    {
        // 1
        print("displaying ingredient library editor as edit.");
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let ingredientLibraryWindowController = storyboard.instantiateControllerWithIdentifier("Ingredient Library Editor View Controller") as! NSWindowController
        
        if let ingredientLibraryWindow = ingredientLibraryWindowController.window {
            
            print("calling display as popover for ingredient library editor.");
            let ingredientLibraryEditorViewController = ingredientLibraryWindow.contentViewController as! IngredientLibraryIngredientEditorViewController
            ingredientLibraryEditorViewController.mode = "EDIT";
            ingredientLibraryEditorViewController.ingredientToWorkWith = ingredientLibrary[sender.selectedRow];
            let rectForPopup = sender.bounds;
            let viewForPopup = sender;
            presentViewController(ingredientLibraryEditorViewController, asPopoverRelativeToRect: rectForPopup, ofView: viewForPopup, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
            //            outletRecipeTableView.selectedCell()?.draw
            //            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            ingredientLibraryEditorViewController.RefreshForEdit();
        }
    }
*/
    func showIngredientLibraryEditorPopOverAsAddFromIngredientID(ID: String)
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let ingredientLibraryWindowController = storyboard.instantiateControllerWithIdentifier("Ingredient Library Editor View Controller") as! NSWindowController
        
        if let ingredientLibraryWindow = ingredientLibraryWindowController.window
        {
            print("calling display as popover for ingredient library editor by Ingredient ID");
            let ingredientLibraryEditorViewController = ingredientLibraryWindow.contentViewController as! IngredientLibraryIngredientEditorViewController
            ingredientLibraryEditorViewController.mode = "EDIT";
            if (outletIngredientLibraryTableView.selectedRow > -1)
            {
                //let indexOfIngredientToWorkWith = getIngredientIndexInLibraryByUUID(ID, ingredientLibrary: ingredientLibrary);
                let ingredientToWorkWith = getIngredientByUUID(ID, ingredientLibrary: ingredientLibrary)
                if (ingredientToWorkWith != nil)
                {
                    
                    ingredientLibraryEditorViewController.ingredientToWorkWith = getIngredientByUUID(ID, ingredientLibrary: ingredientLibrary)!;
                    presentViewController(ingredientLibraryEditorViewController, asPopoverRelativeToRect: outletIngredientLibraryTableView.bounds, ofView: outletIngredientLibraryTableView, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
                    ingredientLibraryEditorViewController.RefreshForEdit();
                }
                
            }
        }
    }
        
    
    func showIngredientLibraryEditorPopupFromIngredientID(ID: String)
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let ingredientLibraryWindowController = storyboard.instantiateControllerWithIdentifier("Ingredient Library Editor View Controller") as! NSWindowController
        
        if let ingredientLibraryWindow = ingredientLibraryWindowController.window
        {
            print("calling display as popover for ingredient library editor by Ingredient ID");
            let ingredientLibraryEditorViewController = ingredientLibraryWindow.contentViewController as! IngredientLibraryIngredientEditorViewController
            ingredientLibraryEditorViewController.mode = "EDIT";
            if (outletIngredientLibraryTableView.selectedRow > -1)
            {
                let indexOfIngredientToWorkWith = getIngredientIndexInLibraryByUUID(ID, ingredientLibrary: ingredientLibrary);
                if (indexOfIngredientToWorkWith > -1)
                {
                    
                    //ingredientLibraryEditorViewController.ingredientToWorkWith = ingredientLibrary[indexOfIngredientToWorkWith];
                    ingredientLibraryEditorViewController.ingredientToWorkWith = getIngredientByUUID(ID, ingredientLibrary: ingredientLibrary)!
                    presentViewController(ingredientLibraryEditorViewController, asPopoverRelativeToRect: outletIngredientLibraryTableView.bounds, ofView: outletIngredientLibraryTableView, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
                    ingredientLibraryEditorViewController.RefreshForEdit();
                }
                
            }
        }
    }
 
   /*
    @IBAction func showIngredientLibraryEditorPopupAsEdit(sender: NSSegmentedControl)
    {
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let ingredientLibraryWindowController = storyboard.instantiateControllerWithIdentifier("Ingredient Library Editor View Controller") as! NSWindowController
        
        if let ingredientLibraryWindow = ingredientLibraryWindowController.window {
            
            print("calling display as popover for ingredient library editor.");
            let ingredientLibraryEditorViewController = ingredientLibraryWindow.contentViewController as! IngredientLibraryIngredientEditorViewController
            ingredientLibraryEditorViewController.mode = "EDIT";
            if (outletIngredientLibraryTableView.selectedRow > -1)
            {
                
            ingredientLibraryEditorViewController.ingredientToWorkWith = ingredientLibrary[outletIngredientLibraryTableView.selectedRow];
            let rectForPopup = outletIngredientLibraryTableView.bounds;
            let viewForPopup = outletIngredientLibraryTableView;
            presentViewController(ingredientLibraryEditorViewController, asPopoverRelativeToRect: rectForPopup, ofView: viewForPopup, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
            //            outletRecipeTableView.selectedCell()?.draw
            //            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            ingredientLibraryEditorViewController.RefreshForEdit();
            }
        }
    }
 */
    
    /*
    @IBAction func showRecipeIngredientEditPopOver(sender: NSSegmentedControl)
    {
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            print("Recipe Ingredient Editor Popover. (button click)");
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.mode = "EDIT";
            addIngredientViewController.incomingRecipe = currentRecipe;
            addIngredientViewController.ingredientToEdit = ingredientToEdit;
 //           let rectForPopup = outletRecipeTableView.bounds;
//            let viewForPopup = outletRecipeTableView;
            let rectForPopup = outletMixLabView.bounds;
            let viewForPopup = outletMixLabView;
            presentViewController(addIngredientViewController, asPopoverRelativeToRect: rectForPopup, ofView: viewForPopup, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
            //            outletRecipeTableView.selectedCell()?.draw
            //            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            addIngredientViewController.RefreshForEdit();
            // 3
            //let application = NSApplication.sharedApplication()
            //application.runModalForWindow(addIngredientWindow)
        }
    }
 */
    
    @IBAction func showRecipeIngredientEditPopOverFromTableRow(sender: NSTableView)
    {
        ingredientToEdit = currentRecipe.RecipeIngredients[sender.clickedRow];
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            print("Recipe Ingredient Editor Popover from Table Row");
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.mode = "EDIT";
            addIngredientViewController.incomingRecipe = currentRecipe;
            
            addIngredientViewController.ingredientToEdit = ingredientToEdit;
            
            presentViewController(addIngredientViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
            //            outletRecipeTableView.selectedCell()?.draw
            //            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            addIngredientViewController.RefreshForEdit();
            // 3
            //let application = NSApplication.sharedApplication()
            //application.runModalForWindow(addIngredientWindow)
        }
    }

    func showRecipeIngredientEditPopOverFromRecipeIngredientID(recipeIngredientID: String)
    {
        UpdateRecipeView();
        print("displaying recipe ingredient editor for newly added ingredient.");
        let indexOfIngredientInRecipe = getRecipeIngredientIndexInLibraryByUUID(recipeIngredientID, recipeIngredients: currentRecipe.RecipeIngredients);
        if (indexOfIngredientInRecipe == -1)
        {
            dialogAlertUser("error editing ingredient.");
            return;
        }
        let ingredientToEdit = currentRecipe.RecipeIngredients[indexOfIngredientInRecipe];
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            print("Recipe Ingredient Editor Popover from Table Row");
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.mode = "EDIT";
            addIngredientViewController.incomingRecipe = currentRecipe;
            
            addIngredientViewController.ingredientToEdit = ingredientToEdit;
            
            presentViewController(addIngredientViewController, asPopoverRelativeToRect: outletMixLabView.bounds, ofView: outletMixLabView, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Transient)
            addIngredientViewController.RefreshForEdit();
        }
    }

    
    @IBAction func ShowRecipeAdditionPopOver(sender: NSSegmentedControl)
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let recipeEditorWindowController = storyboard.instantiateControllerWithIdentifier("Recipe Editor View Controller") as! NSWindowController
        if let recipeEditorWindow = recipeEditorWindowController.window {
            print("calling display as popover for recipe addition.");
            let recipeEditorViewController = recipeEditorWindow.contentViewController as! RecipeEditorViewController
            recipeEditorViewController.mode = "ADD";
            recipeEditorViewController.LoadCategoriesIntoComboBox(recipeLibrary);
            presentViewController(recipeEditorViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinY, behavior: NSPopoverBehavior.Transient)
            print("done with the modal view.");
        }
    }

    
    @IBAction func ShowRecipeEditorPopOverForRowDoubleClick(sender: NSOutlineView)
    {
        //Recipe Editor View Controller
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let recipeEditorWindowController = storyboard.instantiateControllerWithIdentifier("Recipe Editor View Controller") as! NSWindowController
        if let recipeEditorWindow = recipeEditorWindowController.window {
            
            print("calling display as popover for recipe EDITING.");
            let recipeEditorViewController = recipeEditorWindow.contentViewController as! RecipeEditorViewController
            recipeEditorViewController.mode = "EDIT";
            recipeEditorViewController.workingRecipe = recipeLibrary[sender.selectedRow];
            recipeEditorViewController.LoadCategoriesIntoComboBox(recipeLibrary);
            presentViewController(recipeEditorViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinY, behavior: NSPopoverBehavior.Transient)
            print("done with the modal view.");
            recipeEditorViewController.RefreshUIForEdit();
            //            recipeEditorViewController.
        }
    }


 
    //text = NSTextField.alloc().initWithFrame_(((0, 0), (30.0, 22.0)))
    //text.setCell_(NSSearchFieldCell.alloc().init())
    
    //text = NSTextField.alloc().initWithFrame_(((0, 0), (30.0, 22.0)))
    //text.setCell_(NSSearchFieldCell.alloc().init())
    func ShowRecipeEditorPopOverFromRecipeLibraryIndex(index: Int)
    {
        
        //Recipe Editor View Controller
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let recipeEditorWindowController = storyboard.instantiateControllerWithIdentifier("Recipe Editor View Controller") as! NSWindowController
        if let recipeEditorWindow = recipeEditorWindowController.window {
            
            print("calling display as popover for recipe EDITING.");
            let recipeEditorViewController = recipeEditorWindow.contentViewController as! RecipeEditorViewController
            recipeEditorViewController.mode = "EDIT";
            recipeEditorViewController.workingRecipe = recipeLibrary[index];
            recipeEditorViewController.LoadCategoriesIntoComboBox(recipeLibrary);
            presentViewController(recipeEditorViewController, asPopoverRelativeToRect: outletRecipeCategoryOutlineView.bounds, ofView: outletRecipeCategoryOutlineView, preferredEdge: NSRectEdge.MinY, behavior: NSPopoverBehavior.Transient)
            print("done with the modal view.");
            recipeEditorViewController.RefreshUIForEdit();
            //            recipeEditorViewController.
            
        }
    }

    
    @IBAction func showAddPopOver(sender: NSSegmentedControl)
    {
        //Recipe Editor View Controller
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            print("Calling display as popover for adding recipe ingredient.");
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.incomingRecipe = currentRecipe;
            addIngredientViewController.mode = "ADD";
            
            presentViewController(addIngredientViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Transient)
            addIngredientViewController.RefreshForAdd();
//            outletRecipeTableView.selectedCell()?.draw
//            presentViewControllerAsSheet(addIngredientViewController);
            print("done with the modal view.");
            // 3
            //let application = NSApplication.sharedApplication()
            //application.runModalForWindow(addIngredientWindow)
        }
    }
    
    @IBAction func outletRecipeIngredientAddRemoveSegment(sender: NSSegmentedControl) {
        if (sender.selectedSegment == 0)
        {
            print("add button selected!");
            //showAddIngredient(self);
            showAddPopOver(sender);
        }
        if (sender.selectedSegment == 1)
        {
            // we should now delete the selected item from the recipe...
            RemoveSelectedRecipeIngredient();
            print("Delete button selected!");
        }
        if (sender.selectedSegment == 2)
        {
            if (outletRecipeTableView.selectedRow == -1)
            {
                return;
            }
            print("edit button selected");
            // let's find which ingredient we're working with...
            ingredientToEdit = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
            //showEditIngredient(self);
//            showRecipeIngredientEditPopOver(sender);
        }
        if (sender.selectedSegment == 3)
        {
            // refresh button
            UpdateRecipeView();
            outletRecipeTableView.reloadData();
            UpdateMixLabView();
            outletMixLabView.reloadData();
        }
    }
    
    func RemoveSelectedRecipeIngredient()
    {
        print("removing selected recipe ingredient..");
       // let ingredientToRemove = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
        
        //print("removing " + ingredientToRemove.RecipeIngredient.Name);
        // fix bug with removing when no index selected.
        let selectIndex = outletRecipeTableView.selectedRow;
        if (selectIndex > -1)
        {
            currentRecipe.RecipeIngredients.removeAtIndex(outletRecipeTableView.selectedRow);
            //        outletRecipeTableView.reloadData();
            UpdateRecipeView();
            UpdateMixLabView();
            UpdateLabelsWithRecipeInformation();
            UpdateUIControls();
            let indexSet = NSIndexSet(index: selectIndex);
            outletRecipeTableView.selectRowIndexes(indexSet,byExtendingSelection: false);
        }
    }
    
    func RemoveSelectedMixLabRecipeIngredient()
    {
        print("removing selected recipe ingredient");
        if (outletMixLabView.selectedRow > -1)
        {
            let ingredientIdToRemove = mixLab[outletMixLabView.selectedRow].RecipeIngredientID;
            if (ingredientIdToRemove != "")
            {
                for index in 0...currentRecipe.RecipeIngredients.count
                {
                    if (currentRecipe.RecipeIngredients[index].RecipeIngredientID == ingredientIdToRemove)
                    {
                        print("found recipe ingredient to remove.");
                        let areWeSure = dialogAlertUserAreYouSure("Remove Ingredient?", AlertInfo: "Remove ingredient from recipe?");
                        if (areWeSure)
                        {
                            currentRecipe.RecipeIngredients.removeAtIndex(index);
                            UpdateRecipeView();
                            UpdateMixLabView();
                            UpdateLabelsWithRecipeInformation();
                            UpdateUIControls();
                        }
                        return;
                    }
                }
            }
        }
    }
    
    @IBAction func outletNicStrengthTextFieldAction(sender: NSTextField) {
        let string = outletNicStrengthTextField.stringValue;
        let numericSet = "0123456789.";
        let filteredCharacters = string.characters.filter {
            return numericSet.containsString(String($0))
        }
        var filteredString = String(filteredCharacters) // -> 347
        if (filteredString == "") { filteredString = "0"; }
        desiredNicStrength = Double(filteredString)!;
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateMixLabView();
    }
    
    
    
    @IBAction func outletUpdateVGRatioTextField(sender: NSTextField) {
        let string = outletVGRatioTextField.stringValue;
        let numericSet = "0123456789"
        let filteredCharacters = string.characters.filter {
            return numericSet.containsString(String($0))
        }
        var filteredString = String(filteredCharacters) // -> 347
        if (filteredString == "") { filteredString = "0"; }
        VGRatio = Int(filteredString)!;
        PGRatio = 100 - VGRatio;
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateMixLabView();
    }
    @IBAction func outletPGRatioTextField(sender: NSTextField) {
        let string = outletPGRatioTextField.stringValue;
        let numericSet = "0123456789"
        let filteredCharacters = string.characters.filter {
            return numericSet.containsString(String($0))
        }
        var filteredString = String(filteredCharacters) // -> 347
        if (filteredString == "") { filteredString = "0"; }
        
        PGRatio = Int(filteredString)!;
        VGRatio = 100 - PGRatio;
//        print("new PG: " + String(PGRatio) + " - VG: " + String(VGRatio));
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateMixLabView();
    }
    
    @IBAction func outletAmountHandler(sender: NSComboBox) {
        let string = outletAmountComboBox.stringValue;
        let numericSet = "0123456789"
        let filteredCharacters = string.characters.filter {
            return numericSet.containsString(String($0))
        }
        var filteredString = String(filteredCharacters) // -> 347
        if (filteredString == "") { filteredString = "0"; }
        amountOfJuice = Int(filteredString)!;
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateMixLabView();
        
    }
    
    
    /* old handler for ingredient double click 
 
 
 @IBAction func outletIngredientLibraryItemDoubleClick(sender: NSTableView) {
 print("double cilcked item.  edit ingredient.");
 // when we double click a row let's add the ingredient to our recipe.
 if (sender.selectedRow > -1)
 {
 showIngredientLibraryEditorPopupAsEditFromTableRow(sender);
 // filtering is causing us to get the wrong ingredient...why??!?!
 //AddIngredientFromDoubleClick(sender.selectedRow); this is for quick-add to recipe.
 }
 //        AddIngredientFromDoubleClick
 }
 */
    
    //             print("add ingredient.");    showIngredientLibraryEditorPopupAsAdd(sender);

    @IBOutlet weak var outletIngredientLibrarySearchField: NSSearchField!

    /* edit double click function */
    
 
    @IBAction func outletIngredientLibraryItemDoubleClick(sender: NSTableView) {
        print("double clicked item.  edit ingredient.");
        // we should add an ingredient here from the library instead of editing the ingredient.
        let selectedObject : AnyObject = outletIngredientLibraryArrayController.arrangedObjects[sender.selectedRow];
        if (selectedObject is Ingredient)
        {
            let selectedIngredient = selectedObject as! Ingredient;
            print("we selected " + selectedIngredient.Name);
            print("selected object is an ingredient!");
            showIngredientLibraryEditorPopupFromIngredientID(selectedIngredient.ID);
        }
    }
    
/*
    /* add double click function */
    @IBAction func outletIngredientLibraryItemDoubleClick(sender: NSTableView) {
        print("double clicked item.  add ingredient to recipe.");
        let selectedObject : AnyObject = outletIngredientLibraryArrayController.arrangedObjects[sender.selectedRow];
        if (selectedObject is Ingredient)
        {
            let selectedIngredient = selectedObject as! Ingredient;
            let ingredientToAddToRecipe = getIngredientByUUID(selectedIngredient.ID, ingredientLibrary: ingredientLibrary);
            QuickAddIngredientToRecipe(ingredientToAddToRecipe!);
            UpdateLabelsWithRecipeInformation();
            UpdateRecipeView();
            UpdateMixLabView();
            showRecipeIngredientEditPopOverFromRecipeIngredientID((ingredientToAddToRecipe?.ID)!);
        }
    }
*/
    // TODO: Implement filtering potentially.
    
    func AddIngredientFromDoubleClick(ingredientIndex: Int)
    {
        /*
 row = [notesTable selectedRow];
 [myArrayController setSelectionIndex:row];
 
 NSMutableDictionary *dictionary = [myArrayController selection];
 editNoteTextView.string = [dictionary valueForKey:@notesText];*/
        //theRealObject = [[someArrayController selection] valueForKey:@"self"];
            // TODO OMG OMG OMG
        print("we double clicked something....");
    }
    
    
    func dialogAlertUser(AlertInfo: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Alchemy Lab Alert";
        myPopup.informativeText = AlertInfo;
        myPopup.alertStyle = NSAlertStyle.CriticalAlertStyle;
        myPopup.addButtonWithTitle("OK");
        myPopup.runModal();
        return true;
    }
    
    func dialogAlertUserAreYouSure(HeaderInfo : String, AlertInfo: String) -> Bool
    {
        let alert : NSAlert = NSAlert();
        alert.messageText = HeaderInfo;
        alert.informativeText = AlertInfo;
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle;
        alert.addButtonWithTitle("Ok");
        alert.addButtonWithTitle("Cancel");
        let returnCode = alert.runModal();
        if (returnCode == NSAlertFirstButtonReturn)
        {
            return true;
        }
        return false;
    }

    func QuickAddIngredientToRecipe(ingredientToAdd : Ingredient) -> Bool
    {
        let recipeIngredientToAdd : RecipeIngredient = RecipeIngredient();
        var sequence : Int = 0;
        for loopIngredient in currentRecipe.RecipeIngredients
        {
            if (loopIngredient.RecipeIngredientID == ingredientToAdd.ID)
            {
                dialogAlertUser("Ingredient already exists in recipe.  Cannot add duplicate.");
                return false;
            }
            if (loopIngredient.Sequence > sequence)
            {
                sequence = loopIngredient.Sequence + 1;
            }
        }
        recipeIngredientToAdd.RecipeIngredientID = ingredientToAdd.ID;
        recipeIngredientToAdd.Sequence = sequence;
        currentRecipe.RecipeIngredients.append(recipeIngredientToAdd);
        return true;
    }
    
    // Ingredient Library Button Cick Handler
    @IBAction func outletIngredientLibrarySegmentButton(sender: NSSegmentedControl) {
        // for quick add, remove, or edit functionality we need to know which ingredient we're working with.
        var selectedObject : AnyObject? = nil;
        var selectedIngredientID : String? = nil;
        var selectedIngredientIndex = -1;
        if (outletIngredientLibraryTableView.selectedRow > -1)
        {
            
            selectedObject = outletIngredientLibraryArrayController.arrangedObjects[outletIngredientLibraryTableView.selectedRow];
            selectedIngredientID = nil;
            selectedIngredientIndex = -1;
            if (selectedObject is Ingredient)
            {
                let selectedIngredient = selectedObject as! Ingredient;
                print("we selected " + selectedIngredient.Name);
                print("selected object is an ingredient!");
                selectedIngredientID = selectedIngredient.ID;
            }
        }
        
        if (selectedIngredientID != nil)
        {
            selectedIngredientIndex = getIngredientIndexInLibraryByUUID(selectedIngredientID!, ingredientLibrary: ingredientLibrary);
        }
        
        if (sender.selectedSegment == 0)
        {
            // quick add ingredient to recipe..
            if (selectedIngredientIndex != -1 && selectedIngredientID != nil)
            {
                let ingredientToAddToRecipe = getIngredientByUUID(selectedIngredientID!, ingredientLibrary: ingredientLibrary);
                QuickAddIngredientToRecipe(ingredientToAddToRecipe!);
                UpdateRecipeView();
                showRecipeIngredientEditPopOverFromRecipeIngredientID((ingredientToAddToRecipe?.ID)!);
            }
        }
        if (sender.selectedSegment == 1)
        {
            print("add ingredient.");
            showIngredientLibraryEditorPopupAsAdd(sender);
        }
        
        if (sender.selectedSegment == 2)
        {
            print("delete ingredient from library");
            if (selectedIngredientID != nil)
            {
                var ingredientInUse : Bool = false;
                for recipe in recipeLibrary
                {
                    for ingredient in recipe.RecipeIngredients
                    {
                        if (ingredient.RecipeIngredientID == selectedIngredientID)
                        {
                            ingredientInUse = true;
                        }
                    }
                }
                if (ingredientInUse)
                {
                    dialogAlertUser("Cannot delete ingredient - currently in use in recipe.");
                    // let the user know we can't delete this ingredient as it's in use.
                }
                else
                {
                    if (selectedIngredientIndex > -1)
                    {
                        let areWeSure = dialogAlertUserAreYouSure("Remove Ingredient?", AlertInfo: "Are you sure you want to remove " + ingredientLibrary[selectedIngredientIndex].Name + "?");
                        if (areWeSure)
                        {
                            ingredientLibrary.removeAtIndex(selectedIngredientIndex);
                        }
                    }
                    
                }
            }
        }
        if (sender.selectedSegment == 3)
        {
            if (selectedIngredientID != nil)
            {
                print("editing ingredient in library");
                showIngredientLibraryEditorPopupFromIngredientID(selectedIngredientID!);
            }
        }
    }
    
    
    @IBAction func outletNicStrengthSliderHandler(sender: NSSlider) {
        desiredNicStrength = Double(sender.integerValue);
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateMixLabView();
    }
    //TODO: if you change options in the mixlab output in the main panel those changes do not propogate back to the actual recipe.  May want to have that be a dialog.
    
    
    @IBOutlet weak var outletMaxVGCheckBox: NSButton!
    
    @IBAction func outletMaxVGCheckBoxChanged(sender: NSButton) {
        print(sender.state);
        if (sender.state == 1)
        {
            print("enable max VG");
            maxVG = true;
            UpdateLabelsWithRecipeInformation();
            UpdateUIControls();
            UpdateMixLabView();
        }
        if (sender.state == 0)
        {
            print("disable max VG");
            maxVG = false;
            UpdateLabelsWithRecipeInformation();
            UpdateUIControls();
            UpdateMixLabView();
        }
        /*
        if (sender.state == 1)
        {
            print("disable max VG.");
            outletPGRatioTextField.enabled = false;
            outletVGRatioTextField.enabled = false;
            maxVG = false;
            if (PGRatio + VGRatio != 100)
            {
                PGRatio = 30;
                VGRatio = 70;
            }
            UpdateLabelsWithRecipeInformation();
            UpdateUIControls();
            UpdateMixLabView();
        }
        if (sender.state == 0)
        {
            print("enable max VG.");
            outletPGRatioTextField.enabled = true;
            outletVGRatioTextField.enabled = true;
            maxVG = true;
            UpdateLabelsWithRecipeInformation();
            UpdateUIControls();
            UpdateMixLabView();
        }
 */
    }
    @IBOutlet weak var outletRecipeControlSegment: NSSegmentedControl!
    
    @IBAction func outletRecipeControlSegmentAction(sender: NSSegmentedControl) {
        if (sender.selectedSegment == 0)
        {
            // display recipe editor as popup
            ShowRecipeAdditionPopOver(sender);
        }
        if (sender.selectedSegment == 1)
        {
            print ("remove recipe");
            // need to remove a recipe, so first we need to find out what the Index of the selected recipe is in the library..
            let selectedIndex = outletRecipeCategoryOutlineView.selectedRow;
            let object:AnyObject? = outletRecipeCategoryOutlineView.itemAtRow(selectedIndex);
            if (object is RecipeSourceListRecipe)
            {
                let recipeToRemoveFromControlSegment = object as! RecipeSourceListRecipe;
                print("we are going to remove" + recipeToRemoveFromControlSegment.Name);
                let indexToRemove = getRecipeIndexInLibraryByUUID(recipeToRemoveFromControlSegment.RecipeID, recipeLibrary: recipeLibrary);
                if (indexToRemove > -1)
                {
                    recipeLibrary.removeAtIndex(indexToRemove);
                    LoadRecipesIntoSourceListContainer();
                    outletRecipeCategoryOutlineView.reloadData();
                    outletRecipeCategoryOutlineView.expandItem(nil, expandChildren: true);
                }

            }
        }
        if (sender.selectedSegment == 2)
        {
            dialogAlertUser("Copy recipe functionality coming soon.");
            /*
            print ("duplicate recipe.");
            let duplicate = recipes[outletRecipeList.selectedRow].mutableCopy() as! Recipe;
            duplicate.ID = NSUUID().UUIDString;
            duplicate.RecipeName = "Copy of " + duplicate.RecipeName;
            recipes.append(duplicate);
            outletRecipeList.reloadData();
            */
        }
        if (sender.selectedSegment == 3)
        {
            print("we need to edit a recipe..let's find out which recipe we're editing..");
            let selectedIndex = outletRecipeCategoryOutlineView.selectedRow;
            let object:AnyObject? = outletRecipeCategoryOutlineView.itemAtRow(selectedIndex);
            if (object is RecipeSourceListRecipe)
            {
                let recipeToEditFromControlSegment = object as! RecipeSourceListRecipe;
                print("we are going to edit " + recipeToEditFromControlSegment.Name);
                let indexToEdit = getRecipeIndexInLibraryByUUID(recipeToEditFromControlSegment.RecipeID, recipeLibrary: recipeLibrary);
                if (indexToEdit > -1)
                {
                    print(String(format: "found recipe at index %d",indexToEdit));
                    ShowRecipeEditorPopOverFromRecipeLibraryIndex(indexToEdit);
                }
            }
        }
    }
    
    @IBAction func outletRecipeCategoryOutlineViewDoubleClickAction(sender: NSOutlineView) {
        print("received double click event for Recipe Category outline view, handle it.");
        print("we need to edit a recipe..let's find out which recipe we're editing..");
        let selectedIndex = sender.selectedRow;
        let object:AnyObject? = sender.itemAtRow(selectedIndex);
        if (object is RecipeSourceListRecipe)
        {
            let recipeToEditFromControlSegment = object as! RecipeSourceListRecipe;
            print("we are going to edit " + recipeToEditFromControlSegment.Name);
            let indexToEdit = getRecipeIndexInLibraryByUUID(recipeToEditFromControlSegment.RecipeID, recipeLibrary: recipeLibrary);
            if (indexToEdit > -1)
            {
                print(String(format: "found recipe at index %d",indexToEdit));
                ShowRecipeEditorPopOverFromRecipeLibraryIndex(indexToEdit);
            }
        }

        // we need to edit a recipe now based on this.
    }
    
    // end outlets;
    
    @IBOutlet var outletIngredientLibraryArrayController: NSArrayController!
    
    //dynamic var ingredientLibrary = LoadPlaceHolderIngredients();
    dynamic var ingredientLibrary = [Ingredient()];
    dynamic var recipeLibrary = [Recipe()];
    // these are the two data values for the Tables.
    dynamic var recipeDisplay = [RecipeDisplay]();
    dynamic var mixLab = [mixLabDisplay]();
    
    var currentRecipe = Recipe();
    
    @IBOutlet weak var outletIngredientLibraryTableView: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        LoadIngredientsFromXML();
        LoadRecipesFromXML();
        
        // recipes are now in the library, let's make our view for it.
        LoadRecipesIntoSourceListContainer();
        // now that recipes are loaded...we need to create our

        // defaults for recipe.
        // http://swiftrien.blogspot.com/2015/04/adding-menu-items-and-their-actions.html
        
        PGRatio = 30;
        VGRatio = 70;
        amountOfJuice = 50;
        desiredNicStrength = 6;
        //recipes = LoadDefaultRecipe(ingredientLibrary);
        
        currentRecipe = recipeLibrary[0];
        // let's get our sliders and UI all setup...
        UpdateLabelsWithRecipeInformation();
        UpdateUIControls();
        UpdateRecipeView();
        UpdateMixLabView();
        ViewController.sharedInstance = self;
        print("reloading recipe list on the left...");
        outletRecipeTableView.reloadData();
        print("now attempting to run XML parser...");
        
        outletMixLab.rearrangeObjects();
        outletRecipe.rearrangeObjects();
        
        //TODO: Long term implement drag and drop...?
        //TODO: 
        //var registeredTypes:[String] = [NSStringPboardType]
       // outletRecipeTableView.registerForDraggedTypes(registeredTypes);
       // outletIngredientLibraryTableView.registerForDraggedTypes(registeredTypes);
//        outletRecipeTableView.registerForDraggedTypes(<#T##newTypes: [String]##[String]#>)
//        outletRecipeTableView.registerForDraggedTypes(<#T##newTypes: [String]##[String]#>) -- Drag and drop functionality
        // http://www.knowstack.com/swift-nstableview-drag-drop-in/
        //outletRecipeList.reloadData()
        self.outletRecipeCategoryOutlineView.reloadData();
        self.outletRecipeCategoryOutlineView.expandItem(nil, expandChildren: true)
//        self.view.c
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self;
        super.viewDidAppear();
    }
    
    @IBOutlet var outletRecipeLabelTextView: NSTextView!
    
    @IBOutlet weak var outletRecipeLabelImageView: NSImageView!
    
    @IBOutlet weak var outletRecipeInformationLabel: NSTextField!
    
    @IBOutlet weak var outletRecipeAdditionalInformationLabel: NSTextField!
    
    @IBOutlet weak var outletIngredientLabelMaterialInformation: NSTextField!
    @IBOutlet weak var outletIngredientLabelFlavorInformation: NSTextField!
    
    @IBOutlet weak var outletIngredientLabelTotalFlavorPercentage: NSTextField!
    
    @IBOutlet weak var outletIngredientLabelNotes: NSTextField!
    
    func UpdateUIControls()
    {
        //outletIngredientLabelNotes.stringValue = "";
        //outletIngredientLabelMaterialInformation.stringValue = "";
        //outletIngredientLabelFlavorInformation.stringValue = "";
        //outletIngredientLabelTotalFlavorPercentage.stringValue = "";
        // let's go get the ingredient that we're working with if one is selected..
        switch (currentRecipe.RecipeCategory.uppercaseString)
        {
            case "FRUIT":
                outletRecipeLabelImageView.image = NSImage(named: "category-fruit");
            case "FRUITS":
                outletRecipeLabelImageView.image = NSImage(named: "category-fruit");
            case "DESSERT":
                outletRecipeLabelImageView.image = NSImage(named: "category-dessert");
            case "DESSERTS":
                outletRecipeLabelImageView.image = NSImage(named: "category-dessert");
            case "DRINK":
                outletRecipeLabelImageView.image = NSImage(named: "category-drink");
            case "DRINKS":
                outletRecipeLabelImageView.image = NSImage(named: "category-drink");
            case "MENTHOL":
                outletRecipeLabelImageView.image = NSImage(named: "category-menthol");
            case "MENTHOLS":
                outletRecipeLabelImageView.image = NSImage(named: "category-menthol");
            case "THE APOTHECARY":
                outletRecipeLabelImageView.image = NSImage(named: "category-apothecary");
            default:
                outletRecipeLabelImageView.image = NSImage(named: "category-default");
        }
        if (outletMaxVGCheckBox.state == 0)
        {
            outletLabelRecipeName.stringValue = String(format: "%@ - (%d%%vg/%d%%pg)",currentRecipe.RecipeName, VGRatio, PGRatio, amountOfJuice, desiredNicStrength);
        } else {
            outletLabelRecipeName.stringValue = String(format: "%@ - Max VG",currentRecipe.RecipeName, VGRatio, PGRatio, amountOfJuice, desiredNicStrength);

        }
        outletRecipeInformationLabel.stringValue = String(format: "%dml @ %.2fmg/mL Nicotine", amountOfJuice, desiredNicStrength);
        if (currentRecipe.RecipeDescription != "")
        {
            outletRecipeAdditionalInformationLabel.stringValue = currentRecipe.RecipeDescription;
        } else {
            outletRecipeAdditionalInformationLabel.stringValue = "";
        }
        outletPGRatioTextField.integerValue = PGRatio;
        outletVGRatioTextField.integerValue = VGRatio;
        outletMaxVGCheckBox.state = maxVG ? 1 : 0;
        outletNicStrengthTextField.doubleValue = desiredNicStrength;
        outletAmountComboBox.stringValue = String(format:"%dml",amountOfJuice);
        outletRecipeTableView.reloadData();

    }
    
    
    
    func UpdateRecipeView()
    {
        let recipe : Recipe = currentRecipe;
        recipeDisplay.removeAll();
        // sort our ingredients by sequence prior to displaying.
        recipe.RecipeIngredients.sortInPlace({$0.Sequence < $1.Sequence});
        for ingredient in recipe.RecipeIngredients
        {
            let ingredientFromLibrary = getIngredientByUUID(ingredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary)
            let rlDisplay = RecipeDisplay();
            if (ingredientFromLibrary != nil)
            {
            rlDisplay.Base = (ingredientFromLibrary?.Base)!;
            rlDisplay.Ingredient = (ingredientFromLibrary?.Name)!;
            rlDisplay.Percentage = String(format:"%2.2f%%",ingredient.Percentage);
            rlDisplay.Sequence = ingredient.Sequence;
            if (ingredientFromLibrary!.Type.uppercaseString != "FLAVOR")
            {
                rlDisplay.Percentage = "n/a";
            }
            rlDisplay.Strength = String(format:"%.2fmg/ml",(ingredientFromLibrary?.Strength)!);
            if (ingredientFromLibrary!.Type.uppercaseString != "NICOTINE")
            {
                rlDisplay.Strength = "n/a";
            }
            rlDisplay.Type = ingredientFromLibrary!.Type;
            rlDisplay.backgroundIngredient = ingredient;
            rlDisplay.backgroundStrength = ingredientFromLibrary!.Strength;
            rlDisplay.backgroundPercentage = ingredient.Percentage;
            }
            else
            {
                rlDisplay.Ingredient = ingredient.RecipeIngredientID + "NOT FOUND";
            }
            recipeDisplay.append(rlDisplay);

        }
        outletRecipeTableView.reloadData();
    }
    
    
    func UpdateMixLabView()
    {
        let recipe : Recipe = currentRecipe;
        print("received a recipe for " + recipe.RecipeName);
        mixLab.removeAll();
        // need to loop through the currently Displayed Recipe and do all of our math based on that. NOT the currentRecipe because that may not have been updated for some reason.
        // first let's determine how much juice we're making.
        var totalVGNeeded : Double = 0;
        var totalPGNeeded : Double = 0;
        var nicSolutionNeeded : Double = 0.00;
        if (!maxVG)
        {
            totalVGNeeded = (Double(amountOfJuice)-(Double(amountOfJuice) * (Double(PGRatio) / 100)));
            totalPGNeeded = (Double(amountOfJuice)-(Double(amountOfJuice) * (Double(VGRatio) / 100)));
        }
        else
        {
            totalVGNeeded = Double(amountOfJuice);
            totalPGNeeded = 0; // if we're going with max VG, we don't DEMAND that we have any PG.  We will need to compensate for this later however.
        }
        // first let's determine how much VG/PG we need as a total...based on our ratio.
        var PGWeight : Double = 0.0;
        var VGWeight : Double = 0.0;
      //  var nicBase : String = "";
        var nicPGRatio : Double = 0.00;
        var nicVGRatio : Double = 0.00;
      //  var nicSolutionVolumeThatIsPG : Double = 0.0;
     //   var nicSolutionVolumeThatIsVG : Double = 0.0;
        
        for vg in recipeDisplay
        {
            let ingredientFromLibrary = getIngredientByUUID(vg.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (ingredientFromLibrary?.Type.uppercaseString == "VG")
            {
                VGWeight = (ingredientFromLibrary?.Gravity)!;
                break;
            }
        }
        for pg in recipeDisplay
        {
            let ingredientFromLibrary = getIngredientByUUID(pg.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (ingredientFromLibrary?.Type.uppercaseString == "PG")
            {
                PGWeight = (ingredientFromLibrary?.Gravity)!;
                break;
            }
        }
        var nicotineIngredientId = "";
        var nicotineDisplayString = "";
        let nicDisplay = mixLabDisplay();
        for nicotine in recipeDisplay
        {
            let ingredientFromLibrary = getIngredientByUUID(nicotine.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (ingredientFromLibrary?.Type.uppercaseString == "NICOTINE")
            {
                nicotineIngredientId = nicotine.backgroundIngredient.RecipeIngredientID;
                nicotineDisplayString = nicotine.Ingredient;
                nicDisplay.RecipeIngredientID = nicotineIngredientId;
                break;
            }
        }
        if (nicotineIngredientId != "")
        {
            print("determining how much nicotine solution we need...");
            // find our nicotine and determine how much nic we need for our solution..
            let nicotine = getIngredientByUUID(nicotineIngredientId, ingredientLibrary: ingredientLibrary)
            nicPGRatio = (nicotine?.PGRatioForIngredient)!;
            nicVGRatio = (nicotine?.VGRatioForIngredient)!;
            var baseWeight : Double = 0.0;
            var nicBaseWeight = Double(desiredNicStrength) * nicotine!.Gravity;
            if (nicotine!.Base.uppercaseString == "PG")
            {
                baseWeight = PGWeight;
            }
            if (nicotine!.Base.uppercaseString == "VG")
            {
                baseWeight = VGWeight;
            }
            let nicSolutionNeeded = (desiredNicStrength / nicotine!.Strength) * Double(amountOfJuice);
            
            //let nicStrength : Double = nicotine!.Strength / 10;
            //nicBaseWeight += Double((100-nicStrength)) * baseWeight;
            //nicBaseWeight = nicBaseWeight / 100;
            //nicSolutionNeeded = (Double(desiredNicStrength) * Double(amountOfJuice)) / 100;
            //nicBaseWeight = nicSolutionNeeded * (nicotine?.Gravity)!;
            totalVGNeeded -= nicSolutionNeeded * (nicVGRatio/100);
            totalPGNeeded -= nicSolutionNeeded * (nicPGRatio/100);
           // print(String(format: "Nic amount in VG: %2.2f -- PG: %2.2f",nicSolutionVolumeThatIsVG, nicSolutionVolumeThatIsPG));
            
            // at this point we know all about our nicotine so we should be able to add it to the mixlab display.
            nicDisplay.Ingredient = nicotineDisplayString + String(format: " [%d%%vg/%d%%pg]",Int((nicotine?.VGRatioForIngredient)!), Int((nicotine?.PGRatioForIngredient)!));
            
            //    mlDisplay.Ingredient = nicotineDisplayString;
            nicDisplay.Volume = String(format:"%.2fml",nicSolutionNeeded);
            nicDisplay.backgroundVolume = nicSolutionNeeded;
            nicDisplay.Weight = String(format:"%.2fg",nicBaseWeight);
            nicDisplay.backgroundWeight = nicBaseWeight;
            nicDisplay.backgroundCost = (nicSolutionNeeded * nicotine!.Cost);
            nicDisplay.Cost = String(format:"$%.2f",nicDisplay.backgroundCost);
            nicDisplay.backgroundPercentage = (nicSolutionNeeded / Double(amountOfJuice)) * 100;
            nicDisplay.Percentage = String(format: "%.2f%%",nicDisplay.backgroundPercentage);
            mixLab.append(nicDisplay);
        }
        
        // determine how much nicotine solution we need first.
        
        var volumeOfPGInFlavors = 0.00;

        // Nicotine has been sorted out.  Now we need to sort out how much of our flavorings we need.
        for flavor in recipeDisplay
        {
            let flavorIngredient = getIngredientByUUID(flavor.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            let mlDisplay = mixLabDisplay();
            mlDisplay.RecipeIngredientID = flavor.backgroundIngredient.RecipeIngredientID;
            if (flavorIngredient != nil)
            {
                
                if (flavorIngredient!.Type.uppercaseString == "FLAVOR")
                {
                    // first determine how much of this flavor we need..
                    let volumeOfFlavorNeeded = (flavor.backgroundPercentage * Double(amountOfJuice)) / 100;
                    /* allowing flavors to be hybrid base ratios as well.
                     if (flavor.Base.uppercaseString == "PG")
                     {
                     totalPGNeeded -= volumeOfFlavorNeeded;
                     }
                     if (flavor.Base.uppercaseString == "VG")
                     {
                     totalVGNeeded -= volumeOfFlavorNeeded;
                     }*/
                    mlDisplay.Ingredient = flavor.Ingredient + String(format: " [%d%%vg/%d%%pg]",Int((flavorIngredient?.VGRatioForIngredient)!), Int((flavorIngredient?.PGRatioForIngredient)!));
                    mlDisplay.backgroundWeight = (volumeOfFlavorNeeded * flavorIngredient!.Gravity);
                    mlDisplay.backgroundVolume = volumeOfFlavorNeeded;
                    mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
                    volumeOfPGInFlavors += (volumeOfFlavorNeeded * ((flavorIngredient?.PGRatioForIngredient)!/100));
                    totalVGNeeded -= mlDisplay.backgroundVolume * ((flavorIngredient?.VGRatioForIngredient)!/100);
                    totalPGNeeded -= mlDisplay.backgroundVolume * ((flavorIngredient?.PGRatioForIngredient)!/100);
                    mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
                    mlDisplay.backgroundCost = flavorIngredient!.Cost;
                    mlDisplay.Cost = String(format:"$%.2f",mlDisplay.backgroundCost);
                    mlDisplay.backgroundPercentage = flavor.backgroundPercentage;
                    mlDisplay.Percentage = String(format:"%.2f%%",mlDisplay.backgroundPercentage);
                    mixLab.append(mlDisplay);
                }
            } else {
                print("cannot find ingredient in library. oops.");
                mlDisplay.Ingredient = "INGREDIENT NOT FOUND";
            }
        }
        
        if (maxVG)
        {
            totalVGNeeded -= volumeOfPGInFlavors;
            totalPGNeeded = Double(amountOfJuice) - volumeOfPGInFlavors;
            totalPGNeeded -= totalVGNeeded;
        }
        for pg in recipeDisplay
        {
            let pgIngredient = getIngredientByUUID(pg.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (pgIngredient != nil)
            {
                
                if (pgIngredient!.Type.uppercaseString == "PG")
                {
                    //totalPGNeeded -= nicSolutionVolumeThatIsVG;
                    let mlDisplay = mixLabDisplay();
                    mlDisplay.RecipeIngredientID = pg.backgroundIngredient.RecipeIngredientID;
                    mlDisplay.Ingredient = pg.Ingredient;
                    mlDisplay.backgroundVolume = totalPGNeeded;
                    mlDisplay.backgroundWeight = (mlDisplay.backgroundVolume * pgIngredient!.Gravity);
                    mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
                    mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
                    mlDisplay.backgroundCost = (mlDisplay.backgroundVolume * pgIngredient!.Cost);
                    mlDisplay.Cost = String(format:"$%.2f",mlDisplay.backgroundCost);
                    //mlDisplay.Percentage = "n/a";
                    mlDisplay.backgroundPercentage = (totalPGNeeded / Double(amountOfJuice)) * 100
                    mlDisplay.Percentage = String(format:"%.2f%%",mlDisplay.backgroundPercentage);
                    mixLab.append(mlDisplay);
                }
            } else {
                print("cannot find ingredient.  oops.");
            }
        }

        
        // now we need to determine our VG/PG amounts.
        for vg in recipeDisplay
        {
            let vgIngredient = getIngredientByUUID(vg.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (vgIngredient != nil)
            {
                
            if (vgIngredient!.Type.uppercaseString == "VG")
            {
                //totalVGNeeded -= nicSolutionVolumeThatIsVG;
                let mlDisplay = mixLabDisplay();
                mlDisplay.RecipeIngredientID = vg.backgroundIngredient.RecipeIngredientID;
                mlDisplay.Ingredient = vg.Ingredient;
                mlDisplay.backgroundVolume = totalVGNeeded;
                mlDisplay.backgroundWeight = (mlDisplay.backgroundVolume * vgIngredient!.Gravity);
                mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
                mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
                mlDisplay.backgroundCost = (mlDisplay.backgroundVolume * vgIngredient!.Cost);
                mlDisplay.Cost = String(format:"$%.2f",mlDisplay.backgroundCost);
                mlDisplay.backgroundPercentage = (totalVGNeeded / Double(amountOfJuice)) * 100

                mlDisplay.Percentage = String(format:"%.2f%%",mlDisplay.backgroundPercentage);
                //mlDisplay.backgroundPercentage = 0;
                mixLab.append(mlDisplay);
            }
            } else {
                print("cannot find ingredient. oops.");
            }
                

        }
        

      //  for ingredient in recipeDisplay
     //   {
    //        let mlDisplay = mixLabDisplay();
//            ingredient.backgroundIngredient.RecipeIngredient.Type
  //          mlDisplay.Ingredient = ingredient.Ingredient;
            // now let's figure out how much of this ingredient we need...
//        }
/*        for ingredient in recipe.RecipeIngredients
        {
            let mlDisplay = mixLabDisplay();
            mlDisplay.Ingredient = ingredient.RecipeIngredient.Name;
            mlDisplay.Weight = "0.00";
            mlDisplay.Volume = "0.00";
            mlDisplay.Cost = "0.00";
            mlDisplay.backgroundCost = 0.00;
            mlDisplay.backgroundVolume = 0.00;
            mlDisplay.backgroundWeight = 0.00;
            mixLab.append(mlDisplay);
            // need to loop through the ingredients and do things with them...
        }*/
        var totalVolume : Double = 0.00;
        var totalWeight : Double = 0.00;
        var totalCost : Double = 0.00;
        var totalPercentage : Double = 0.00;
        for mixlabingredient in mixLab
        {
            totalVolume += mixlabingredient.backgroundVolume;
            totalWeight += mixlabingredient.backgroundWeight;
            totalCost += mixlabingredient.backgroundCost;
            totalPercentage += mixlabingredient.backgroundPercentage;
        }
        
        let mlDisplay = mixLabDisplay();
        mlDisplay.Ingredient = "TOTALS";
        mlDisplay.Volume = String(format: "%.2fml",totalVolume);
        mlDisplay.Weight = String(format: "%.2fg",totalWeight);
        mlDisplay.Cost = String(format: "$%.2f",totalCost);
        mlDisplay.Percentage = String(format: "%.2f%%",totalPercentage);
        mixLab.append(mlDisplay);
        
        outletMixLabView.reloadData();
        
    }
    
    /* Begin Mixlab Table handlers */
    
    @IBAction func outletMixLabRowClickHandler(sender: NSTableView)
    {
        print("row clicked in mix lab.");
        UpdateLabelsWithRecipeInformation();
    }
    
    func UpdateLabelsWithRecipeInformation()
    {
        outletIngredientLabelMaterialInformation.stringValue = "";
        outletIngredientLabelTotalFlavorPercentage.stringValue = "";
        outletIngredientLabelFlavorInformation.stringValue = "";
        outletIngredientLabelNotes.stringValue = "";
        
        var totalFlavorPercentage : Double = 0;
        for ingredientId in currentRecipe.RecipeIngredients
        {
            let ingredient = getIngredientByUUID(ingredientId.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (ingredient?.Type.uppercaseString == "FLAVOR")
            {
                totalFlavorPercentage += ingredientId.Percentage;
            }
        }
        outletIngredientLabelTotalFlavorPercentage.stringValue = String(format: "Total Flavor Percentage: %.2f%%",totalFlavorPercentage);

        if (outletMixLabView.selectedRow > -1)
        {
            print("we have a row -- should be updating.");
            let selectedRecipeIngredientId = mixLab[outletMixLabView.selectedRow].RecipeIngredientID;
            if (selectedRecipeIngredientId != "")
            {
                let selectedIngredient = getIngredientByUUID(selectedRecipeIngredientId, ingredientLibrary: ingredientLibrary);
                outletIngredientLabelFlavorInformation.stringValue = String(format: "Type: %@ | Mfg: %@",(selectedIngredient?.Type.capitalizedString)!, (selectedIngredient?.Manufacturer.capitalizedString)!);
                outletIngredientLabelMaterialInformation.stringValue = String(format: "%d%%vg/%d%%pg | Gravity: %.4f",Int((selectedIngredient?.VGRatioForIngredient)!), Int((selectedIngredient?.PGRatioForIngredient)!),(selectedIngredient?.Gravity)!);
                if (selectedIngredient?.Type.uppercaseString == "NICOTINE")
                {
                    outletIngredientLabelMaterialInformation.stringValue += String(format: " | Strength: %.2fmg/mL", selectedIngredient!.Strength);
                }
                if (selectedIngredient?.Notes != "")
                {
                    outletIngredientLabelNotes.stringValue = (selectedIngredient?.Notes)!;
                    outletIngredientLabelNotes.toolTip = (selectedIngredient?.Notes)!;
                } else
                {
                    outletIngredientLabelNotes.stringValue = "";
                }
            }

        }
        /*
        print("attempting to update recipe information..");
        if (sender.selectedRow > -1)
        {
        }*/
    }
    
    /*
     let selectedIndex = outletRecipeCategoryOutlineView.selectedRow;
     let object:AnyObject? = outletRecipeCategoryOutlineView.itemAtRow(selectedIndex);
     if (object is RecipeSourceListRecipe)
     {
     let recipeToRemoveFromControlSegment = object as! RecipeSourceListRecipe;
     print("we are going to remove" + recipeToRemoveFromControlSegment.Name);
     let indexToRemove = getRecipeIndexInLibraryByUUID(recipeToRemoveFromControlSegment.RecipeID, recipeLibrary: recipeLibrary);
     if (indexToRemove > -1)
     {
     recipeLibrary.removeAtIndex(indexToRemove);
     LoadRecipesIntoSourceListContainer();
     outletRecipeCategoryOutlineView.reloadData();
     outletRecipeCategoryOutlineView.expandItem(nil, expandChildren: true);
     }
     
     }
     */

    @IBAction func outletMixLabRowDoubleClickHandler(sender: NSTableView) {
        print("row double clicked in mix lab.");
        if (sender.selectedRow > -1)
        {
            let selectedMixLabRow = mixLab[sender.selectedRow];
            if (selectedMixLabRow.RecipeIngredientID != "")
            {
                print("editing ingredient...");
                
                showRecipeIngredientEditPopOverFromRecipeIngredientID(selectedMixLabRow.RecipeIngredientID);
            }
        }
    }
 
 
    /* End Mixlab Table handlers */
 
 /* New source list implementation */
 
    var recipeSourceListHeader : RecipeSourceListHeader = RecipeSourceListHeader();
    func LoadRecipesIntoSourceListContainer()
    {
        recipeSourceListHeader = RecipeSourceListHeader();
        recipeSourceListHeader.Name = "Recipes";
        // let's determine our categories...
        var categories : [String] = []
        // we've created our header.  now we have to create our recipes.
        for recipeCategory in recipeLibrary
        {
            if !categories.contains(recipeCategory.RecipeCategory.capitalizedString)
            {
                categories.append(recipeCategory.RecipeCategory.capitalizedString);
            }
        }
        // now we have a list of categories, let's create an object for each one.
        for categoryToCreate in categories
        {
            let recipeCategory = RecipeSourceListCategory();
            recipeCategory.CategoryName = categoryToCreate;
            recipeCategory.Icon = NSImage(named: "category");
            for recipeToAddToCategory in recipeLibrary where recipeToAddToCategory.RecipeCategory.capitalizedString == recipeCategory.CategoryName
            {
                // create the recipe and add it to the list.
                let recipeSourceToAdd = RecipeSourceListRecipe();
                recipeSourceToAdd.Name = recipeToAddToCategory.RecipeName;
                recipeSourceToAdd.RecipeID = recipeToAddToCategory.ID;
                recipeSourceToAdd.Icon = NSImage(named: "chemical");
                print("adding recipe to category.");
                recipeCategory.Recipes.append(recipeSourceToAdd);
            }
            recipeCategory.Recipes.sortInPlace({$0.Name < $1.Name});
            recipeSourceListHeader.RecipeCategories.append(recipeCategory);
        }
        //        recipe.RecipeIngredients.sortInPlace({$0.Sequence < $1.Sequence});
        recipeSourceListHeader.RecipeCategories.sortInPlace({$0.CategoryName < $1.CategoryName});
        print("now we have a list!!");
    }
    
 
    @IBOutlet weak var outletRecipeCategoryOutlineView: NSOutlineView!
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        print("outlineView: 1");
        if (recipeSourceListHeader.RecipeCategories.count < 1)
        {
            return self;
        }
            if let item: AnyObject = item {
                switch item {
                case let recipeHeader as RecipeSourceListHeader:
                    print("item is a recipe header.");
                    return recipeHeader.RecipeCategories[index]
                case let recipeCategory as RecipeSourceListCategory:
                    print("item is a recipe category.");
                    return recipeCategory.Recipes[index]
                default:
                    print("item is self.");
                    return self
                }
            } else {
                switch index {
                case 0:
                    print("returning first row.");
                    return recipeSourceListHeader;
                default:
                    return recipeSourceListHeader.RecipeCategories[0]; // not sure about this.
                }
            }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        print("outlineView: 2");
            switch item {
            case let recipeHeader as RecipeSourceListHeader:
                return (recipeHeader.RecipeCategories.count > 0) ? true : false
            case let recipeCategory as RecipeSourceListCategory:
                return (recipeCategory.Recipes.count > 0) ? true : false
            default:
                return false
            }
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        print("outlineView: 3");
            if let item: AnyObject = item {
                switch item {
                case let recipeHeader as RecipeSourceListHeader:
                    print("outlineView: returning recipe categories count.");
                    return recipeHeader.RecipeCategories.count
                case let recipeCategory as RecipeSourceListCategory:
                    print("outlineView: returning recipe count.");
                    return recipeCategory.Recipes.count
                default:
                    print("outlineView: not returning shit.");
                    return 0
                }
            } else {
                print("outlineView: default bullshit.");
                return 1; //Department1 , Department 2
            }
    }
    
    
    // NSOutlineViewDelegate
    func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        print("outlineView: 4");
            switch item {
            case let recipeHeader as RecipeSourceListHeader:
                print("we should be creating a header cell.");
                let view = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = recipeHeader.Name;
                }
                return view
            case let recipeCategory as RecipeSourceListCategory:
                print("outlineView: we should be creating a tablecellview here it seems...");
                print(recipeCategory.CategoryName);
                let view = outlineView.makeViewWithIdentifier("CategoryCell", owner: self) as! NSTableCellView;
                print("made the view!");
                if let textField = view.textField {
                    textField.stringValue = recipeCategory.CategoryName;
                }
                if let image = recipeCategory.Icon {
                    view.imageView!.image = image
                }
                return view
            case let recipe as RecipeSourceListRecipe:
                let view = outlineView.makeViewWithIdentifier("RecipeCell", owner: self) as! NSTableCellView
                if let textField = view.textField {
                    textField.stringValue = recipe.Name
                }
                if let image = recipe.Icon {
                    view.imageView!.image = image;
                }
                let recipeFromIndex = getRecipeByUUID(recipe.RecipeID, recipeLibrary: recipeLibrary)
                if (recipeFromIndex?.Notes != "")
                {
                    view.toolTip = "NOTES: " + (recipeFromIndex?.Notes)!;
                }
               // if let image = employee.icon {
               //     view.imageView!.image = image
               // }
                return view
            default:
                return nil
            }
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        print("outlineView: 5");
            switch item {
            case let recipeHeader as RecipeSourceListHeader:
                print("outlineView: returning true.");
                return true
            default:
                print("outlineView: returning false.");
                return false
            }
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification)
    {
        print(notification);
        var selectedIndex = notification.object?.selectedRow;
        var object:AnyObject? = notification.object?.itemAtRow(selectedIndex!);
        if (object is RecipeSourceListRecipe)
        {
            let r = object as! RecipeSourceListRecipe;
            
            print("need to load up recipe: " + r.Name + "(" + r.RecipeID + ")");
            let i = getRecipeIndexInLibraryByUUID(r.RecipeID, recipeLibrary: recipeLibrary);
            if (i > -1)
            {
                currentRecipe = recipeLibrary[i];
                
                if (currentRecipe.PGRatio + currentRecipe.VGRatio != 100)
                {
                    currentRecipe.PGRatio = 30;
                    currentRecipe.VGRatio = 70;
                }
                PGRatio = currentRecipe.PGRatio;
                VGRatio = currentRecipe.VGRatio;
                maxVG = currentRecipe.maxVG;
                UpdateLabelsWithRecipeInformation();
                UpdateUIControls();
                UpdateRecipeView();
                UpdateMixLabView();
            } else
            {
                dialogAlertUser("cannot find recipe in library.");
            }
        }
        
    }
    
 
 
    /* XML Parsing Functionality */
 
    /*
 <IngredientLibrary>
	<IngredientLibraryIngredient ID="" Name="FW Menthol" Manufacturer="Flavor West" Type="FLAVOR" Base="PG" Gravity="1.03" Cost="0.23" Strength="0.0" Notes="These are my notes about this flavor"/>
*/
    var recipeLibraryParser = NSXMLParser();
    var recipeLibraryFromXML = [Recipe]();
    var recipeWeAreParsing = Recipe();

    var ingredientLibraryParser = NSXMLParser();
    var ingredientLibraryFromXML = [Ingredient]();
    var ingredientFromXML = Ingredient();
    var hadToAddIDs : Bool = false;
    var hadToAddRecipeIDs : Bool = false;
 
    func parserDidStartDocument(parser: NSXMLParser) {
        if (parser == ingredientLibraryParser)
        {
            ingredientLibraryFromXML = [Ingredient]();
            print("parsing ingredient library XML");
        }
        if (parser == recipeLibraryParser)
        {
 
            print("parsing recipe Library XML");
        }
    }

    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if (parser == ingredientLibraryParser && elementName == "IngredientLibraryIngredient")
        {
            print ("found an ingredient!");
            ingredientFromXML = Ingredient();
            ingredientFromXML.ID = attributeDict["ID"]!;
            ingredientFromXML.Name = attributeDict["Name"]!;
            ingredientFromXML.Manufacturer = attributeDict["Manufacturer"]!;
            ingredientFromXML.Type = attributeDict["Type"]!;
            ingredientFromXML.Base = attributeDict["Base"]!;
            ingredientFromXML.Gravity = Double(attributeDict["Gravity"]!)!;
            ingredientFromXML.Cost = Double(attributeDict["Cost"]!)!;
            ingredientFromXML.Strength = Double(attributeDict["Strength"]!)!;
            ingredientFromXML.Notes = attributeDict["Notes"]!;
            /* XML TODO OMG OMG OMG OMG */
            ingredientFromXML.VGRatioForIngredient = Double(attributeDict["VGRatioForIngredient"]!)!;
            ingredientFromXML.PGRatioForIngredient = Double(attributeDict["PGRatioForIngredient"]!)!;
            print("finished up ingredient.");
            if ingredientFromXML.ID == ""
            {
                ingredientFromXML.ID = NSUUID().UUIDString;
                hadToAddIDs = true;
            }
            print("found ingredient library ingredient.  yay us!");
            ingredientLibraryFromXML.append(ingredientFromXML);
        }
        if (parser == recipeLibraryParser)
        {
            print("found an element in the recipe Library Parser..");
            if (elementName == "Recipe")
            {
                print("parsing a recipe element, need to reset. EndElement is responsible for getting it in the library for the UI");
                recipeWeAreParsing = Recipe();
                recipeWeAreParsing.RecipeIngredients = [RecipeIngredient]();
                recipeWeAreParsing.ID = attributeDict["ID"]!;
                recipeWeAreParsing.RecipeName = attributeDict["RecipeName"]!;
                recipeWeAreParsing.RecipeAuthor = attributeDict["RecipeAuthor"]!;
                recipeWeAreParsing.RecipeDate = NSDate();
                recipeWeAreParsing.RecipeDescription = attributeDict["RecipeDescription"]!;
                recipeWeAreParsing.RecipeCategory = attributeDict["RecipeCategory"]!;
                recipeWeAreParsing.Notes = attributeDict["Notes"]!;
                recipeWeAreParsing.PGRatio = Int(attributeDict["PGRatio"]!)!;
                recipeWeAreParsing.VGRatio = Int(attributeDict["VGRatio"]!)!;
                recipeWeAreParsing.maxVG = attributeDict["maxVG"]?.uppercaseString == "TRUE";
                if (recipeWeAreParsing.ID == "")
                {
                    // missing ID so we need to generate one
                    recipeWeAreParsing.ID = NSUUID().UUIDString;
                    hadToAddRecipeIDs = true;
                }
            }
            if (elementName == "RecipeIngredient")
            {
                let ingredientToAddToRecipe = RecipeIngredient();
                ingredientToAddToRecipe.Notes = attributeDict["Notes"]!;
                ingredientToAddToRecipe.Percentage = Double(attributeDict["Percentage"]!)!;
                ingredientToAddToRecipe.RecipeIngredientID = attributeDict["RecipeIngredientID"]!;
                ingredientToAddToRecipe.Sequence = Int(attributeDict["Sequence"]!)!;
                ingredientToAddToRecipe.Temperature = Double(attributeDict["Temperature"]!)!;
                ingredientToAddToRecipe.TempScale = attributeDict["TempScale"]!;
                //print("finished up ingredient.");
                recipeWeAreParsing.RecipeIngredients.append(ingredientToAddToRecipe);
            }
        }
    }
    
    // need code in didStartElement for recipeIngredients..
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (parser == recipeLibraryParser && elementName == "Recipe")
        {
            print("found end of recipe.  now we should append it.");
            if recipeWeAreParsing.ID != ""
            {
                recipeLibraryFromXML.append(recipeWeAreParsing);
                outletRecipeTableView.reloadData();
            }
        }
    }
    
    func WriteRecipeLibraryToFile()
    {
        let xmlRoot = NSXMLElement(name: "RecipeLibrary");
        let xmlDoc = NSXMLDocument(rootElement: xmlRoot);
        
        print ("reeive Write recipe calll....");
        for recipe in recipeLibrary
        {
            let recipeElement = NSXMLElement(name: "Recipe");
            xmlRoot.addChild(recipeElement);
            let IDAttribute = NSXMLNode.attributeWithName("ID", stringValue: recipe.ID) as! NSXMLNode;
            let MaxVGAttribute = NSXMLNode.attributeWithName("maxVG", stringValue: String(recipe.maxVG)) as! NSXMLNode;
            let NotesAttribute = NSXMLNode.attributeWithName("Notes", stringValue: recipe.Notes) as! NSXMLNode;
            let PGRatioAttribute = NSXMLNode.attributeWithName("PGRatio", stringValue: String(recipe.PGRatio)) as! NSXMLNode;
            let RecipeAuthorAttribute = NSXMLNode.attributeWithName("RecipeAuthor", stringValue: recipe.RecipeAuthor) as! NSXMLNode;
            let RecipeCategoryAttribute = NSXMLNode.attributeWithName("RecipeCategory", stringValue: recipe.RecipeCategory) as! NSXMLNode;
            let RecipeDateAttribute = NSXMLNode.attributeWithName("RecipeDate", stringValue: String(recipe.RecipeDate)) as! NSXMLNode;
            let RecipeDescriptionAttribute = NSXMLNode.attributeWithName("RecipeDescription", stringValue: String(recipe.RecipeDescription)) as! NSXMLNode;
            let RecipeNameAttribute = NSXMLNode.attributeWithName("RecipeName", stringValue: recipe.RecipeName) as! NSXMLNode;
            let VGRatioAttribute = NSXMLNode.attributeWithName("VGRatio", stringValue: String(recipe.VGRatio)) as! NSXMLNode;

            recipeElement.addAttribute(IDAttribute);
            recipeElement.addAttribute(MaxVGAttribute);
            recipeElement.addAttribute(NotesAttribute);
            recipeElement.addAttribute(PGRatioAttribute);
            recipeElement.addAttribute(RecipeAuthorAttribute);
            recipeElement.addAttribute(RecipeCategoryAttribute);
            recipeElement.addAttribute(RecipeDateAttribute);
            recipeElement.addAttribute(RecipeDescriptionAttribute);
            recipeElement.addAttribute(RecipeNameAttribute);
            recipeElement.addAttribute(VGRatioAttribute);
            // now add each ingredient..
            for ing in recipe.RecipeIngredients
            {
                let recipeIngredientElement = NSXMLElement(name: "RecipeIngredient");
                recipeElement.addChild(recipeIngredientElement);
                let IDAttribute = NSXMLNode.attributeWithName("RecipeIngredientID", stringValue: ing.RecipeIngredientID) as! NSXMLNode;
                let NotesAttribute = NSXMLNode.attributeWithName("Notes", stringValue: ing.Notes) as! NSXMLNode;
                let PercentageAttribute = NSXMLNode.attributeWithName("Percentage", stringValue: String(ing.Percentage)) as! NSXMLNode;
                let SequenceAttribute = NSXMLNode.attributeWithName("Sequence", stringValue: String(ing.Sequence)) as! NSXMLNode;
                let TemperatureAttribute = NSXMLNode.attributeWithName("Temperature", stringValue: String(ing.Temperature)) as! NSXMLNode;
                let TempScaleAttribute = NSXMLNode.attributeWithName("TempScale", stringValue: ing.TempScale) as! NSXMLNode;
                recipeIngredientElement.addAttribute(IDAttribute);
                recipeIngredientElement.addAttribute(NotesAttribute);
                recipeIngredientElement.addAttribute(PercentageAttribute);
                recipeIngredientElement.addAttribute(SequenceAttribute);
                recipeIngredientElement.addAttribute(TemperatureAttribute);
                recipeIngredientElement.addAttribute(TempScaleAttribute);
            }
        }
        print("XML Data for Ingredients that we need to add:");
        let path = NSBundle.mainBundle().pathForResource("RecipeLibrary", ofType: "xml");
        if (path != nil)
        {
            do
            {
                print ("path is " + path!);
                try xmlDoc.XMLData.writeToFile(path!, options: NSDataWritingOptions.DataWritingAtomic)
                print("wrote XML file!");
            }
            catch
            {
                print("error writing file.");
            }
        }
        print("finished XML work...");
        
    }
    
    func WriteIngredientLibraryToFile()
    {
        let xmlRoot = NSXMLElement(name: "IngredientLibrary");
        let xmlDoc = NSXMLDocument(rootElement: xmlRoot);
        for ing in ingredientLibrary
        {
            let ingredientElement = NSXMLElement(name: "IngredientLibraryIngredient");
            xmlRoot.addChild(ingredientElement);
            let IDAttribute = NSXMLNode.attributeWithName("ID", stringValue: ing.ID) as! NSXMLNode;
            let NameAttribute = NSXMLNode.attributeWithName("Name", stringValue: ing.Name) as! NSXMLNode;
            let ManufacturerAttribute = NSXMLNode.attributeWithName("Manufacturer", stringValue: ing.Manufacturer) as! NSXMLNode;
            let TypeAttribute = NSXMLNode.attributeWithName("Type", stringValue: ing.Type) as! NSXMLNode;
            let BaseAttribute = NSXMLNode.attributeWithName("Base", stringValue: ing.Base) as! NSXMLNode;
            let GravityAttribute = NSXMLNode.attributeWithName("Gravity", stringValue: String(ing.Gravity)) as! NSXMLNode;
            let CostAttribute = NSXMLNode.attributeWithName("Cost", stringValue: String(ing.Cost)) as! NSXMLNode;
            let StrengthAttribute = NSXMLNode.attributeWithName("Strength", stringValue: String(ing.Strength)) as! NSXMLNode;
            let NotesAttribute = NSXMLNode.attributeWithName("Notes", stringValue: ing.Notes) as! NSXMLNode;
            let VGRatioForIngredientAttribute = NSXMLNode.attributeWithName("VGRatioForIngredient", stringValue: String(ing.VGRatioForIngredient)) as! NSXMLNode;
            let PGRatioForIngredientAttribute = NSXMLNode.attributeWithName("PGRatioForIngredient", stringValue: String(ing.PGRatioForIngredient)) as! NSXMLNode;

            ingredientElement.addAttribute(IDAttribute);
            ingredientElement.addAttribute(NameAttribute);
            ingredientElement.addAttribute(ManufacturerAttribute);
            ingredientElement.addAttribute(TypeAttribute);
            ingredientElement.addAttribute(BaseAttribute);
            ingredientElement.addAttribute(GravityAttribute);
            ingredientElement.addAttribute(CostAttribute);
            ingredientElement.addAttribute(StrengthAttribute);
            ingredientElement.addAttribute(NotesAttribute);
            ingredientElement.addAttribute(VGRatioForIngredientAttribute);
            ingredientElement.addAttribute(PGRatioForIngredientAttribute);
            
        }
        print("XML Data for Ingredients that we need to add:");
        let path = NSBundle.mainBundle().pathForResource("IngredientLibrary", ofType: "xml");
        if (path != nil)
        {
            do
            {
                try xmlDoc.XMLData.writeToFile(path!, options: NSDataWritingOptions.DataWritingAtomic)
                //try xmlDoc.XMLString.writeToFile(path!, atomically: false, encoding: NSUTF8StringEncoding);
                print("wrote XML file!");
            }
            catch
            {
                print("error writing file.");
            }
        }
        print("finished XML work...");
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if (parser == ingredientLibraryParser)
        {
            print("finished parsing ingredient XML file");
            print(ingredientLibraryFromXML.count);
            print("ingredients in the dictionary.");
            ingredientLibrary = ingredientLibraryFromXML;
            // now let's sort the ingredients...
            ingredientLibrary.sortInPlace({$0.Name < $1.Name});
            outletIngredientLibraryTableView.reloadData();
            if (hadToAddIDs)
            {
                print("we need to write the XML file back out now -- we had to add IDs");
                WriteIngredientLibraryToFile();
                print("wrote XML!");
            }
        }
        if (parser == recipeLibraryParser)
        {
            print("finished parsing recipe XML file");
            print(recipeLibraryFromXML.count);
            print("recipes in the dictionary.");
            recipeLibrary = recipeLibraryFromXML;
            print ("yay");
            outletRecipeTableView.reloadData();
            if (hadToAddRecipeIDs)
            {
                print("we need to write the XML file back out now -- we had to add IDs");
                WriteRecipeLibraryToFile();
                print("wrote XML!");
            }

//            outletRecipeList
        }
    }
    
    func LoadIngredientsFromXML()
    {
        //        parser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path!))
        //     let path = NSBundle.mainBundle().pathForResource("MyFile", ofType: "xml")
        let path = NSBundle.mainBundle().pathForResource("IngredientLibrary", ofType: "xml");
        if path != nil
        {
            ingredientLibraryParser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path!))!;
            print("loaded file...");
            ingredientLibraryParser.delegate = self;
            ingredientLibraryParser.parse();
        }
    }
    
    func LoadRecipesFromXML()
    {
        let path = NSBundle.mainBundle().pathForResource("RecipeLibrary", ofType: "xml");
        if path != nil
        {
            recipeLibraryParser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path!))!;
            print("loaded recipe file...");
            recipeLibraryParser.delegate = self;
            recipeLibraryParser.parse();
        }
        
    }
    func windowShouldClose(sender: AnyObject) -> Bool {
        print ("window closing, save XML!");
        WriteIngredientLibraryToFile();
        WriteRecipeLibraryToFile();
        print("wrote XML...");
        return true;
    }

    /* End XML Parsing Functionality */
}

