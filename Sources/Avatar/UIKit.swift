//
//  UIKit.swift
//  Avatar
//
//  Created by Денис Либит on 06.04.2022.
//

#if os(iOS) || os(watchOS) || os(tvOS)

import UIKit


extension UIImage {
    public static func avatar(
        id:          Avatar.ID = .int(0),
        text:        Avatar.Text,
        size:        CGSize,
        saturation:  CGFloat = 0.40,
        brightness:  CGFloat = 0.80,
        font:        UIFont? = nil,
        corners:     CGFloat = 0,
        padding:     CGFloat? = nil,
        placeholder: UIImage?
    ) -> UIImage? {
        return Avatar.draw(
            id:          id,
            text:        text,
            size:        size,
            saturation:  saturation,
            brightness:  brightness,
            font:        font,
            corners:     corners,
            padding:     padding,
            placeholder: placeholder,
            setup: { draw in
                #if os(watchOS)
                    UIGraphicsBeginImageContextWithOptions(size, false, 0)
                    defer { UIGraphicsEndImageContext() }
                    draw(UIGraphicsGetCurrentContext())
                    return UIGraphicsGetImageFromCurrentImageContext()
                #else
                    return UIGraphicsImageRenderer(size: size).image { draw($0.cgContext) }
                #endif
            }
        )
    }
}

#endif
