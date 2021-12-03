import UIKit

open class EventView: UIView {
  public var descriptor: EventDescriptor?
  public var color = SystemColors.label

  public var contentHeight: CGFloat {
    return lessonView.frame.height
  }

    private let lessonView: LessonEventView = .init(frame: .zero)

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
      layer.cornerRadius = 6
      layer.masksToBounds = true
    color = tintColor
    addSubview(lessonView)
    
    for (idx, handle) in eventResizeHandles.enumerated() {
      handle.tag = idx
      addSubview(handle)
    }
  }

  public func updateWithDescriptor(event: EventDescriptor) {
      lessonView.nameLabel.text = event.lessonEvent?.name
      lessonView.nameLabel.font = event.lessonEvent?.nameFont
      lessonView.nameLabel.textColor = event.lessonEvent?.nameTextColor
      lessonView.addressLabel.text = event.lessonEvent?.address
      lessonView.addressLabel.font = event.lessonEvent?.addressFont
      lessonView.addressLabel.textColor = event.lessonEvent?.addressTextColor
      lessonView.imageView.image = event.lessonEvent?.avatar
//    if let attributedText = event.attributedText {
//      textView.attributedText = attributedText
//    } else {
//      textView.text = event.text
//      textView.textColor = event.textColor
//      textView.font = event.font
//    }
//    if let lineBreakMode = event.lineBreakMode {
//      textView.textContainer.lineBreakMode = lineBreakMode
//    }
    descriptor = event
    backgroundColor = event.backgroundColor
    color = event.color
    eventResizeHandles.forEach{
      $0.borderColor = event.color
      $0.isHidden = event.editedEvent == nil
    }
    drawsShadow = event.editedEvent != nil
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

  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    context.interpolationQuality = .none
    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(Constants.leftStripeWidth * 2)
//    context.translateBy(x: 0, y: 0.5)
    let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
    let x: CGFloat = leftToRight ? 0 : frame.width - 1  // 1 is the line width
    let y: CGFloat = 0
    context.beginPath()
    context.move(to: CGPoint(x: x, y: y))
    context.addLine(to: CGPoint(x: x, y: (bounds).height))
    context.strokePath()
    context.restoreGState()
  }

  private var drawsShadow = false

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
      
      if drawsShadow {
          applySketchShadow(alpha: 0.13,
                            blur: 10)
      }
  }

  private func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = alpha
    layer.shadowOffset = CGSize(width: x, height: y)
    layer.shadowRadius = blur / 2.0
    if spread == 0 {
      layer.shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
    
    private struct Constants {
        static let leftStripeWidth: CGFloat = 4
    }
}

private class LessonEventView: UIView {
    
    let addressLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    let nameLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    let imageView: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    private func configureSelf() {
        imageView.layer.masksToBounds = true
        [addressLabel, nameLabel, imageView].forEach { self.addSubview($0) }
        
        let nameLabelBottomConstraint = nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -Constants.bottomMargin)
        nameLabelBottomConstraint.priority = .init(999)
        
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topMargin),
            addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.horizontalMargin),
            addressLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -Constants.horizontalMargin),
            
            imageView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: Constants.imageTopMargin),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.horizontalMargin),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSideLength),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: Constants.betweenLabelsMargin),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.imageRightMargin),
            nameLabelBottomConstraint,
            nameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -Constants.horizontalMargin),
        ])
        
        
    }
    
    private struct Constants {
        static let topMargin: CGFloat = 8
        static let horizontalMargin: CGFloat = 16
        static let bottomMargin: CGFloat = 13
        static let betweenLabelsMargin: CGFloat = 7
        static let imageTopMargin: CGFloat = 4
        static let imageSideLength: CGFloat = 20
        static let imageRightMargin: CGFloat = 8
    }
    
}
