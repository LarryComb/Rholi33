
//  ViewController.swift
//  CocoaPodsTest_10_18
//
//  Created by Larry Combs on 10/18/15.
//  Copyright © 2015 Larry Combs. All rights reserved.
//

import UIKit
import CVCalendar
import Parse


class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //Mark Properties
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var daysOutSwitch: UISwitch!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var UserName: UITextField!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var loginViewBottomSpaceConstraint: NSLayoutConstraint!
    
    lazy var images: [UIImage] = []
    lazy var imageObjects: [PFObject] = []
    
    var avoidAlertForMonthChange = 0

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if(textField == self.UserName)
        {
            self.UserName?.resignFirstResponder()
            self.Password?.becomeFirstResponder()
        }
        else if (textField == self.Password)
        {
            self.Password?.resignFirstResponder()
            self.Email?.becomeFirstResponder()
        }
        else if (textField == self.Email)
        {
            self.Email?.resignFirstResponder()
        }
         return true
    }
    
    lazy var shouldShowDaysOut = true
    lazy var animationFinished = true
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        TableView.userInteractionEnabled = PFUser.currentUser() != nil
        
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
        let imageQuery = PFQuery(className: "Image")
        let date = NSDate(timeIntervalSinceNow: 86400000 * -1)
        imageQuery.whereKey("createdAt", greaterThanOrEqualTo: date)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeGesture.direction = .Left
        TableView.addGestureRecognizer(swipeGesture)
    
        imageQuery.findObjectsInBackgroundWithBlock { [weak self] (imageObjects, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            
            
            if error == nil {
                if let imageObjects = imageObjects {
                    for imageObject in imageObjects {
                        if let imageFile = imageObject["image"] as? PFFile {
                            if let data = try? imageFile.getData() {
                                if let image = UIImage(data: data) {
                                    self?.imageObjects.append(imageObject)
                                    do {
                                        try (imageObject["user"] as? PFUser)?.fetchIfNeeded()
                                    }
                                    catch {}
                                    self?.images.append(image)
                                }
                            }
                        }
                    }
                }
            
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.TableView.reloadData()
                })
                
            
            } else {
                //TODO Alert user that images are not loading
            }
            }
        }
        //let testObject = PFObject(className: "TestObject")
        //testObject["foo"] = "barr"
        //testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        // print("Object has been saved.")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func swiped(gesture:UISwipeGestureRecognizer) {
        self.performSegueWithIdentifier("CollectionViewControllerSegue", sender: nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        loginViewBottomSpaceConstraint.constant = 200
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.setNeedsLayout()
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        loginViewBottomSpaceConstraint.constant = 20
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.setNeedsLayout()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let name = PFUser.currentUser()?.username
        if name == nil {
            self.view.viewWithTag(1)?.hidden = false
        }
        else
        {
            
            self.view.viewWithTag(1)?.hidden = true

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.delegate = self
        self.calendarView.calendarDelegate = self
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        menuView.delegate = self
    }
    
    // TODO Can not figure out where to put this code
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if (textField == self.UserName)
        {
            self.UserName?.resignFirstResponder()
            self.Password?.becomeFirstResponder()
        }
        else if (textField == self.Password)
        {
            self.Password?.resignFirstResponder()
            
            self.authenticate()
        }
        
        retun; true
    }
}


func authenticate()
{
    var email = self.email?.text
    var password = self.password?.text
    
    if (email?.isEmpty == true || password?.isEmpty == true)// is this an email address
    {
        //alert the user 
        return
    }
    else
    {
        //otherwise authenticate
    }
}
    
*/
    
    @IBAction func SignUp(sender: AnyObject){
        
        SignUp()
        TableView.userInteractionEnabled = true
    
    }
    
    @IBAction func SignIn(sender: AnyObject){
        
        SignIn()
        TableView.userInteractionEnabled = true
    
    }
    
    @IBAction func LogOut(sender: AnyObject){
        PFUser.logOut()
        self.view.viewWithTag(1)?.hidden = false
        TableView.userInteractionEnabled = false
        
    }
    
    @IBAction func Camera(sender: AnyObject){
        
        let Picker = UIImagePickerController()
        Picker.sourceType = .PhotoLibrary
        Picker.delegate = self
        self.presentViewController(Picker, animated: true, completion: nil)
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        if let image = info[UIImagePickerControllerOriginalImage]as? UIImage {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let Parseimage = PFObject(className: "Image")
                Parseimage.setObject(PFUser.currentUser()!, forKey: "user")
                let data = UIImageJPEGRepresentation(image, 0.8)
                let imagefile = PFFile(data: data!)
                Parseimage.setObject(imagefile!, forKey: "image")
                do {
                    try Parseimage.save()
                } catch _ {
                    print("Error happened saving to parse")
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.images.insert(image, atIndex: 0)
                    self.imageObjects.insert(Parseimage, atIndex: 0)
                    self.TableView.reloadData()
                })
            })
            
        }
            self.dismissViewControllerAnimated(true, completion: nil)
        

    }

}



extension ViewController: UITableViewDelegate{

    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.images.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)as! CameraViewCell
        let image = self.images[indexPath.row]
        cell.ImageView.image = image
        //below code changes all UserName labels to current user name
        cell.UserName.text = PFUser.currentUser()?.username
        cell.UserName.text = (self.imageObjects[indexPath.row]["user"] as? PFUser)?["username"] as? String
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let image = self.images[indexPath.row]
        
        let viewController = ImageViewController(nibName: nil, bundle: nil)
        viewController.image = image
        viewController.object = self.imageObjects[indexPath.row]
        viewController.delegate = self
        
        
        presentViewController(viewController, animated: true, completion: nil)
    }

}

