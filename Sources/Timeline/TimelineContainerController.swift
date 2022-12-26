import UIKit

public final class TimelineContainerController: UIViewController {
  /// Content Offset to be set once the view size has been calculated
    public var pendingContentOffset: CGPoint?
    public weak var dayModelDataSource: DayModelDataSource? {
        didSet {
            timeline.dayModelDataSource = dayModelDataSource
            showEmptyViewIfNecessary()
        }
    }
  
    public lazy var timeline = TimelineView()
    public lazy var container: TimelineContainer = {
        let view = TimelineContainer(timeline)
        view.addSubview(timeline)
        view.alwaysBounceVertical = true
        return view
    }()
    var emptyDayView: UIView?
    
    public override func loadView() {
        view = container
    }
      
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
      let contentHeight: CGFloat = max(timeline.frame.height, (container.frame.height - container.adjustedContentInset.bottom))
      let contentSize = CGSize(width: timeline.frame.width, height: contentHeight)
      let currentContentSize = container.contentSize
      if currentContentSize != contentSize {
          container.contentSize = contentSize
      }

      emptyDayView?.frame = self.view.bounds
    if let newOffset = pendingContentOffset {
      // Apply new offset only once the size has been determined
      if view.bounds != .zero {
        container.setContentOffset(newOffset, animated: false)
        container.setNeedsLayout()
        pendingContentOffset = nil
      }
    }
  }
    
    private func makeEmptyDayView(_ date: Date?) -> UIView? {
        let result = dayModelDataSource?.getPlaceholderView(for: date)
        result?.translatesAutoresizingMaskIntoConstraints = false
//        result?.style = timeline.style.emtyDayStyle
        return result
    }
    
    private func showEmptyDayView(_ show: Bool, date: Date?) {
        guard show else {
            emptyDayView?.removeFromSuperview()
            emptyDayView = nil
            return
        }
        
        var emptyDayView: UIView! = self.emptyDayView
        if emptyDayView == nil {
            emptyDayView = makeEmptyDayView(date)
            self.emptyDayView = emptyDayView
        }
        
        view.addSubview(emptyDayView)
        NSLayoutConstraint.activate([
            emptyDayView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyDayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyDayView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyDayView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }

    private func showEmptyViewIfNecessary() {
        guard let model = dayModelDataSource?.dayModel(for: timeline.date) else {
            showEmptyDayView(false, date: timeline.date)
            return
        }
        
        let show = model.totalWorkingHours == 0
        showEmptyDayView(show, date: timeline.date)
    }
    
}
