//
//  DayModelDescription.swift
//  
//
//  Created by Pavel Tikhonov on 12/6/21.
//

import Foundation

public protocol DayModelDescription: AnyObject {
    var startHour: Int { get }
    var endHour: Int { get }
    var isBusyDay: Bool { get }
    var totalWorkingHours: Int { get }
}

public protocol DayModelDataSource: AnyObject {
    func dayModel(for date: Date) -> DayModelDescription
}