extension ViewController: ImageViewControllerDelegate {
    
    func imageViewControllerDidPressBackButton(controller: ImageViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageViewControllerDidPressLikeButton(controller: ImageViewController) {
        
    }
    
}


// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension ViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    
  func SignUp(){
    let user = PFUser()
    user.username = UserName.text
    user.password = Password.text
    user.email = Email.text
    
    
    user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        if error == nil {
            // Let them use the app now by Hiding StartUserView
            self.view.viewWithTag(1)?.hidden = true
            
        } else {
            // Examine the error object and inform the user.Give notification that username/password incorrect
            let alertController = UIAlertController(title: "Uh Oh", message: "Looks Like Something Went Wrong and We Couldn't Sign you Up, Please Try Again", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Return To Sign Up", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
}

   


    func SignIn(){
        let user = PFUser()
        user.username = UserName.text
        user.password = Password.text
     
        PFUser.logInWithUsernameInBackground(UserName.text!, password: Password.text!, block: {
            (User : PFUser?, Error : NSError?) -> Void in
            
            if Error == nil{
                // Hide StartUserView
                self.view.viewWithTag(1)?.hidden = true
                
            }
            else{
                 //TODO Give notification that username/password incorrect
                let alertController = UIAlertController(title: "Uh Oh", message: "Looks Like Something Went Wrong and We Couldn't Sign you In, Please Try Again", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Return To Sign In", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        
        })
        
       
    }

    
    
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        let date = dayView.date
        holidayForDate(date)
        print("\(calendarView.presentedDate.commonDescription) is selected!")
    }
    
    func presentedDateUpdated(date: CVDate) {
        if avoidAlertForMonthChange == 0 {
            holidayForDate(date)
        }
        else {
            avoidAlertForMonthChange--
        }
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            print("test:%@",date.globalDescription);
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let randomDay = Int(arc4random_uniform(31))
        if day == randomDay {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        _ = dayView.date.day
        
        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        let numberOfDots = Int(arc4random_uniform(3) + 1)
        switch(numberOfDots) {
        case 2:
            return [color, color]
        case 3:
            return [color, color, color]
        default:
            return [color] // return 1 dot
        }
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }
    
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    
    
    
    
    
    
    //        Line 161 read: NSString *dateString = [NSString stringWithFormat:@"%i-%i", start.month, start.day];
    //        This is from Objective-c file to call Holiday.json file
    
    func holidayForDate(date:CVDate) {
        //let cal = NSCalendar.currentCalendar()
        // let components = cal.components([.Month, .Day], fromDate: date)
        let dateString = "\(date.month)-\(date.day)"
        
        guard let path : String = NSBundle.mainBundle().pathForResource("Holiday", ofType: "json") else {
            // TODO error handling?
            return
        }
        guard let jsonData = NSData(contentsOfFile: path) else {
            // TODO error handling?
            return
        }
        do {
            guard let dict:[String:AnyObject] = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String : AnyObject] else {
                // TODO error handling
                return
            }
            if let dict2 = dict[dateString] as? [String:[[String:String]]] {
                if let holidays:[[String:String]] = dict2["holidays"] {
                    if let holiday = holidays.first {
                        let title = holiday["title"]
                        let description = holiday["description"]
                        let alertController = UIAlertController(title: title, message: description, preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                            
                        }))
                        presentViewController(alertController, animated: true, completion: { () -> Void in
                            
                        })
                    }
                }
            }
        }
        catch {
            NSLog("\(error)")
        }
        
    }
    
}
//NSString *dateString = [NSString, stringWithFormat;@"%li-%li", (long)start.month, (long)start.day];


// MARK: - CVCalendarViewDelegate
/*
extension ViewController: CVCalendarViewDelegate {
func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
circleView.fillColor = .colorFromCode(0xCCCCCC)
return circleView
}

func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
if (dayView.isCurrentDay) {
return true
}
return false
}

func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
let p = M_PI

let ringSpacing: CGFloat = 3.0
let ringInsetWidth: CGFloat = 1.0
let ringVerticalOffset: CGFloat = 1.0
var ringLayer: CAShapeLayer!
let ringLineWidth: CGFloat = 4.0
let ringLineColour: UIColor = .blueColor()

let newView = UIView(frame: dayView.bounds)

let diameter: CGFloat = (newView.bounds.width) - ringSpacing
let radius: CGFloat = diameter / 2.0

let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)

ringLayer = CAShapeLayer()
newView.layer.addSublayer(ringLayer)

ringLayer.fillColor = nil
ringLayer.lineWidth = ringLineWidth
ringLayer.strokeColor = ringLineColour.CGColor

let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
let startAngle: CGFloat = CGFloat(-p/2.0)
let endAngle: CGFloat = CGFloat(p * 2.0) + startAngle
let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)

ringLayer.path = ringPath.CGPath
ringLayer.frame = newView.layer.bounds

return newView
}

func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
if (Int(arc4random_uniform(3)) == 1) {
return true
}

return false
}
}
*/

// MARK: - CVCalendarViewAppearanceDelegate



extension ViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension ViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
    @IBAction func toWeekView(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
    }
    
    /// Switch to MonthView mode.
    @IBAction func toMonthView(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
}

// MARK: - Convenience API Demo

extension ViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        _ = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func didShowNextMonthView(date: NSDate)
    {
        avoidAlertForMonthChange = 2
        _ = NSCalendar.currentCalendar()
        _ = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
        avoidAlertForMonthChange = 2
        _ = NSCalendar.currentCalendar()
        _ = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
   
    
}
