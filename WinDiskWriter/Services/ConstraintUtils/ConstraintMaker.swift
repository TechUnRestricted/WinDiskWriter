//
//  ConstraintMaker.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

class ConstraintMaker {
    private var view: NSView

    init(view: NSView) {
        self.view = view
    }

    enum Attribute {
        case top, bottom, leading, trailing, width, height, centerX, centerY

        var layoutConstraintAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            case .leading:
                return .leading
            case .trailing:
                return .trailing
            case .width:
                return .width
            case .height:
                return .height
            case .centerX:
                return .centerX
            case .centerY:
                return .centerY
            }
        }
    }

    @discardableResult
    func constraint(
        _ relation: NSLayoutConstraint.Relation = .equal,
        with attribute: Attribute,
        to toAttribute: Attribute,
        of otherView: NSView?,
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0
    ) -> ConstraintHandler {
        let targetAttribute = (otherView != nil) ? toAttribute.layoutConstraintAttribute : .notAnAttribute

        let constraint = NSLayoutConstraint(
            item: view,
            attribute: attribute.layoutConstraintAttribute,
            relatedBy: relation,
            toItem: otherView,
            attribute: targetAttribute,
            multiplier: multiplier,
            constant: constant
        )

        NSLayoutConstraint.activate([constraint])

        return ConstraintHandler(constraints: [constraint])
    }

    @discardableResult
    func center(in view: NSView, offsetY: CGFloat = 0, offsetX: CGFloat = 0) -> ConstraintHandler {
        let centerX = constraint(with: .centerX, to: .centerX, of: view, constant: offsetX).constraints
        let centerY = constraint(with: .centerY, to: .centerY, of: view, constant: offsetY).constraints
        
        return ConstraintHandler(constraints: centerX + centerY)
    }

    @discardableResult
    func size(
        _ relation: NSLayoutConstraint.Relation = .equal,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> ConstraintHandler {
        var constraints = [NSLayoutConstraint]()

        if let width = width {
            constraints += constraint(relation, with: .width, to: .width, of: nil, constant: width).constraints
        }

        if let height = height {
            constraints += constraint(relation, with: .height, to: .height, of: nil, constant: height).constraints
        }

        return ConstraintHandler(constraints: constraints)
    }
}
