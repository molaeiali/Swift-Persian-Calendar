//
//  ViewController.swift
//  CVCalendar Demo
//


import UIKit
import Foundation

class ViewController: UIViewController, CVCalendarViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var daysOutSwitch: UISwitch!
    
    @IBOutlet weak var table: UITableView!
    var shouldShowDaysOut = true
    var animationFinished = true
    let months = ["Farvardin", "Ordibehesht", "Khordad", "Tir", "Mordad", "Shahrivar", "Mehr", "Aban", "Azar", "Day", "Bahman", "Esfand"]
    let weeks = [ "Shanbeh", "Yek shanbeh", "Doshanbeh", "Seshhanbeh", "Chaharshanbeh", "Panjshanbeh", "Jomeh"]
    /// put the holidays name
    let holidays = ["Noruz", "mehrgan", "Sinzdah Be Dar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = CVDate(date: Date()).description2()
        self.shouldShowDaysOut = false
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "present-100"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.menuClicked)) as UIBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
    }
    let textCellIdentifier = "TextCell"
    // MARK: - IB Actions
    func menuClicked(){
        NSLog("Nav Button Clicked!")
        self.calendarView.toggleTodayMonthView()
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.calendarView!.changeDaysOutShowingState(false)
            self.shouldShowDaysOut = true
        } else {
            self.calendarView!.changeDaysOutShowingState(true)
            self.shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        self.calendarView.toggleTodayMonthView()
    }
    
    // MARK: Calendar View Delegate
    
    func shouldShowWeekdaysOut() -> Bool {
        return self.shouldShowDaysOut
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView) {
        // TODO:
        let click_month:Int = dayView.date!.month!
        let click_day:Int = dayView.date!.day!
        let click_year:Int = dayView.date!.year!
        print("click_ \(click_month)_\(click_day)_\(click_year)")
        var sectionNum: Int
        if click_month > 7 {
            sectionNum  = 31 * 6 + (click_month - 7) * 30 + click_day - 1
        }else{
            sectionNum  = (click_month - 1)  * 31 + click_day - 1
        }
        if (self.numberOfSections(in: table) > 0) {
            let top = IndexPath(row: Foundation.NSNotFound, section: sectionNum)
            self.table.scrollToRow(at: top, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> UIColor {
//        if dayView.date?.day == 3 {
//            return .redColor()
//        } else if dayView.date?.day == 5 {
//            return .blackColor()
//        } else if dayView.date?.day == 2 {
//            return .blueColor()
//        }
        
        return .clear
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        if dayView.date?.day == 3 || dayView.date?.day == 5 || dayView.date?.day == 2 {
            return true
        } else {
            return false
        }
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    
    func presentedDateUpdated(_ date: CVDate) {
        self.navigationItem.title = date.description2()
    }
    
    func toggleMonthViewWithMonthOffset(_ offset: Int) {
        let calendar = Calendar.current
        let calendarManager = CVCalendarManager.sharedManager
        var components = calendarManager.componentsForDate(Date()) // from today ///Not
        print("components?!?!?!?! = \(components)")
        components.month! += offset
        
        let resultDate = calendar.date(from: components)!
        
        self.calendarView.toggleMonthViewWithDate(resultDate)
    }
    /////////////////////////////////////////////////////////////////////////
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 366
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as UITableViewCell
        
        let row = indexPath.section
        // Put the holidays here
        switch (row) {
        case 0...3:
            cell.textLabel?.text = holidays[0]
            
        case 12:
            cell.textLabel?.text = holidays[2]
            //return sectionHeaderView
        default:
            cell.textLabel?.text = "No Event"
        }
        
        return cell
    }
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
        headerCell.backgroundColor = UIColor.cyan
        
        var monthNum, dayNum : Int
        if section < 186 {
            monthNum = (section + 1) / 31 + 1
            dayNum = (section + 1) % 31
            if dayNum == 0 {
                dayNum = 31; monthNum -= 1
            }
        }else{
            monthNum = (section + 1 - 186) / 30 + 7
            dayNum = (section + 1 - 186) % 30
            if dayNum == 0 {
                dayNum = 30; monthNum -= 1
            }
        }
        let weekNum = section % 7;
        headerCell.headerLabel.text = " \(weeks[weekNum]), \(dayNum)  \(months[monthNum - 1])"
        return headerCell
    }
}
