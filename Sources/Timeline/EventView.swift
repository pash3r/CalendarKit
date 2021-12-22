import UIKit

public protocol ShadowDrawable: AnyObject {
    static func addShadow(to layer: CALayer, rect: CGRect, radiusValue: CGFloat, isDarkMode: Bool)
    static func makeShadowPath(for rect: CGRect, radiusValue: CGFloat) -> CGPath
}

open class EventView: UIView {
    public static var shadowHelper: ShadowDrawable.Type?
    
  public var descriptor: EventDescriptor?
  public var color = SystemColors.label

  public var contentHeight: CGFloat {
    return lessonView.frame.height
  }

    private let lessonView: LessonEventView = .init(frame: .zero)
    private let contentView: EventContentView = .init(frame: .zero)

  /// Resize Handle views showing up when editing the event.
  /// The top handle has a tag of `0` and the bottom has a tag of `1`
  public lazy var eventResizeHandles = [EventResizeHandleView(), EventResizeHandleView()]

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

    private func configure() {
        color = tintColor
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        contentView.addSubview(lessonView)
        
        for (idx, handle) in eventResizeHandles.enumerated() {
            handle.tag = idx
            addSubview(handle)
        }
        
        contentView.layer.cornerRadius = Constants.cornerRadius
        lessonView.layer.cornerRadius = contentView.layer.cornerRadius
        contentView.clipsToBounds = true
    }

    public func updateWithDescriptor(event: EventDescriptor) {
        lessonView.nameLabel.text = event.lessonEvent?.name
        lessonView.nameLabel.font = event.lessonEvent?.nameFont
        lessonView.nameLabel.textColor = event.lessonEvent?.nameTextColor
        lessonView.addressLabel.text = event.lessonEvent?.address
        lessonView.addressLabel.font = event.lessonEvent?.addressFont
        lessonView.addressLabel.textColor = event.lessonEvent?.addressTextColor
        event.lessonEvent?.avatarClosure(lessonView.imageView, event.lessonEvent?.avatarUrl)
        
        let now = Date()
        let isOverlayHidden = !(now > event.endDate)
        lessonView.overlayView.isHidden = isOverlayHidden
        
        descriptor = event
        contentView.backgroundColor = event.backgroundColor
        lessonView.backgroundColor = contentView.backgroundColor
        contentView.stripeWidth = Constants.leftStripeWidth
        contentView.stripeColor = event.color
        contentView.stripeAlpha = lessonView.overlayView.isHidden ? 1.0 : 0.5
        
        eventResizeHandles.forEach{
            $0.borderColor = event.color
            $0.isHidden = event.editedEvent == nil
        }
                
        setNeedsDisplay()
        setNeedsLayout()
    }
  
  public func animateCreation() {
    transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    func scaleAnimation() {
      transform = .identity
    }
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   usingSpringWithDamping: 0.2,
                   initialSpringVelocity: 10,
                   options: [],
                   animations: scaleAnimation,
                   completion: nil)
  }

  /**
   Custom implementation of the hitTest method is needed for the tap gesture recognizers
   located in the ResizeHandleView to work.
   Since the ResizeHandleView could be outside of the EventView's bounds, the touches to the ResizeHandleView
   are ignored.
   In the custom implementation the method is recursively invoked for all of the subviews,
   regardless of their position in relation to the Timeline's bounds.
   */
  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    for resizeHandle in eventResizeHandles {
      if let subSubView = resizeHandle.hitTest(convert(point, to: resizeHandle), with: event) {
        return subSubView
      }
    }
    return super.hitTest(point, with: event)
  }

  private var drawsShadow = true

  override open func layoutSubviews() {
    super.layoutSubviews()
      
      let stripeWidth = Constants.leftStripeWidth
      lessonView.frame = {
          if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
              return CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width - stripeWidth, height: bounds.height)
          } else {
              return CGRect(x: bounds.minX + Constants.leftStripeWidth, y: bounds.minY, width: bounds.width - stripeWidth, height: bounds.height)
          }
      }()
      if frame.minY < 0 {
          var textFrame = lessonView.frame;
          textFrame.origin.y = frame.minY * -1;
          textFrame.size.height += frame.minY;
          lessonView.frame = textFrame;
      }
      let first = eventResizeHandles.first
      let last = eventResizeHandles.last
      let radius: CGFloat = 40
      let yPad: CGFloat =  -radius / 2
      let width = bounds.width
      let height = bounds.height
      let size = CGSize(width: radius, height: radius)
      first?.frame = CGRect(origin: CGPoint(x: width - radius - layoutMargins.right, y: yPad),
                            size: size)
      last?.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: height - yPad - radius),
                           size: size)
      
      if drawsShadow, let shadowHelper = Self.shadowHelper {
          let rect = bounds
          let cornerRadius = Constants.cornerRadius
          
          shadowHelper.addShadow(to: layer,
                                 rect: rect,
                                 radiusValue: cornerRadius,
                                 isDarkMode: traitCollection.userInterfaceStyle == .dark)
          layer.shadowPath = shadowHelper.makeShadowPath(for: rect, radiusValue: cornerRadius)
      }
  }

    private struct Constants {
        static let leftStripeWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 6
    }
    
}

private class EventContentView: UIView {
    
    var stripeAlpha: CGFloat = 1
    var stripeColor: UIColor = .purple
    var stripeWidth: CGFloat = 1
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.interpolationQuality = .none
        context.saveGState()
        context.setStrokeColor(stripeColor.withAlphaComponent(stripeAlpha).cgColor)
        context.setLineWidth(stripeWidth * 2)

        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let x: CGFloat = leftToRight ? 0 : frame.width - stripeWidth
        let y: CGFloat = 0
        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x, y: (bounds).height))
        context.strokePath()
        context.restoreGState()
    }
    
}
