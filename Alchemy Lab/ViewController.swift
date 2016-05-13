//
//  ViewController.swift
//  Alchemy Lab
//
//  Created by Randy Williams on 5/11/16.
//  Copyright © 2016 alchemy Labs. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, AddRecipeIngredientDelegate, RecipeEditorDelegate, NSTableViewDelegate,NSTableViewDataSource, NSApplicationDelegate {

    
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
        let ingredientToRemove = currentRecipe.RecipeIngredients[outletRecipeTableView.selectedRow];
        print("removing " + ingredientToRemove.RecipeIngredient.Name);
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
        recipes = LoadDefaultRecipe(ingredientLibrary);
        
        currentRecipe = recipes[0];
        // let's get our sliders and UI all setup...
        UpdateUIControls();
        UpdateRecipeView();
        UpdateMixLabView();
        ViewController.sharedInstance = self;
        print("reloading recipe list on the left...");
        outletRecipeTableView.reloadData();
        
        
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
            let rlDisplay = RecipeDisplay();
            rlDisplay.Base = ingredient.RecipeIngredient.Base;
            rlDisplay.Ingredient = ingredient.RecipeIngredient.Name;
            rlDisplay.Percentage = String(format:"%2.2f%%",ingredient.Percentage);
            if (ingredient.RecipeIngredient.Type.uppercaseString != "FLAVOR")
            {
                rlDisplay.Percentage = "n/a";
            }
            rlDisplay.Strength = String(format:"%.2fmg/ml",ingredient.RecipeIngredient.Strength);
            if (ingredient.RecipeIngredient.Type.uppercaseString != "NICOTINE")
            {
                rlDisplay.Strength = "n/a";
            }
            rlDisplay.Type = ingredient.RecipeIngredient.Type;
            rlDisplay.backgroundIngredient = ingredient;
            rlDisplay.backgroundStrength = ingredient.RecipeIngredient.Strength;
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
        PGRatio = currentRecipe.PGRatio;
        VGRatio = currentRecipe.VGRatio;
        
        var nicSolutionNeeded : Double = 0.00;
        var totalVGNeeded : Double = (Double(amountOfJuice)-(Double(amountOfJuice) * (Double(PGRatio) / 100)));
        var totalPGNeeded : Double = (Double(amountOfJuice)-(Double(amountOfJuice) * (Double(VGRatio) / 100)));
        // first let's determine how much VG/PG we need as a total...based on our ratio.
        var PGWeight : Double = 0.0;
        var VGWeight : Double = 0.0;
        var nicBase : String = "";
        
        for vg in recipeDisplay where vg.backgroundIngredient.RecipeIngredient.Type.uppercaseString == "VG"
        {
            VGWeight = vg.backgroundIngredient.RecipeIngredient.Gravity;
        }
        for pg in recipeDisplay where pg.backgroundIngredient.RecipeIngredient.Type.uppercaseString == "PG"
        {
            PGWeight = pg.backgroundIngredient.RecipeIngredient.Gravity;
        }
        // now we know how much PG/VG weighs for our specific recipe.
        
        // determine how much nicotine solution we need first.
        for nicotine in recipeDisplay where nicotine.backgroundIngredient.RecipeIngredient.Type.uppercaseString == "NICOTINE"
        {
            // find our nicotine and determine how much nic we need for our solution..
            var baseWeight : Double = 0.0;
            var nicBaseWeight = Double(desiredNicStrength) * nicotine.backgroundIngredient.RecipeIngredient.Gravity;
            if (nicotine.backgroundIngredient.RecipeIngredient.Base.uppercaseString == "PG")
            {
                baseWeight = PGWeight;
                nicBase = "PG";
            }
            if (nicotine.backgroundIngredient.RecipeIngredient.Base.uppercaseString == "VG")
            {
                baseWeight = VGWeight;
                nicBase = "VG";
            }
            let nicStrength : Double = nicotine.backgroundIngredient.RecipeIngredient.Strength / 10;
            nicBaseWeight += Double((100-nicStrength)) * baseWeight;
            nicBaseWeight = nicBaseWeight / 100;
            nicSolutionNeeded = (Double(desiredNicStrength) * Double(amountOfJuice)) / 100;
            // at this point we know all about our nicotine so we should be able to add it to the mixlab display.
            let mlDisplay = mixLabDisplay();
            mlDisplay.Ingredient = nicotine.Ingredient;
            mlDisplay.Volume = String(format:"%.2fml",nicSolutionNeeded);
            mlDisplay.backgroundVolume = nicSolutionNeeded;
            mlDisplay.Weight = String(format:"%.2fg",nicBaseWeight);
            mlDisplay.backgroundWeight = nicBaseWeight;
            mlDisplay.backgroundCost = (nicSolutionNeeded * nicotine.backgroundIngredient.RecipeIngredient.Cost);
            mlDisplay.Cost = String(format:"$%2.2f",(nicSolutionNeeded * nicotine.backgroundIngredient.RecipeIngredient.Cost));
            mixLab.append(mlDisplay);
        }
        
        // Nicotine has been sorted out.  Now we need to sort out how much of our flavorings we need.
        for flavor in recipeDisplay where flavor.backgroundIngredient.RecipeIngredient.Type.uppercaseString == "FLAVOR"
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
            mlDisplay.backgroundWeight = (volumeOfFlavorNeeded * flavor.backgroundIngredient.RecipeIngredient.Gravity);
            mlDisplay.backgroundVolume = volumeOfFlavorNeeded;
            mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
            mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
            mlDisplay.backgroundCost = flavor.backgroundIngredient.RecipeIngredient.Cost;
            mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
            mixLab.append(mlDisplay);
        }
        
        
        // now we need to determine our VG/PG amounts.
        for vg in recipeDisplay where vg.backgroundIngredient.RecipeIngredient.Type.uppercaseString == "VG"
        {
            if (nicBase == "VG")
            {
                totalVGNeeded -= nicSolutionNeeded;
            }
            let mlDisplay = mixLabDisplay();
            mlDisplay.Ingredient = vg.Ingredient;
            mlDisplay.backgroundVolume = totalVGNeeded;
            mlDisplay.backgroundWeight = (mlDisplay.backgroundVolume * vg.backgroundIngredient.RecipeIngredient.Gravity);
            mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
            mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
            mlDisplay.backgroundCost = (mlDisplay.backgroundVolume * vg.backgroundIngredient.RecipeIngredient.Cost);
            mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
            mixLab.append(mlDisplay);
        }

        for pg in recipeDisplay where pg.backgroundIngredient.RecipeIngredient.Type.uppercaseString == "PG"
        {
            if (nicBase == "PG")
            {
                totalPGNeeded -= nicSolutionNeeded;
            }
            let mlDisplay = mixLabDisplay();
            mlDisplay.Ingredient = pg.Ingredient;
            mlDisplay.backgroundVolume = totalPGNeeded;
            mlDisplay.backgroundWeight = (mlDisplay.backgroundVolume * pg.backgroundIngredient.RecipeIngredient.Gravity);
            mlDisplay.Volume = String(format:"%.2fml",mlDisplay.backgroundVolume);
            mlDisplay.Weight = String(format:"%.2fg",mlDisplay.backgroundWeight);
            mlDisplay.backgroundCost = (mlDisplay.backgroundVolume * pg.backgroundIngredient.RecipeIngredient.Cost);
            mlDisplay.Cost = String(format:"$%2.2f",mlDisplay.backgroundCost);
            mixLab.append(mlDisplay);
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
            UpdateRecipeView();
            UpdateMixLabView();
            UpdateUIControls();
        }
        
        // here's where we need to set up the new recipe/mixLab
        
    }
    
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (outlineView.tag == 1) // this means we're in the recipe source list.
        {
            print("Calling delegate for index..");
            print(index);
            return recipes[index];
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
    
    
    /* Drag and Drop Functionality */
    /*
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        var newString:String = ""
        if (tableView == sourceTableView)
        {
            newString = sourceDataArray[row]
        }
        else if (tableView == targetTableView)
        {
            newString = targetDataArray[row]
        }
        return newString;
    }
    */
    
    /*
    // delegate for creating the object to drop in.
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
//        var newIngredient:RecipeIngredient = RecipeIngredient();
        print("creating object value from drag and drop delegate.");
        if (tableView == outletIngredientLibraryTableView)
        {
            print("we have an item from our ingredient library!");
  //          newIngredient.RecipeIngredient = ingredientLibrary[row];
        }
        return "item";
    }
 */
    /*
 func tableView(aTableView: NSTableView,
 writeRowsWithIndexes rowIndexes: NSIndexSet,
 toPasteboard pboard: NSPasteboard) -> Bool
 {
 if ((aTableView == sourceTableView) || (aTableView == targetTableView))
 {
 var data:NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
 var registeredTypes:[String] = [NSStringPboardType]
 pboard.declareTypes(registeredTypes, owner: self)
 pboard.setData(data, forType: NSStringPboardType)
 return true
 
 }
 else
 {
 return false
 }
 }*/
    /*
    // delegate for putting the object we're pulling out into the pasteboard.
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        print ("checking to see if we should put this into the pasteboard.");
        if (tableView == outletIngredientLibraryTableView)
        {
            let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes);
            let registeredTypes:[String] = [NSStringPboardType];
            pboard.declareTypes(registeredTypes, owner: self);
            pboard.setData(data, forType: NSStringPboardType);
            return true;
        }
        return false;
    }*/
    
    
/*func tableView(aTableView: NSTableView,
 validateDrop info: NSDraggingInfo,
 proposedRow row: Int,
 proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation
 {
 if operation == .Above
 {
 return .Move
 }
 return .All
 
 }*/
    /*
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        print("validating drop operation");
        return .Move
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        print("accepting drop!");
        return true;
    }*/
    
    /* final drop operation... */
    /*
 func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool
 {
 var data:NSData = info.draggingPasteboard().dataForType(NSStringPboardType)!
 var rowIndexes:NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSIndexSet
 
 if ((info.draggingSource() as NSTableView == targetTableView) && (tableView == targetTableView))
 {
 var value:String = targetDataArray[rowIndexes.firstIndex]
 targetDataArray.removeAtIndex(rowIndexes.firstIndex)
 if (row > targetDataArray.count)
 {
 targetDataArray.insert(value, atIndex: row-1)
 }
 else
 {
 targetDataArray.insert(value, atIndex: row)
 }
 targetTableView.reloadData()
 return true
 }
 else if ((info.draggingSource() as NSTableView == sourceTableView) && (tableView == targetTableView))
 {
 var value:String = sourceDataArray[rowIndexes.firstIndex]
 sourceDataArray.removeAtIndex(rowIndexes.firstIndex)
 targetDataArray.append(value)
 sourceTableView.reloadData()
 targetTableView.reloadData()
 return true
 }
 else
 {
 return false
 }
 }*/
 
 
 
 
    /* End Drag and Drop Functionality */

}

