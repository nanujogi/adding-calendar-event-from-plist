//
//  ViewController.swift
//  ekeventdemo
//
//  Created by Nanu Jogi on 30/08/17.
//  Copyright © 2017 GL. All rights reserved.
//
import UIKit
import EventKit

class ViewController: UIViewController {
    
    var myclass = MyClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Calendar Event"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Event", style: .plain, target: self, action: #selector(addevent))
    }
    
    func addevent() {
        
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                self.addallevents(eventStore: eventStore)
            } else {
                self.myalert(mytitle: "We need your permission to add events in your Calendar", msg: "")
            }
        }
    } // end of addevent
    
    func addallevents(eventStore: EKEventStore) {
        
        if let path = Bundle.main.path(forResource: "calendar-data", ofType: "plist") {
            if let dataArray = NSArray(contentsOfFile: path) {
                for dict in dataArray {
                    
                    let event = EKEvent(eventStore: eventStore)
                    
                    // subject & name goes below
                    let jbDict = dict as! [String: AnyObject]
                    
                    if let subject_unwrapped = jbDict["subject"] as? String,
                        let name_unwrapped = jbDict["name"] as? String {
                        event.title = subject_unwrapped + " of " + name_unwrapped
                        event.notes = "Call \(name_unwrapped) for \(subject_unwrapped)"
                    }
                    
                    // Date
                    if let mydate = jbDict["dob"] as? String {
                        let dateArray1 = mydate.components(separatedBy: "-")
                        
                        var mystartdates = DateComponents()
                        mystartdates.year = Int(dateArray1[2])
                        mystartdates.month = Int(dateArray1[1])
                        mystartdates.day = Int(dateArray1[0])
                        mystartdates.hour = 10
                        mystartdates.minute = 10
                        mystartdates.second = 0
                        mystartdates.calendar = Calendar.current
                        
                        var myenddate = DateComponents()
                        myenddate.year = Int(dateArray1[2])
                        myenddate.month = Int(dateArray1[1])
                        myenddate.day = Int(dateArray1[0])
                        myenddate.hour = 10
                        myenddate.minute = 35
                        myenddate.second = 0
                        myenddate.calendar = Calendar.current
                        
                        event.startDate = mystartdates.date!
                        event.endDate = myenddate.date!
                    }
                    
                    // Repeat the event every year
                    if let eventRecurrencetests = EKRecurrenceFrequency.init(rawValue: 3) {
                        let eventRecurrence = EKRecurrenceRule.init(recurrenceWith: eventRecurrencetests, interval: 1, end: nil)
                        event.recurrenceRules = [eventRecurrence]
                    }
                    
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    // alaram 1 minute before
                    let alarm1minutebefore = EKAlarm(relativeOffset: -60) //1 minute
                    event.addAlarm(alarm1minutebefore)
                    
                    // Let us Save it
                    do {
                        try eventStore.save(event, span: .thisEvent)
                        
                    } catch let error as NSError {
                        print ("error: \(error)") // in case of error print error
                    }
                    
                } // end of for dict in dataArray
                
            } // end of if let dataArray
            
        myalert(mytitle: "Successfully added all events in your Calendar", msg: "👍🏽")
            navigationItem.rightBarButtonItem?.isEnabled = false // disable the button
            
            // Fetch all events
            fetchevent(eventStore: eventStore)
            
        } // end of Bundle.main
        
    } // end of addallevents
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // FetchEvents
    func fetchevent(eventStore: EKEventStore) {
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day = 365
        let futureDate = calendar.date(byAdding: dateComponents, to: now)
        
        let eventsPredicate = eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil)

        let events = eventStore.events(matching: eventsPredicate)
           print ("Date dd-mm-yyyy     Event - Subject")
        
        for event in events{
            let mydt =  myclass.sdate(dtsent: event.startDate)
            print ("\(mydt)          \(event.title)" )
        }
    }
    
}


