//
//  Shared.swift
//  Avatar
//
//  Created by Денис Либит on 06.04.2022.
//

import Foundation
import CoreGraphics
import CryptoKit


// MARK: - Публичное

public struct Avatar {}

extension Avatar {
    public struct ID {
        public static func int<T: BinaryInteger>(_ id: T) -> Self {
            let data = Swift.withUnsafeBytes(of: id) { Data($0) }
            let key = self.key(for: data)
            return Self(key: key)
        }
        
        public static func string<T: StringProtocol>(_ id: T) -> Self {
            let data = id.data(using: .utf8) ?? Data()
            let key = self.key(for: data)
            return Self(key: key)
        }
        
        internal let key: UInt64
    }
    
    public enum Text {
        case initials(String)
        case name(String, max: Int = 2)
        case components(PersonNameComponents)
    }
}

// MARK: - Инструменты

extension Avatar.ID {
    internal static func key(for data: Data) -> UInt64 {
        let hash = SHA256.hash(data: data)
        let pref = hash.prefix(8)
        let body = Data(pref)
        let uint = body.reduce(0) { $0 << 8 | UInt64($1) }
        return uint
    }
}

extension Avatar.Text {
    internal var initials: String {
        switch self {
            case let .initials(initials):
                // сразу даны инициалы
                return initials
                
            case let .name(name, max):
                // вычислим инициалы
                let separator: CharacterSet =
                    .whitespacesAndNewlines
                    .union(.punctuationCharacters)
                
                let words: [String] =
                    name.components(separatedBy: separator)
                
                let initials: [String] =
                    words.compactMap({ $0.first }).map(String.init)
                
                switch initials.count {
                    case 1:
                        // единственное слово, вернём две его первые буквы
                        return String(words[0].prefix(max)).localizedUppercase
                    default:
                        // слов или нет, или больше одного
                        return initials.prefix(max).joined()
                }
                
            case let .components(components):
                // тут всё просто
                let initials = PersonNameComponentsFormatter.localizedString(from: components, style: .abbreviated)
                return String(initials.prefix(2))
        }
    }
    
    internal var long: String {
        switch self {
            case let .initials(initials):
                // у нас лишь инициалы
                return initials
                
            case let .name(name, _):
                // отдадим полный текст имени
                return name
                
            case let .components(components):
                // отдадим в длинной форме
                return PersonNameComponentsFormatter.localizedString(from: components, style: .long)
        }
    }
}

#if os(macOS)
import AppKit
typealias Font  = NSFont
typealias Color = NSColor
#else
import UIKit
typealias Font  = UIFont
typealias Color = UIColor
#endif

extension Avatar {
    internal static func draw<I>(
        id:          Avatar.ID,
        text:        Avatar.Text,
        size:        CGSize,
        saturation:  CGFloat,
        brightness:  CGFloat,
        font:        Font?,
        corners:     CGFloat,
        padding:     CGFloat?,
        placeholder: I?,
        setup:       ((CGContext?) -> Void) -> I?
    ) -> I? {
        // есть в чём рисовать?
        guard
            size.width  > 0,
            size.height > 0
        else {
            return placeholder
        }
        
        // убедимся, что есть инициалы
        let initials = text.initials
        
        guard initials.isEmpty == false else {
            return placeholder
        }
        
        // хэш
        let hash: UInt64 =
            text.long.utf8.reduce(id.key) { ($0 &* 33) + (UInt64($1) * 101) }
        
        // оттенок
        let hue =
            CGFloat(hash % 360) / 360
        
        // цвета
        let backColor =
            Color(
                hue: hue,
                saturation: saturation,
                brightness: brightness,
                alpha: 1
            )
        
        let textColor =
            Color(
                hue: 0,
                saturation: 0,
                brightness: brightness > 0.8 ? 0.2 : 1.0,
                alpha: 1
            )
        
        // уголки
        let corners: CGFloat =
            min(corners, size.width / 2, size.height / 2)
        
        // отступы
        let padding: CGFloat =
            padding ?? ceil(min(size.width, size.height) * 0.1)
        
        // получим контекст
        return setup { context in
            guard let context = context else {
                return
            }
            
            // фон
            context.setFillColor(backColor.cgColor)
            
            context.addPath(
                CGPath(
                    roundedRect: CGRect(origin: .zero, size: size),
                    cornerWidth: corners,
                    cornerHeight: corners,
                    transform: nil
                )
            )
            context.fillPath()
            
            // шрифт
            let font: Font =
                font ?? Font.systemFont(ofSize: floor(size.height / 2))
            
            // текст
            let attributedText =
                NSAttributedString(
                    string: initials,
                    attributes: [
                        .font: font,
                        .foregroundColor: textColor,
                    ]
                )
            
            // вычислим размер оригинального текста
            let textSize: CGSize =
                attributedText
                    .boundingRect(
                        with: .zero,
                        options: [.usesLineFragmentOrigin],
                        context: nil
                    )
                    .size
            
            // есть что рисовать?
            guard
                textSize.width  > 0,
                textSize.height > 0
            else {
                return
            }
            
            // масштабирование
            let scale =
                min(
                    1,
                    (size.width  - padding * 2) / textSize.width,
                    (size.height - padding * 2) / textSize.height
                )
            
            // сдвинем прямоугольник текста под изменённый масштаб контекста
            let rect =
                CGRect(
                    origin: CGPoint(
                        x: ((size.width  - textSize.width  * scale) / 2) / scale,
                        y: ((size.height - textSize.height * scale) / 2) / scale
                    ),
                    size: textSize
                )
            
            // отмасштабируем контекст
            context.saveGState()
            context.scaleBy(x: scale, y: scale)
            
            // рисуем
            attributedText
                .draw(
                    with: rect,
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )
            
            // вернём контекст к начальному состоянию
            context.restoreGState()
        }
    }
}
