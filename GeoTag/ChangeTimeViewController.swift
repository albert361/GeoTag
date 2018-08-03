//
//  ChangeTimeView.swift
//  GeoTag
//
//  Created by Marco S Hyman on 7/29/18.
//  Copyright © 2018 Marco S Hyman. All rights reserved.
//

import Cocoa

class ChangeTimeViewController: NSViewController {
    var image: ImageData!
    var callback: (() -> ())?

    @IBOutlet weak var originalDate: NSDatePicker!
    @IBOutlet weak var newDate: NSDatePicker!

    override func viewWillAppear() {
        super.viewWillAppear()
        if let wc = view.window?.windowController as? ChangeTimeWindowController {
            image = wc.image
            callback = wc.callback
            if let dateValue = image.dateValue {
                originalDate.dateValue = dateValue
                newDate.dateValue = dateValue
            } else {
                // no current date
                originalDate.dateValue = Date(timeIntervalSince1970: 0)
                newDate.dateValue = Date()
            }
            return
        }
        unexpected(error: nil, "Cannot find ChangeTime Window Controller")
        fatalError("Cannot find ChangeTime Window Controller")
    }

    @IBAction func dateTimeChanged(
        _ sender: NSButton
    ) {
        if newDate.dateValue != originalDate.dateValue {
            image.dateValue = newDate.dateValue
            callback?()
        }
        self.view.window?.close()
    }

    @IBAction func cancel(
        _ sender: Any
    ) {
        print("Change cancelled")
        self.view.window?.close()
    }

}
