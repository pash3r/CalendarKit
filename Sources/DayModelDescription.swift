//
//  DayModelDescription.swift
//  
//
//  Created by Pavel Tikhonov on 12/6/21.
//

import Foundation
import UIKit

public protocol DayModelDescription: AnyObject {
    var startHour: Int { get }
    var endHour: Int { get }
    var lastHourForTimeline: Int { get }
    var totalWorkingHours: Int { get }
}

public protocol DayModelDataSource: AnyObject {
    func dayModel(for date: Date) -> DayModelDescription
    func getPlaceholderView(for date: Date?) -> UIView?
    func isBusy(date: Date) -> Bool
}
