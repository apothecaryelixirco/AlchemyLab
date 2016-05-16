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
    var desiredNicStrength : Double = 0;
    var amountOfJuice : Int = 0;
    static var sharedInstance : ViewController?;
    // outlets
    
    @IBOutlet weak var outletRecipeList: NSOutlineView!
    @IBOutlet weak var outletIngredientList: NSOutlineView!
    
    //@IBOutlet var outletRecipe: NSArrayController!
    
   // @IBOutlet var outletMixLab: NSArrayController!
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
    
    var ingredientToEdit : RecipeIngredient = RecipeIngredient();

    func IngredientEditorDelegate(controller: IngredientLibraryIngredientEditorViewController, ingredient: Ingredient, mode: String) {
        if (mode == "ADD")
        {
            ingredientLibrary.append(ingredient);
            print ("add ingredient to library.");
        }
        if (mode == "EDIT")
        {
            print ("edit ingredient from library.");
        }
    }
    func RecipeViewDelegate(controller: RecipeEditorViewController, recipe: Recipe, mode: String) {
        if (mode == "ADD")
        {
            // we have received a recipe, now we need to add it to our view.
            recipes.append(recipe);
            outletRecipeList.reloadData();
        }
        print("received recipe from recipe view controller.");
    }
    
    @IBAction func outletRecipeTableViewRowSelectedHandler(sender: NSTableView) {
        print("a recipe row has been selected!");
     //   ingredientToEdit = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
    //    showEditPopOverFromTableRow(sender);
        
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
        showEditPopOverFromTableRow(sender);
    }
    
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

    @IBAction func showIngredientLibraryEditorPopupAsEdit(sender: NSSegmentedControl)
    {
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let ingredientLibraryWindowController = storyboard.instantiateControllerWithIdentifier("Ingredient Library Editor View Controller") as! NSWindowController
        
        if let ingredientLibraryWindow = ingredientLibraryWindowController.window {
            
            print("calling display as popover for ingredient library editor.");
            let ingredientLibraryEditorViewController = ingredientLibraryWindow.contentViewController as! IngredientLibraryIngredientEditorViewController
            ingredientLibraryEditorViewController.mode = "EDIT";
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
    
    @IBAction func showEditPopOver(sender: NSSegmentedControl)
    {
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            print("calling display as popover.");
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.mode = "EDIT";
            addIngredientViewController.incomingRecipe = currentRecipe;
            addIngredientViewController.ingredientToEdit = ingredientToEdit;
            let rectForPopup = outletRecipeTableView.bounds;
            let viewForPopup = outletRecipeTableView;
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
    
    
    @IBAction func showEditPopOverFromTableRow(sender: NSTableView)
    {
        ingredientToEdit = currentRecipe.RecipeIngredients[sender.clickedRow];
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addIngredientWindowController = storyboard.instantiateControllerWithIdentifier("Add Ingredient View Controller") as! NSWindowController
        
        if let addIngredientWindow = addIngredientWindowController.window {
            
            print("calling display as popover.");
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

    
    @IBAction func ShowRecipeAdditionPopOver(sender: NSSegmentedControl)
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let recipeEditorWindowController = storyboard.instantiateControllerWithIdentifier("Recipe Editor View Controller") as! NSWindowController
        if let recipeEditorWindow = recipeEditorWindowController.window {
            print("calling display as popover for recipe addition.");
            let recipeEditorViewController = recipeEditorWindow.contentViewController as! RecipeEditorViewController
            recipeEditorViewController.mode = "ADD";
            presentViewController(recipeEditorViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinY, behavior: NSPopoverBehavior.Transient)
            print("done with the modal view.");
        }
    }

    
    
    @IBAction func ShowRecipeEditorPopOver(sender: NSSegmentedControl)
    {
        //Recipe Editor View Controller
        // 1
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let recipeEditorWindowController = storyboard.instantiateControllerWithIdentifier("Recipe Editor View Controller") as! NSWindowController
        if let recipeEditorWindow = recipeEditorWindowController.window {
            
            print("calling display as popover for recipe EDITING.");
            let recipeEditorViewController = recipeEditorWindow.contentViewController as! RecipeEditorViewController
            recipeEditorViewController.mode = "EDIT";
            recipeEditorViewController.workingRecipe = currentRecipe;
            presentViewController(recipeEditorViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinY, behavior: NSPopoverBehavior.Transient)
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
            
            print("calling display as popover.");
            let addIngredientViewController = addIngredientWindow.contentViewController as! AddIngredientViewController
            addIngredientViewController.ingredientLibrary = ingredientLibrary;
            addIngredientViewController.incomingRecipe = currentRecipe;
            addIngredientViewController.mode = "ADD";
            
            presentViewController(addIngredientViewController, asPopoverRelativeToRect: sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinX, behavior: NSPopoverBehavior.Transient)
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
            showEditPopOver(sender);
        }
    }
    
    func RemoveSelectedRecipeIngredient()
    {
        print("removing selected recipe ingredient..");
       // let ingredientToRemove = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
        
        //print("removing " + ingredientToRemove.RecipeIngredient.Name);
        let selectIndex = outletRecipeTableView.selectedRow;
        currentRecipe.RecipeIngredients.removeAtIndex(outletRecipeTableView.selectedRow);
//        outletRecipeTableView.reloadData();
        UpdateRecipeView();
        UpdateMixLabView();
        UpdateUIControls();
        let indexSet = NSIndexSet(index: selectIndex);
        outletRecipeTableView.selectRowIndexes(indexSet,byExtendingSelection: false);
    }
    
    @IBAction func outletNicStrengthTextFieldAction(sender: NSTextField) {
        let string = outletNicStrengthTextField.stringValue;
        let numericSet = "0123456789"
        let filteredCharacters = string.characters.filter {
            return numericSet.containsString(String($0))
        }
        var filteredString = String(filteredCharacters) // -> 347
        if (filteredString == "") { filteredString = "0"; }
        desiredNicStrength = Double(filteredString)!;
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
        UpdateUIControls();
        UpdateMixLabView();
        
    }
    
    @IBAction func outletIngredientLibraryItemDoubleClick(sender: NSTableView) {
        print("double cilcked item.  edit ingredient.");
    }
    
    // Ingredient Library Button Cick Handler
    @IBAction func outletIngredientLibrarySegmentButton(sender: NSSegmentedControl) {
        if (sender.selectedSegment == 0)
        {
            print("add ingredient.");
            showIngredientLibraryEditorPopupAsAdd(sender);
        }
        if (sender.selectedSegment == 1)
        {
            print("delete ingredient");
        }
        if (sender.selectedSegment == 2)
        {
            showIngredientLibraryEditorPopupAsEdit(sender);
        }
    }
    
   /*
    @IBAction func outletPGRatioHandler(sender: NSSlider) {
        PGRatio = sender.integerValue;
        VGRatio = 100-PGRatio;
        UpdateUIControls();
        UpdateMixLabView();
    }*/
    /*
    
    @IBAction func outletVGRatioSliderHandler(sender: NSSlider) {
        VGRatio = sender.integerValue;
        PGRatio = 100-VGRatio;
        UpdateUIControls();
        UpdateMixLabView();

    }*/
    
    @IBAction func outletNicStrengthSliderHandler(sender: NSSlider) {
        desiredNicStrength = Double(sender.integerValue);
        UpdateUIControls();
        UpdateMixLabView();
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
        }
        if (sender.selectedSegment == 2)
        {
            ShowRecipeEditorPopOver(sender);
            print ("edit recipe");
        }
    }
    
    // end outlets;
    
    @IBOutlet var outletIngredientLibraryArrayController: NSArrayController!
    
    dynamic var ingredientLibrary = LoadPlaceHolderIngredients();
    dynamic var recipes = [Recipe()];
    // these are the two data values for the Tables.
    dynamic var recipeDisplay = [RecipeDisplay]();
    dynamic var mixLab = [mixLabDisplay]();
    
    var currentRecipe = Recipe();
    
    @IBOutlet weak var outletIngredientLibraryTableView: NSTableView!
    override func viewDidLoad() {
        // defaults for recipe.
        PGRatio = 30;
        VGRatio = 70;
        amountOfJuice = 50;
        desiredNicStrength = 6;
        //recipes = LoadDefaultRecipe(ingredientLibrary);
        
        currentRecipe = recipes[0];
        // let's get our sliders and UI all setup...
        UpdateUIControls();
        UpdateRecipeView();
        UpdateMixLabView();
        ViewController.sharedInstance = self;
        print("reloading recipe list on the left...");
        outletRecipeTableView.reloadData();
        print("now attempting to run XML parser...");
        LoadIngredientsFromXML();
        LoadRecipesFromXML();
        
        //TODO: Long term implement drag and drop...?
        //TODO: 
        //var registeredTypes:[String] = [NSStringPboardType]
       // outletRecipeTableView.registerForDraggedTypes(registeredTypes);
       // outletIngredientLibraryTableView.registerForDraggedTypes(registeredTypes);
//        outletRecipeTableView.registerForDraggedTypes(<#T##newTypes: [String]##[String]#>)
//        outletRecipeTableView.registerForDraggedTypes(<#T##newTypes: [String]##[String]#>) -- Drag and drop functionality
        // http://www.knowstack.com/swift-nstableview-drag-drop-in/
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self;
        super.viewDidAppear();
    }

    func UpdateUIControls()
    {
        //outletPGRatioSlider.integerValue = PGRatio;
        //outletVGRatioSlider.integerValue = VGRatio;
        outletPGRatioTextField.integerValue = PGRatio;
        outletVGRatioTextField.integerValue = VGRatio;
        //outletNicStrengthSlider.doubleValue = desiredNicStrength;
        outletNicStrengthTextField.doubleValue = desiredNicStrength;
        //outletAmountLabel.stringValue = String(format:"Target e-liquid Amount: %dml",amountOfJuice);
        outletAmountComboBox.stringValue = String(format:"%dml",amountOfJuice);
        outletRecipeTableView.reloadData();

    }
    func UpdateRecipeView()
    {
        let recipe : Recipe = currentRecipe;
        recipeDisplay.removeAll();
        // go through the current recipe and read it all up to display!
        for ingredient in recipe.RecipeIngredients
        {
            let ingredientFromLibrary = getIngredientByUUID(ingredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary)
            let rlDisplay = RecipeDisplay();
            rlDisplay.Base = (ingredientFromLibrary?.Base)!;
            rlDisplay.Ingredient = (ingredientFromLibrary?.Name)!;
            rlDisplay.Percentage = String(format:"%2.2f%%",ingredient.Percentage);
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
            recipeDisplay.append(rlDisplay);
        }
        
        
        //        outletRecipeTableView.reloadData();
    }
    
    
    func UpdateMixLabView()
    {
        let recipe : Recipe = currentRecipe;
        print("received a recipe for " + recipe.RecipeName);
        mixLab.removeAll();
        // need to loop through the currently Displayed Recipe and do all of our math based on that. NOT the currentRecipe because that may not have been updated for some reason.
        // first let's determine how much juice we're making.
        
        var nicSolutionNeeded : Double = 0.00;
        var totalVGNeeded : Double = (Double(amountOfJuice)-(Double(amountOfJuice) * (Double(PGRatio) / 100)));
        var totalPGNeeded : Double = (Double(amountOfJuice)-(Double(amountOfJuice) * (Double(VGRatio) / 100)));
        // first let's determine how much VG/PG we need as a total...based on our ratio.
        var PGWeight : Double = 0.0;
        var VGWeight : Double = 0.0;
        var nicBase : String = "";
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
        for nicotine in recipeDisplay
        {
            let ingredientFromLibrary = getIngredientByUUID(nicotine.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (ingredientFromLibrary?.Type.uppercaseString == "NICOTINE")
            {
                nicotineIngredientId = nicotine.backgroundIngredient.RecipeIngredientID;
                nicotineDisplayString = nicotine.Ingredient;
                break;
            }
        }
        if (nicotineIngredientId != "")
        {
            print("determining how much nicotine solution we need...");
            // find our nicotine and determine how much nic we need for our solution..
            let nicotine = getIngredientByUUID(nicotineIngredientId, ingredientLibrary: ingredientLibrary)
            var baseWeight : Double = 0.0;
            var nicBaseWeight = Double(desiredNicStrength) * nicotine!.Gravity;
            if (nicotine!.Base.uppercaseString == "PG")
            {
                baseWeight = PGWeight;
                nicBase = "PG";
            }
            if (nicotine!.Base.uppercaseString == "VG")
            {
                baseWeight = VGWeight;
                nicBase = "VG";
            }
            let nicStrength : Double = nicotine!.Strength / 10;
            nicBaseWeight += Double((100-nicStrength)) * baseWeight;
            nicBaseWeight = nicBaseWeight / 100;
            nicSolutionNeeded = (Double(desiredNicStrength) * Double(amountOfJuice)) / 100;
            // at this point we know all about our nicotine so we should be able to add it to the mixlab display.
            let mlDisplay = mixLabDisplay();
            mlDisplay.Ingredient = nicotineDisplayString;
            mlDisplay.Volume = String(format:"%.2fml",nicSolutionNeeded);
            mlDisplay.backgroundVolume = nicSolutionNeeded;
            mlDisplay.Weight = String(format:"%.2fg",nicBaseWeight);
            mlDisplay.backgroundWeight = nicBaseWeight;
            mlDisplay.backgroundCost = (nicSolutionNeeded * nicotine!.Cost);
            mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
            mixLab.append(mlDisplay);

        }
        
        // determine how much nicotine solution we need first.
        
        // Nicotine has been sorted out.  Now we need to sort out how much of our flavorings we need.
        for flavor in recipeDisplay
        {
            let flavorIngredient = getIngredientByUUID(flavor.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (flavorIngredient!.Type.uppercaseString == "FLAVOR")
            {
                let mlDisplay = mixLabDisplay();
                // first determine how much of this flavor we need..
                let volumeOfFlavorNeeded = (flavor.backgroundPercentage * Double(amountOfJuice)) / 100;
                if (flavor.Base.uppercaseString == "PG")
                {
                    totalPGNeeded -= volumeOfFlavorNeeded;
                }
                if (flavor.Base.uppercaseString == "VG")
                {
                    totalVGNeeded -= volumeOfFlavorNeeded;
                }
                mlDisplay.Ingredient = flavor.Ingredient;
                mlDisplay.backgroundWeight = (volumeOfFlavorNeeded * flavorIngredient!.Gravity);
                mlDisplay.backgroundVolume = volumeOfFlavorNeeded;
                mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
                mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
                mlDisplay.backgroundCost = flavorIngredient!.Cost;
                mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
                mixLab.append(mlDisplay);
            }
        }
        
        
        // now we need to determine our VG/PG amounts.
        for vg in recipeDisplay
        {
            let vgIngredient = getIngredientByUUID(vg.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (vgIngredient!.Type.uppercaseString == "VG")
            {
                if (nicBase == "VG")
                {
                    totalVGNeeded -= nicSolutionNeeded;
                }
                let mlDisplay = mixLabDisplay();
                mlDisplay.Ingredient = vg.Ingredient;
                mlDisplay.backgroundVolume = totalVGNeeded;
                mlDisplay.backgroundWeight = (mlDisplay.backgroundVolume * vgIngredient!.Gravity);
                mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
                mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
                mlDisplay.backgroundCost = (mlDisplay.backgroundVolume * vgIngredient!.Cost);
                mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
                mixLab.append(mlDisplay);
            }
        }
        
        for pg in recipeDisplay
        {
            let pgIngredient = getIngredientByUUID(pg.backgroundIngredient.RecipeIngredientID, ingredientLibrary: ingredientLibrary);
            if (pgIngredient!.Type.uppercaseString == "PG")
            {
                if (nicBase == "PG")
                {
                    totalPGNeeded -= nicSolutionNeeded;
                }
                let mlDisplay = mixLabDisplay();
                mlDisplay.Ingredient = pg.Ingredient;
                mlDisplay.backgroundVolume = totalPGNeeded;
                mlDisplay.backgroundWeight = (mlDisplay.backgroundVolume * pgIngredient!.Gravity);
                mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
                mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
                mlDisplay.backgroundCost = (mlDisplay.backgroundVolume * pgIngredient!.Cost);
                mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
                mixLab.append(mlDisplay);
            }
            
        }

        for ingredient in recipeDisplay
        {
            let mlDisplay = mixLabDisplay();
//            ingredient.backgroundIngredient.RecipeIngredient.Type
            mlDisplay.Ingredient = ingredient.Ingredient;
            // now let's figure out how much of this ingredient we need...
        }
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
        for mixlabingredient in mixLab
        {
            totalVolume += mixlabingredient.backgroundVolume;
            totalWeight += mixlabingredient.backgroundWeight;
            totalCost += mixlabingredient.backgroundCost;
        }
        
        let mlDisplay = mixLabDisplay();
        mlDisplay.Ingredient = "TOTALS";
        mlDisplay.Volume = String(format: "%.2fml",totalVolume);
        mlDisplay.Weight = String(format: "%.2fg",totalWeight);
        mlDisplay.Cost = String(format: "$%.2f",totalCost);
        mixLab.append(mlDisplay);
        
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func outlineViewSelectionDidChange(notification: NSNotification) {
        print(notification);
        
        let selectedIndex = notification.object?.selectedRow
        let object:AnyObject? = notification.object?.itemAtRow(selectedIndex!)
        
        if object is Recipe
        {
            let recipe = object as! Recipe;
            print("Need to update the recipe and mixlab view for " + recipe.RecipeName);
            currentRecipe = recipe;
            if (currentRecipe.PGRatio + currentRecipe.VGRatio != 100)
            {
                // TODO: Remove when supporting Max VG.
                PGRatio=30;
                VGRatio=70;
                currentRecipe.PGRatio = 30;
                currentRecipe.VGRatio = 70;
            }
            UpdateUIControls();
            UpdateRecipeView();
            UpdateMixLabView();
        }
        
        // here's where we need to set up the new recipe/mixLab
        
    }
    
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (outlineView.tag == 1) // this means we're in the recipe source list.
        {
            print("Calling delegate for index..");
            print(index);
            if (recipes.count > index) {
                return recipes[index];
            }
        }
        return self;
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if (outlineView.tag == 1) // this means we're in the recipe source list.
        {
        print(2);
            return false;
        }
        return false;
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if (outlineView.tag == 1) // this means we're in the recipe source list.
        {
            print("I believe this is our constructor for the list...first call.");
            // here is where we should add our groups first, right?
            if (item == nil)
            {
                return recipes.count
            }
            return 0
        }
        return 0;
    }
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if (outlineView.tag == 1) // this means we're in the recipe source list..
        {
            print(4);
            //        return "ITEM"
            return item as! Recipe;
        }
        return nil;
    }
    
    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
        if (outlineView.tag == 1)
        {
            print(5);
            print(object, tableColumn, recipes)
        }
    }
    
    func outlineView(outlineView: NSOutlineView,
                     viewForTableColumn tableColumn: NSTableColumn?,
                                        item: AnyObject) -> NSView? {
        if (outlineView.tag == 1)
        {
            print("Delegate called!");
            
            let r = item as! Recipe;
            let v = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView;
            v.textField?.stringValue = r.RecipeName;
            v.imageView!.image = NSImage(named: NSImageNameQuickLookTemplate);
            return v;
        }
        return nil;
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
        for recipe in recipes
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
            let NotesAttribute = NSXMLNode.attributeWithName("Notes", stringValue: ing.Name) as! NSXMLNode;
            ingredientElement.addAttribute(IDAttribute);
            ingredientElement.addAttribute(NameAttribute);
            ingredientElement.addAttribute(ManufacturerAttribute);
            ingredientElement.addAttribute(TypeAttribute);
            ingredientElement.addAttribute(BaseAttribute);
            ingredientElement.addAttribute(GravityAttribute);
            ingredientElement.addAttribute(CostAttribute);
            ingredientElement.addAttribute(StrengthAttribute);
            ingredientElement.addAttribute(NotesAttribute);
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
            recipes = recipeLibraryFromXML;
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

