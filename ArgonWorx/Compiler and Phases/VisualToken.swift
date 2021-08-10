//
//  VisualToken.swift
//  VisualToken
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation
import AppKit

public class VisualToken
    {
    public enum Kind
        {
        case `default`
        case localSlot
        case classSlot
        case `class`
        case module
        case method
        case methodInvocation
        case function
        case functionInvocation
        case identifier
        case keyword
        case integer
        case float
        case string
        case symbol
        case path
        case name
        case invisible
        case note
        case directive
        case comment
        case end
        case `operator`
        case keypath
        case byte
        case character
        case boolean
        case date
        case time
        case dateTime
        case type
        }
        
    public var isNone: Bool
        {
        switch(self.token)
            {
            case .none:
                return(true)
            default:
                return(false)
            }
        }
        
    public var attributes: [NSAttributedString.Key:Any]
        {
        var values = [NSAttributedString.Key:Any]()
        values[.font] = self.font
        values[.foregroundColor] = self.color
        return(values)
        }
        
    public let token: Token
    internal var kind: Kind = .default
    internal var font = NSFont(name: "Menlo",size: 11)
    internal var color: NSColor = .white
    internal let range: NSRange
    
    init(token theToken: Token)
        {
        self.range = NSRange(location: theToken.location.tokenStart, length: theToken.location.tokenStop - theToken.location.tokenStart)
        self.token = theToken
        switch(theToken)
            {
            case .name:
                self.kind = .name
            case .invisible:
                self.kind = .invisible
            case .path:
                self.kind = .path
            case .hashString:
                self.kind = .symbol
            case .note:
                self.kind = .note
            case .directive:
                self.kind = .directive
            case .comment:
                self.kind = .comment
            case .end:
                self.kind = .end
            case .identifier:
                self.kind = .identifier
            case .keyword:
                self.kind = .keyword
            case .string:
                self.kind = .string
            case .integer:
                self.kind = .integer
            case .float:
                self.kind = .float
            case .symbol:
                self.kind = .symbol
            case .none:
                self.kind = .default
            case .operator:
                self.kind = .operator
            case .character:
                self.kind = .character
            case .boolean:
                self.kind = .boolean
            case .byte:
                self.kind = .byte
            case .keyPath:
                self.kind = .keypath
            case .date:
                self.kind = .date
            case .time:
                self.kind = .time
            case .dateTime:
                self.kind = .dateTime
            }
        }
        
    public func mapColors(systemClassNames: Array<String>) -> VisualToken
        {
        switch(self.kind)
            {
            case .invisible:
                break
            case .keyword:
                self.color = NSColor.argonXGreen
            case .identifier:
                let identifier = token.identifier
                if systemClassNames.contains(identifier)
                    {
                    self.color = NSColor.argonNeonOrange
                    }
                self.color = NSColor.argonXcodePink
            case .name:
                self.color = NSColor.argonXOrange
            case .comment:
                self.color = NSColor.yellow
            case .path:
                self.color = NSColor.argonIvory
            case .symbol:
                self.color = NSColor.argonBayside
            case .string:
                self.color = NSColor.argonSalmonPink
            case .class:
                self.color = NSColor.argonNeonFuchsia
            case .integer:
                self.color = NSColor.argonSeaGreen
            case .float:
                self.color = NSColor.argonZomp
            case .directive:
                self.color = NSColor.argonNamingYellow
            case .methodInvocation:
                self.color = NSColor.argonXWhite
            case .method:
                self.color = NSColor.argonXWhite
            case .functionInvocation:
                self.color = NSColor.argonXBlue
            case .function:
                self.color = NSColor.argonXBlue
            case .localSlot:
                self.color = NSColor.argonXCornflower
            case .classSlot:
                self.color = NSColor.argonXCoral
            case .type:
                self.color = NSColor.argonXSeaBlue
            default:
                break
            }
        return(self)
        }
    }

        

