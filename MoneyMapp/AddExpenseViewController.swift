//
//  AddExpenseViewController.swift
//  MoneyMapp
//
//  Created by Tung Ly on 6/2/16.
//  Copyright © 2016 Tung Ly. All rights reserved.
//

import UIKit
import CoreData

class AddExpenseViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var expens:Expense?
    var isExpense:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        dateTextField.inputView = datePicker
        datePicker.addTarget(self, action: Selector("handleDatePicker"), forControlEvents: UIControlEvents.ValueChanged)
        dateTextField.delegate = self
        
        if let expens = expens {
            updateUI(expens)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    
    @IBAction func dismissKeyboard(sender: UIButton) {
        self.view.endEditing(false)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        if nameTextField.text != "" && amountTextField.text != "" {
            if let _ = expens {
                datePicker.setDate(dateFromString(dateTextField.text!), animated: true)
                saveEdit()
            } else {
                saveNew()
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: TableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if indexPath.row == 0 {
            if isExpense {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            cell.textLabel?.text = "Expense"
        } else if indexPath.row == 1 {
            if !isExpense {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            cell.textLabel?.text = "Income"
        }
        cell.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        return cell
    }
    
    //MARK: TableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            isExpense = true
        } else if indexPath.row == 1 {
            isExpense = false
        }
        tableView.reloadData()
    }
    
    //MARK: UITextfieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == dateTextField{
            if let _ = expens {
                //once the user selects date textfield, set the datepicker date to match saved date
                datePicker.setDate(dateFromString(dateTextField.text!), animated: true)
            }
            handleDatePicker()
        }
    }
    
    
    //MARK: Helper Methods
    private func updateUI(expens: Expense) {
        nameTextField.text = expens.name
        amountTextField.text = ("\(expens.amount!)")
        dateTextField.text = stringFromDate(expens.date!)
        isExpense = expens.isExpense!.boolValue
    }
    
    
    private func saveNew() {
        let entityDescription = NSEntityDescription.insertNewObjectForEntityForName("Expense", inManagedObjectContext: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext) as! Expense
        
        //add calendar Units (week, month, year) to expense
        entityDescription.weekOfTheYear = calendarComponents().weekOfYear
        entityDescription.monthOfTheYear = calendarComponents().month
        entityDescription.year = calendarComponents().year
        
        
        entityDescription.name = nameTextField.text!
        
        entityDescription.dateString = stringFromDate(datePicker.date)
        entityDescription.date = datePicker.date
        entityDescription.isExpense = isExpense
        
        entityDescription.amount = Double(amountTextField.text!)!
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }
    
    private func saveEdit() {
        expens!.amount = Double(amountTextField.text!)!
        expens!.name = nameTextField.text!
        expens!.date = datePicker.date
        expens!.isExpense = isExpense
        expens!.dateString = stringFromDate(datePicker.date)
        expens!.weekOfTheYear = calendarComponents().weekOfYear
        expens!.monthOfTheYear = calendarComponents().month
        expens!.year = calendarComponents().year
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }
    
    private func stringFromDate (date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.stringFromDate(date)
    }
    
    private func dateFromString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        return dateFormatter.dateFromString(string)!
    }
    
    func calendarComponents () -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: datePicker.date)
        return components
    }
    
    
    func handleDatePicker() {
        self.dateTextField.text = stringFromDate(datePicker.date)
    }
    
    
    
}