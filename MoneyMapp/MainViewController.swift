//
//  MainViewController.swift
//  MoneyMapp
//
//  Created by Tung Ly on 6/2/16.
//  Copyright © 2016 Tung Ly. All rights reserved.
//

import UIKit
import CoreData

let kFIRSTRUN = "firstRun"
let kDATEFORMAT = "dateFormat"
let kDATEFORMATSTRING = "dateFormatString"
let kCURRENCY = "currency"
let kCURRENCYSTRING = "currencyString"

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var sortSegmentController: UISegmentedControl!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var monthNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = (UIApplication .sharedApplication().delegate as! AppDelegate)
    var fetchResultController:NSFetchedResultsController = NSFetchedResultsController()
    var calendar: NSCalendar?
    
    var expenses: [Expense] = []
    
    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?
    
    var thisYear: Int?
    var firstRun: Bool?
    
    var currency = ""
    var dateFormat = ""
    
    let red = UIColor(red: 204/255, green: 24/255, blue: 48/255, alpha: 1.0)
    let green = UIColor(red: 51/255, green: 161/255, blue: 21/255, alpha: 1.0)
    let black = UIColor.blackColor()
    
    override func viewWillAppear(animated: Bool) {
        firstRunCheck()
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstRunCheck()
        calendar = NSCalendar.currentCalendar()
        calendar?.firstWeekday = 2
        setupCarrentDate()
        
        sortSegmentController.selectedSegmentIndex = 1
        
        updateFetch()
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchResultController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections![section].numberOfObjects
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ExpenseTableViewCell
        let expense = fetchResultController.objectAtIndexPath(indexPath) as! Expense
        
        cell.nameLabel.text = expense.name
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.amountLabel.text = String(format: "\(currency)%.2f", Double(expense.amount!))
        cell.amountLabel.adjustsFontSizeToFitWidth = true
        if expense.isExpense!.boolValue {
            cell.amountLabel.textColor = red
        } else {
            cell.amountLabel.textColor = green
        }
        return cell
    }
    
    //MARK: TableviewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 28.0))
        headerView.backgroundColor = UIColor.whiteColor()
        
        let lineView = UIView(frame: CGRectMake(0, 28, tableView.frame.width, 0.5))
        
        lineView.backgroundColor = black
        
        let dateLabel = UILabel(frame: CGRectMake(10, 0, tableView.frame.width - 10, 27.0))
        
        headerView.addSubview(dateLabel)
        headerView.addSubview(lineView)
        
        
        //get the expense
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let expense = fetchResultController.objectAtIndexPath(indexPath) as! Expense
        
        //format the day
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, \(dateFormat)"
        let date = dateFormatter.stringFromDate(expense.date!)
        
        dateLabel.text = date
        dateLabel.font = UIFont(name: "Helvetica-Light", size: 15.0)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height))
        footerView.backgroundColor = UIColor.clearColor()
        
        return footerView
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let expense = fetchResultController.objectAtIndexPath(indexPath) as! Expense
        
        appDelegate.managedObjectContext.deleteObject(expense)
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        updateUI()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: IBActions
    
    @IBAction func sortSegment(sender: UISegmentedControl) {
        setupCarrentDate()
        updateFetch()
        updateUI()
    }
    
    
    @IBAction func addBarButonItemPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("mainToAddSeg", sender: self)
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        sortSegmentController.selectedSegmentIndex = 1
        if currentMonth == 12 {
            currentMonth = 1
            currentYear!++
        } else {
            currentMonth!++
        }
        updateFetch()
        updateUI()
    }
    
    @IBAction func previousButtonPressed(sender: UIButton) {
        sortSegmentController.selectedSegmentIndex = 1
        if currentMonth == 1 {
            currentMonth = 12
            currentYear!--
        } else {
            currentMonth!--
        }
        updateFetch()
        updateUI()
    }
    
    //MARK: Helper Methods
    
    private func updateFetch() {
        fetchResultController = getFetchResultsController()
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        } catch _ {
        }
    }
    
    private func updateUI() {
        if currentYear == thisYear {
            monthNameLabel.text = nameOfTheMonthFromMonthNumber(currentMonth!)
        } else {
            monthNameLabel.text = "\(nameOfTheMonthFromMonthNumber(currentMonth!)), \(currentYear!)"
        }
        expenseFetchRequest()
        //get expense from expenses and calculate expenses/incomes/total
        var incomeAmount = 0.0
        var expenseAmount = 0.0
        var totalAmount = 0.0
        
        for expense in expenses {
            //check if its expense or income and add accordingly
            if expense.isExpense!.boolValue {
                expenseAmount += Double(expense.amount!)
            } else {
                incomeAmount += Double(expense.amount!)
            }
        }
        
        
        totalAmount = incomeAmount - expenseAmount
        
        expenseLabel.text = String(format: "\(currency)%.2f", expenseAmount)
        expenseLabel.adjustsFontSizeToFitWidth = true
        expenseLabel.textColor = red
        incomeLabel.text = String(format: "\(currency)%.2f", incomeAmount)
        incomeLabel.adjustsFontSizeToFitWidth = true
        incomeLabel.textColor = green
        totalLabel.text = String(format: "\(currency)%.2f",totalAmount)
        totalLabel.adjustsFontSizeToFitWidth = true
        
        if totalAmount < -0.01 {
            totalLabel.textColor = red
        } else {
            totalLabel.textColor = green
        }
        
        tableView.reloadData()
    }
    
    private func nameOfTheMonthFromMonthNumber (monthNumber: Int) -> String {
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        
        return monthNames[monthNumber - 1]
    }
    
    private func setupCarrentDate() {
        currentMonth = calendarComponents().month
        currentWeek = calendarComponents().weekOfYear
        currentYear = calendarComponents().year
    }
    
    func calendarComponents () -> NSDateComponents {
        let components = calendar!.components([NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: NSDate())
        thisYear = components.year
        return components
    }
    
    func expenseFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Expense")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        //update segment
        switch sortSegmentController.selectedSegmentIndex {
        case 0:
            fetchRequest.predicate = NSPredicate(format: "weekOfTheYear = %i", currentWeek!)
        case 1:
            fetchRequest.predicate = NSPredicate(format: "year = %i && monthOfTheYear = %i", currentYear!, currentMonth!)
        default:
            fetchRequest.predicate = NSPredicate(format: "year = %i", currentYear!)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        expenses = (try! self.appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)) as! [Expense]
        
        return fetchRequest
    }
    
    
    func getFetchResultsController () -> NSFetchedResultsController{
        
        fetchResultController = NSFetchedResultsController(fetchRequest: self.expenseFetchRequest(), managedObjectContext: self.appDelegate.managedObjectContext, sectionNameKeyPath: "dateString", cacheName: nil)
        
        return fetchResultController
    }
    
    private func firstRunCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        firstRun = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstRun! {
            print("first time", terminator: "")
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setObject("$", forKey: kCURRENCY)
            userDefaults.setObject("USD, $", forKey: kCURRENCYSTRING)
            userDefaults.setObject("MMMM dd yyyy", forKey: kDATEFORMAT)
            userDefaults.setObject("Month Day Year", forKey: kDATEFORMATSTRING)
            userDefaults.synchronize()
        }
        
        currency = userDefaults.objectForKey(kCURRENCY) as! String
        dateFormat = userDefaults.objectForKey(kDATEFORMAT) as! String
    }
    
    
    //MARK: NSFetchresultsDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("did change content")
        updateUI()
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainToEditSeg" {
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let expense = fetchResultController.objectAtIndexPath(indexPath!) as! Expense
            
            let editVC = segue.destinationViewController as! AddExpenseViewController
            editVC.expens = expense
            
            
        }
        
    }
    
}