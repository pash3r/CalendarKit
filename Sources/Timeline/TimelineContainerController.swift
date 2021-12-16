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
    var emtyDayView: EmptyDayView?
    
    public override func loadView() {
        view = container
    }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
      let contentHeight: CGFloat = max(timeline.frame.height, container.frame.height)
      let contentSize = CGSize(width: timeline.frame.width, height: contentHeight)
      let currentContentSize = container.contentSize
      if currentContentSize != contentSize {
          container.contentSize = contentSize
      }

      emtyDayView?.frame = self.view.bounds
    if let newOffset = pendingContentOffset {
      // Apply new offset only once the size has been determined
      if view.bounds != .zero {
        container.setContentOffset(newOffset, animated: false)
        container.setNeedsLayout()
        pendingContentOffset = nil
      }
    }
  }
    
    private func makeEmtyDayView() -> EmptyDayView {
        let result = EmptyDayView(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.style = timeline.style.emtyDayStyle
        return result
    }
    
    private func showEmtyDayView(_ show: Bool) {
        guard show else {
            emtyDayView?.removeFromSuperview()
            emtyDayView = nil
            return
        }
        
        var emtyDayView: EmptyDayView! = self.emtyDayView
        if emtyDayView == nil {
            emtyDayView = makeEmtyDayView()
            self.emtyDayView = emtyDayView
        }
        
        view.addSubview(emtyDayView)
        NSLayoutConstraint.activate([
            emtyDayView.topAnchor.constraint(equalTo: view.topAnchor),
            emtyDayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emtyDayView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emtyDayView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }

    private func showEmptyViewIfNecessary() {
        guard let model = dayModelDataSource?.dayModel(for: timeline.date) else {
            showEmtyDayView(false)
            return
        }
        
        let show = model.totalWorkingHours == 0
        showEmtyDayView(show)
    }
    
}
