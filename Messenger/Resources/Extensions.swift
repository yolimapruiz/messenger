//
//  Extensions.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 11/07/23.
//

import Foundation
import UIKit
extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var heigth: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
}

extension Notification.Name {
    ///notification when user logs in
    static let didLogInNotificacion = Notification.Name("didLogInNotificacion")
}
