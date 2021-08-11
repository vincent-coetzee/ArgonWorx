//
//  VisualToken.swift
//  VisualToken
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation
import AppKit

fileprivate var TokenNumber:Int = 0

public class VisualToken
    {
    public enum Kind
        {
        case none
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
        case constant
        }
        
    public var isNone: Bool
        {
        switch(self.baseToken)
            {
            case .none:
                return(true)
            default:
                return(false)
            }
        }
        
    public var attributes: [NSAttributedString.Key:Any]
        {
        return(self._attributes)
        }
        
    public var baseToken: Token = .none
    
    internal var kind: Kind 
        {
        get
            {
            return(self._kind)
            }
        set
            {
            self._kind = newValue
            self.mapKindToColors(kind: newValue,systemClassNames: Compiler.systemClassNames)
            }
        }
        
    public var range: NSRange
        {
        self.baseToken.location.range
        }
        
    private var _attributes: [NSAttributedString.Key:Any] = [.font:NSFont(name: "Menlo",size: 12)!]
    private var _kind: Kind = .none
    public var number:Int
    
    init(token: Token)
        {
        self.number = TokenNumber
        TokenNumber += 1
        self.baseToken = token
        self.mapTokenToColors(token: token)
        }
        
    public func remapTokenToColors()
        {
        self.mapTokenToColors(token: self.baseToken)
        self.mapKindToColors(kind: self._kind, systemClassNames: Compiler.systemClassNames)
        }
        
    public func mapTokenToColors(token: Token)
        {
        switch(token)
            {
            case .name:
                self._kind = .name
                self._attributes[.foregroundColor] = SyntaxColorPalette.nameColor
            case .invisible:
                self._kind = .invisible
            case .path:
                self._kind = .path
                self._attributes[.foregroundColor] = SyntaxColorPalette.pathColor
            case .hashString:
                self._attributes[.foregroundColor] = SyntaxColorPalette.symbolColor
            case .note:
                self._kind = .note
            case .directive:
                self._kind = .directive
                self._attributes[.foregroundColor] = SyntaxColorPalette.directiveColor
            case .comment:
                self._kind = .comment
                self._attributes[.foregroundColor] = SyntaxColorPalette.commentColor
            case .end:
                self._kind = .end
            case .identifier:
                self._kind = .identifier
                self._attributes[.foregroundColor] = SyntaxColorPalette.identifierColor
            case .keyword:
                self._kind = .keyword
                self._attributes[.foregroundColor] = SyntaxColorPalette.keywordColor
            case .string:
                self._kind = .string
                self._attributes[.foregroundColor] = SyntaxColorPalette.stringColor
            case .integer:
                self._kind = .integer
                self._attributes[.foregroundColor] = SyntaxColorPalette.integerColor
            case .float:
                self._kind = .float
                self._attributes[.foregroundColor] = SyntaxColorPalette.floatColor
            case .symbol:
                self._kind = .operator
                self._attributes[.foregroundColor] = SyntaxColorPalette.operatorColor
            case .none:
                self._kind = .none
                self._attributes[.foregroundColor] = NSColor.argonNeonFuchsia
            case .operator:
                self._kind = .operator
                self._attributes[.foregroundColor] = SyntaxColorPalette.operatorColor
            case .character:
                self._kind = .character
                self._attributes[.foregroundColor] = SyntaxColorPalette.characterColor
            case .boolean:
                self._kind = .boolean
                self._attributes[.foregroundColor] = SyntaxColorPalette.booleanColor
            case .byte:
                self._kind = .byte
                self._attributes[.foregroundColor] = SyntaxColorPalette.byteColor
            case .keyPath:
                self._kind = .keypath
                self._attributes[.foregroundColor] = SyntaxColorPalette.keypathColor
            case .date:
                self._kind = .date
                self._attributes[.foregroundColor] = SyntaxColorPalette.textColor
            case .time:
                self._kind = .time
                self._attributes[.foregroundColor] = SyntaxColorPalette.textColor
            case .dateTime:
                self._kind = .dateTime
                self._attributes[.foregroundColor] = SyntaxColorPalette.textColor
            }
        }
        
    public func mapKindToColors(kind:Kind,systemClassNames: Array<String>)
        {
        switch(kind)
            {
            case .none:
                break
            case .invisible:
                break
            case .keyword:
                self._attributes[.foregroundColor] = SyntaxColorPalette.keywordColor
            case .identifier:
                let identifier = self.baseToken.identifier
                if systemClassNames.contains(identifier)
                    {
                    self._attributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
                    }
                else
                    {
                    self._attributes[.foregroundColor] = SyntaxColorPalette.identifierColor
                    }
            case .name:
                self._attributes[.foregroundColor] = SyntaxColorPalette.nameColor
            case .comment:
                self._attributes[.foregroundColor] = SyntaxColorPalette.commentColor
            case .path:
                self._attributes[.foregroundColor] = SyntaxColorPalette.pathColor
            case .symbol:
                self._attributes[.foregroundColor] = SyntaxColorPalette.symbolColor
            case .string:
                self._attributes[.foregroundColor] = SyntaxColorPalette.stringColor
            case .class:
                self._attributes[.foregroundColor] = SyntaxColorPalette.classColor
            case .integer:
                self._attributes[.foregroundColor] = SyntaxColorPalette.integerColor
            case .float:
                self._attributes[.foregroundColor] = SyntaxColorPalette.floatColor
            case .directive:
                self._attributes[.foregroundColor] = SyntaxColorPalette.directiveColor
            case .methodInvocation:
                self._attributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .method:
                self._attributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .functionInvocation:
                self._attributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .function:
                self._attributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .localSlot:
                self._attributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .classSlot:
                self._attributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .type:
                self._attributes[.foregroundColor] = SyntaxColorPalette.typeColor
            case .constant:
                self._attributes[.foregroundColor] = SyntaxColorPalette.constantColor
            default:
                self._attributes[.foregroundColor] = NSColor.magenta
            }
        }
    }

        

