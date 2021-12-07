import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
    var startDate: Date { get set }
    var endDate: Date { get set }
    var isAllDay: Bool { get }
    var text: String { get }
    var attributedText: NSAttributedString? { get }
    var lineBreakMode: NSLineBreakMode? { get }
    var font : UIFont { get }
    var color: UIColor { get }
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var editedEvent: EventDescriptor? { get set }
    var lessonEvent: LessonEventProtocol? { get set }
    
    func makeEditable() -> Self
    func commitEditing()
}

public protocol LessonEventProtocol: AnyObject {
    typealias AvatarSetter = (UIImageView) -> Void
    
    var address: String { get }
    var name: String { get }
    var avatarClosure: AvatarSetter { get }
    var addressFont: UIFont { get }
    var addressTextColor: UIColor { get }
    var nameFont: UIFont { get }
    var nameTextColor: UIColor { get }
    var lesson: Any { get }
}
