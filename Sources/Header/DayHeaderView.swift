import UIKit

public final class DayHeaderView: UIView, DaySelectorDelegate, DayViewStateUpdating, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  public private(set) var daysInWeek = 7
  public let calendar: Calendar

  private var style = DayHeaderStyle()
  private var currentSizeClass = UIUserInterfaceSizeClass.compact

  public weak var state: DayViewState? {
    willSet(newValue) {
      state?.unsubscribe(client: self)
    }
    didSet {
      state?.subscribe(client: self)
      swipeLabelView.state = state
    }
  }
    
    public weak var dayModelDataSource: DayModelDataSource? {
        get {
            (pagingViewController.viewControllers?.first as? DaySelectorController)?.dayModelDataSource
        }
        set {
            reloadData { $0.dayModelDataSource = newValue }
        }
    }

  private var currentWeekdayIndex = -1

  private var pagingScrollViewHeight: CGFloat = 50

  private let daySymbolsView: DaySymbolsView
  private var pagingViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: .horizontal,
                                                       options: nil)
  private let swipeLabelView: SwipeLabelView

  public init(calendar: Calendar) {
    self.calendar = calendar
    let symbols = DaySymbolsView(calendar: calendar)
    let swipeLabel = SwipeLabelView(calendar: calendar)
    self.swipeLabelView = swipeLabel
    self.daySymbolsView = symbols
    super.init(frame: .zero)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configure() {
    [daySymbolsView].forEach(addSubview)
    backgroundColor = style.backgroundColor
    configurePagingViewController()
  }
  
  private func configurePagingViewController() {
      let selectedDate = Date()
      let vc = makeSelectorController(startDate: beginningOfWeek(selectedDate))
      vc.selectedDate = selectedDate
      currentWeekdayIndex = vc.selectedIndex
      
      let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
      let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse
      
      pagingViewController.setViewControllers([vc], direction: direction, animated: false, completion: nil)
      pagingViewController.dataSource = self
      pagingViewController.delegate = self
      addSubview(pagingViewController.view!)
  }
  
    private func makeSelectorController(startDate: Date) -> DaySelectorController {
        let new = DaySelectorController()
        new.calendar = calendar
        new.transitionToHorizontalSizeClass(currentSizeClass)
        new.updateStyle(style.daySelector)
        new.startDate = startDate
        new.delegate = self
        new.dayModelDataSource = dayModelDataSource
        return new
    }
    
    private func reloadData(using closure: @escaping (DaySelectorController) -> Void) {
        pagingViewController.viewControllers?
            .compactMap { $0 as? DaySelectorController }
            .forEach(closure)
    }
  
  private func beginningOfWeek(_ date: Date) -> Date {
    let weekOfYear = component(component: .weekOfYear, from: date)
    let yearForWeekOfYear = component(component: .yearForWeekOfYear, from: date)
    return calendar.date(from: DateComponents(calendar: calendar,
                                              weekday: calendar.firstWeekday,
                                              weekOfYear: weekOfYear,
                                              yearForWeekOfYear: yearForWeekOfYear))!
  }

  private func component(component: Calendar.Component, from date: Date) -> Int {
    return calendar.component(component, from: date)
  }
  
  public func updateStyle(_ newStyle: DayHeaderStyle) {
    style = newStyle
    daySymbolsView.updateStyle(style.daySymbols)
    swipeLabelView.updateStyle(style.swipeLabel)
    (pagingViewController.viewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(newStyle.daySelector)}
    backgroundColor = style.backgroundColor
  }

    override public func layoutSubviews() {
        super.layoutSubviews()
        pagingViewController.view?.frame = CGRect(origin: .zero,
                                                  size: CGSize(width: bounds.width, height: pagingScrollViewHeight))
    }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    currentSizeClass = sizeClass
    daySymbolsView.isHidden = sizeClass == .regular
    (pagingViewController.children as? [DaySelectorController])?.forEach{$0.transitionToHorizontalSizeClass(sizeClass)}
  }

  // MARK: DaySelectorDelegate

  public func dateSelectorDidSelectDate(_ date: Date) {
    state?.move(to: date)
  }

  // MARK: DayViewStateUpdating

  public func move(from oldDate: Date, to newDate: Date) {
    let newDate = newDate.dateOnly(calendar: calendar)

    let centerView = pagingViewController.viewControllers![0] as! DaySelectorController
    let startDate = centerView.startDate.dateOnly(calendar: calendar)

    let daysFrom = calendar.dateComponents([.day], from: startDate, to: newDate).day!
    let newStartDate = beginningOfWeek(newDate)

    let new = makeSelectorController(startDate: newStartDate)
    
    let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight

    if daysFrom < 0 {
      currentWeekdayIndex = abs(daysInWeek + daysFrom % daysInWeek) % daysInWeek
      new.selectedIndex = currentWeekdayIndex
      
      let direction: UIPageViewController.NavigationDirection = leftToRight ? .reverse : .forward
        
      pagingViewController.setViewControllers([new], direction: direction, animated: true, completion: nil)
    } else if daysFrom > daysInWeek - 1 {
      currentWeekdayIndex = daysFrom % daysInWeek
      new.selectedIndex = currentWeekdayIndex
      
      let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse
        
      pagingViewController.setViewControllers([new], direction: direction, animated: true, completion: nil)
    } else {
      currentWeekdayIndex = daysFrom
      centerView.selectedDate = newDate
      centerView.selectedIndex = currentWeekdayIndex
    }
  }

  // MARK: UIPageViewControllerDataSource

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let selector = viewController as? DaySelectorController else {
            return nil
        }
        
        guard let startDate = state?.startDate else {
            let previousDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selector.startDate)!
            return makeSelectorController(startDate: previousDate)
        }
        
        let currentControllerDate = selector.startDate
        if currentControllerDate == startDate {
            return nil
        }
        
        if currentControllerDate > startDate, let prevDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentControllerDate) {
            return makeSelectorController(startDate: prevDate)
        }
          
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let selector = viewController as? DaySelectorController else {
            return nil
        }
        
        let currentControllerDate = selector.startDate
        
        guard let endDate = state?.endDate else {
            return makeSelectorController(startDate: calendar.date(byAdding: .weekOfYear, value: 1, to: currentControllerDate)!)
        }
        
        var nextController: UIViewController?
        
        let result = calendar.compare(currentControllerDate, to: endDate, toGranularity: .weekOfYear)
        if case .orderedAscending = result, let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentControllerDate) {
            nextController = makeSelectorController(startDate: nextDate)
        }
        
        return nextController
    }

  // MARK: UIPageViewControllerDelegate

  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else {return}
    if let selector = pageViewController.viewControllers?.first as? DaySelectorController {
      selector.selectedIndex = currentWeekdayIndex
      if let selectedDate = selector.selectedDate {
        state?.client(client: self, didMoveTo: selectedDate)
      }
    }
    // Deselect all the views but the currently visible one
    (previousViewControllers as? [DaySelectorController])?.forEach{$0.selectedIndex = -1}
  }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    (pendingViewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(style.daySelector)}
  }
}
