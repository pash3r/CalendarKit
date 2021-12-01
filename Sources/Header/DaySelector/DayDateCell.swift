import UIKit

public final class DayDateCell: UIView, DaySelectorItemProtocol {

  private let dateLabel = DateLabel()
  private let dayLabel = UILabel()

  private var regularSizeClassFontSize: CGFloat = 16

  public var date = Date() {
    didSet {
      dateLabel.date = date
      updateState()
    }
  }

  public var calendar = Calendar.autoupdatingCurrent {
    didSet {
      dateLabel.calendar = calendar
      updateState()
    }
  }


  public var selected: Bool {
    get {
      return dateLabel.selected
    }
    set(value) {
      dateLabel.selected = value
    }
  }

  var style = DaySelectorStyle()

  override public var intrinsicContentSize: CGSize {
    return CGSize(width: 40, height: 50)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  private func configure() {
      // WARNING!: -- remove after debug
      layer.borderColor = UIColor.red.cgColor
      layer.borderWidth = 1
      //
      clipsToBounds = true
      [dayLabel, dateLabel].forEach {
          addSubview($0)
          $0.translatesAutoresizingMaskIntoConstraints = false
      }
      
      NSLayoutConstraint.activate([
        dayLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
        dayLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
        dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
      ])
      
      layer.cornerRadius = 6
      
      backgroundColor = .purple
  }

  public func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    dateLabel.updateStyle(newStyle)
    updateState()
  }

  private func updateState() {
    let isWeekend = isAWeekend(date: date)
    dayLabel.font = UIFont.systemFont(ofSize: regularSizeClassFontSize)
    dayLabel.textColor = isWeekend ? style.weekendTextColor : style.inactiveTextColor
    dateLabel.updateState()
    updateDayLabel()
    setNeedsLayout()
  }

  private func updateDayLabel() {
    let daySymbols = calendar.shortWeekdaySymbols
    let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
    var weekDays = Array(zip(daySymbols, weekendMask))
    weekDays.shift(calendar.firstWeekday - 1)
    let weekDay = component(component: .weekday, from: date)
    dayLabel.text = daySymbols[weekDay - 1]
  }

  private func component(component: Calendar.Component, from date: Date) -> Int {
    return calendar.component(component, from: date)
  }

  private func isAWeekend(date: Date) -> Bool {
    let weekday = component(component: .weekday, from: date)
    if weekday == 7 || weekday == 1 {
      return true
    }
    return false
  }

  override public func tintColorDidChange() {
    updateState()
  }
}
