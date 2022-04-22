//
//  AppKit.swift
//  Avatar
//
//  Created by Денис Либит on 06.04.2022.
//

#if os(macOS)

import AppKit


extension NSImage {
    public static func avatar(
        id:          Avatar.ID = .int(0),
        text:        Avatar.Text,
        size:        CGSize,
        saturation:  CGFloat = 0.40,
        brightness:  CGFloat = 0.80,
        font:        NSFont? = nil,
        corners:     CGFloat = 0,
        padding:     CGFloat? = nil,
        placeholder: NSImage?
    ) -> NSImage? {
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
                let image = NSImage(size: size)
                image.lockFocusFlipped(false)
                draw(NSGraphicsContext.current?.cgContext)
                image.unlockFocus()
                return image
            }
        )
    }
}

#endif
