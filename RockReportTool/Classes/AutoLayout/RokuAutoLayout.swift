import UIKit

public class RokuAutoLayout {
    
}

/** FILL **/
// Make a view fill another view completely, or fill an axis
// Fill functions set equal width/height as well as align edges

extension RokuAutoLayout {
//    public static func fillView(view: UIView, ancestor: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func fillView(view: UIView, ancestorSafeArea: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    // Horizontal orientation
//
//    public static func fillHorizontal(view: UIView, ancestor: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func fillHorizontal(view: UIView, ancestorSafeArea: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    // Vertical orientation
//
//    public static func fillVertical(view: UIView, ancestor: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func fillVertical(view: UIView, ancestorSafeArea: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func fillVertical(view: UIView, ancestor: UIView, topOffset: CGFloat) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func fillVertical(view: UIView, ancestorSafeArea: UIView, topOffset: CGFloat) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func leastAsBig(view: UIView, ancestor: UIView) -> [NSLayoutConstraint] {
//        return []
//    }
}

/** WIDTH, HEIGHT **/

extension RokuAutoLayout {
    
    // set width/height to a constant
    
    public static func setWidthOf(view: UIView, width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: width)
        view.addConstraint(constraint)
        return constraint
    }
    
    public static func setHeightOf(view: UIView, height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: height)
        view.addConstraint(constraint)
        return constraint
    }
    
//    // MAX width/height constraints
//
//    public static func setMaxWidthOf(view: UIView, maxWidth: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setMaxHeightOf(view: UIView, maxHeight: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    // set width/height equal to another view
//
//    public static func setEqualWidth(view: UIView, view2: UIView) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setEqualWidth(view: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setEqualHeight(view: UIView, view2: UIView) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setEqualHeight(view: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    // set width/height proportionally, for instance to divide the screen into 2/3 and 1/3; e.g left.width = 2*right.width
//    // --> [AutoLayoutUtils setProportionateWidthOf:left to:2 as:right];
//
//    public static func setProportionateWidth(view: UIView, proportion: CGFloat, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setProportionateWidth(view: UIView,
//                                             proportion: CGFloat,
//                                             view2: UIView,
//                                             offset: CGFloat,
//                                             priority: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setProportionateHeight(view: UIView, proportion: CGFloat, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func setProportionateHeight(view: UIView,
//                                              proportion: CGFloat,
//                                              view2: UIView,
//                                              offset: CGFloat,
//                                              priority: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    // Set aspect ratio = width/height
//
//    public static func setAspectRatio(view: UIView, aspect: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
}

/** ALIGNMENT **/

extension RokuAutoLayout {
//    // to "line up" two views by leading, trailing, top, bottom edges
//
//    public static func alignLeadingEdgeOf(view1: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignLeadingEdgeOf(view1: UIView, safeArea: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignTrailingEdgeOf(view1: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignTrailingEdgeOf(view1: UIView, safeArea: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignTopEdgeOf(view1: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignTopEdgeOf(view1: UIView, safeArea: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignBottomEdgeOf(view1: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignBottomEdgeOf(view1: UIView, safeArea: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignCenterX(with view: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func alignCenterY(with view: UIView, view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
}

/** INSET **/
extension RokuAutoLayout {
//    // applies offset to leading, trailing, top and bottom
//    public static func inset(with view: UIView, view2: UIView, offset: CGFloat) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    // applies horizontal offset to leading and trailing, vertical offset to top and bottom
//    public static func inset(with view: UIView, view2: UIView, horizontalOffset: CGFloat, verticalOffset: CGFloat) -> [NSLayoutConstraint] {
//        return []
//    }
//
//    public static func inset(with view: UIView,
//                             view2: UIView,
//                             leadingOffset: CGFloat,
//                             trailingOffset: CGFloat,
//                             topOffset: CGFloat,
//                             bottomOffset: CGFloat) -> [NSLayoutConstraint] {
//        return []
//    }
}

/** RELATIVE POSITIONING **/
extension RokuAutoLayout {
//    // Position two views side by side or top to bottom
//    public static func positionView(view: UIView, above view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func positionView(view: UIView, below view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
//
//    public static func positionView(view: UIView, above view2: UIView, atLeast: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint()
//    }
}

/** CENTERING **/

extension RokuAutoLayout {
    public static func centerVertically(view: UIView, in view2: UIView) -> NSLayoutConstraint {
        return centerVertically(view: view, in: view2, offset: 0.0)
    }
    
    public static func centerVertically(view: UIView, in view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: view2,
                                            attribute: .centerY,
                                            multiplier: 1.0,
                                            constant: offset)

        view.ancestorSharedWithView(view: view2)?.addConstraint(constraint)
        return constraint;
    }
    
    public static func centerHorizontally(view: UIView, in view2: UIView) -> NSLayoutConstraint {
        return centerHorizontally(view: view, in: view2, offset: 0.0)
    }
    
    
    public static func centerHorizontally(view: UIView, in view2: UIView, offset: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: view2,
                                            attribute: .centerX,
                                            multiplier: 1.0,
                                            constant: offset)

        view.ancestorSharedWithView(view: view2)?.addConstraint(constraint)
        return constraint;
    }
}

extension UIView {
    func ancestorSharedWithView(view: UIView) -> UIView? {
        var iter: UIView?
        iter = self
        while iter != nil {
            if let iterView = iter {
                if view.viewReachable(view: iterView) {
                    return iterView
                }
                iter = iter?.superview
            }
        }
        return nil
    }
    
    func viewReachable(view: UIView) -> Bool {
        var iter: UIView?
        iter = self
        while iter != nil {
            if iter == view {
                return true
            }
            iter = iter?.superview
        }
        
        return false
    }
}
