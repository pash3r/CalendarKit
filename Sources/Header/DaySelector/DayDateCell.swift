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
        dateLabel.date = date
      updateState()
    }
  }


    public var selected: Bool = false {
        didSet {
            configureStyles()
        }
    }
    
    public var dayModel: DayModelDescription? {
        didSet {
            guard dayModel != nil else {
                return
            }
            
            updateState()
        }
    }
    
    public var isEmpty: Bool = false {
        didSet {
            configureStyles()
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
      clipsToBounds = true
      [dayLabel, dateLabel].forEach {
          addSubview($0)
          $0.translatesAutoresizingMaskIntoConstraints = false
          $0.backgroundColor = .clear
      }
      
      NSLayoutConstraint.activate([
        dayLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
        dayLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
        dayLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
        dayLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        
        dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor),
        dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
        dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 4),
        dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
        dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
      ])
      
      layer.cornerRadius = 6
      layer.borderWidth = 1
  }

  public func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    dateLabel.updateStyle(newStyle)
    updateState()
  }

    private func updateState() {
        dateLabel.updateState()
        updateDayLabel()
        configureStyles()
        setNeedsLayout()
    }
    
    private func updateDayLabel() {
        let daySymbols = calendar.shortWeekdaySymbols
        let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
        var weekDays = Array(zip(daySymbols, weekendMask))
        weekDays.shift(calendar.firstWeekday - 1)
        let weekDay = component(component: .weekday, from: date)
        dayLabel.text = (daySymbols[weekDay - 1]).lowercased()
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
    
    private func configureStyles() {
        let bgColor: UIColor
        let textColor: UIColor
        let borderColor: CGColor

        let isSelected = selected
        if isSelected {
            bgColor = style.selectedBgColor
            textColor = style.selectedTextColor
            borderColor = style.selectedBorderColor.cgColor
        } else {
            let isBusyDay = isEmpty
            bgColor = isBusyDay ? style.busyBgColor : style.emptyBgColor
            textColor = isBusyDay ? style.busyTextColor : style.emptyTextColor
            borderColor = (isBusyDay ? style.busyBorderColor : style.emptyBorderColor).cgColor
        }
        
        backgroundColor = bgColor
        dayLabel.font = style.dayNameFont
        dayLabel.textColor = textColor
        dateLabel.font = style.dayNumberFont
        dateLabel.textColor = dayLabel.textColor
        layer.borderColor = borderColor
    }
    
}
