//
//  TokenMappedView.swift
//  TokenMappedView
//
//  Created by Vincent Coetzee on 5/8/21.
//

import SwiftUI

struct TokenView: NSViewRepresentable
    {
    typealias NSViewType = NSTextView
    
    @Binding var text: String
    
    public func makeNSView(context:Context) -> NSTextView
        {
        return(NSTextView(frame: .zero))
        }
        
    func updateNSView(_ nsView: NSTextView,context: Context)
        {
        nsView.textStorage?.append(self.format(source:self.$text.wrappedValue))
        }
        
    private func format(source:String) -> NSMutableAttributedString
        {
        let tokens = TokenStream(source: source,context: NullReportingContext.shared).allTokens(withComments: true, context: NullReportingContext.shared)
        let decorator = TokenDecorator()
        let wrapped = tokens.flatMap{decorator.decorate($0)}
        let attributes:[NSAttributedString.Key:Any] = [.font:NSFont(name:"Menlo",size: 11)!,.foregroundColor: NSColor.argonXcodePink]
        let mutable = NSMutableAttributedString(string: source,attributes: attributes)
        for token in wrapped
            {
            mutable.setAttributes(token.attributes, range: token.range)
            }
        return(mutable)
        }
    }

struct TokenView_Previews: PreviewProvider
    {
    @State static var source = Argon.sampleSource
    
    static var previews: some View
        {
        TokenView(text: self.$source)
        }
    }

struct WrappedToken
    {
    public let textColor:NSColor
    public let font:NSFont
    public let range:NSRange
    public var attributes:[NSAttributedString.Key:Any]
        {
        let attributes:[NSAttributedString.Key:Any] = [.foregroundColor:self.textColor,.font:self.font]
        return(attributes)
        }
    }

struct TokenDecorator
    {
    private let font = NSFont(name:"Menlo",size: 11)!
    private let color = NSColor.argonPink
    
    func decorate(_ token:Token) -> WrappedToken?
        {
        let range = NSRange(location: token.location.tokenStart, length: token.location.tokenStop - token.location.tokenStart)
        switch(token)
            {
            case .invisible:
                return(nil)
            case .keyword:
                let tokenColor = NSColor.argonNeonGreen
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .identifier:
                let tokenColor = NSColor.argonXcodePink
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .name:
                let tokenColor = NSColor.argonNeonOrange
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .comment:
                let tokenColor = NSColor.argonPurple
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .path:
                let tokenColor = NSColor.argonIvory
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .symbol:
                let tokenColor = NSColor.argonBayside
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .string:
                let tokenColor = NSColor.argonSalmonPink
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .hashString:
                let tokenColor = NSColor.argonNeonFuchsia
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .integer:
                let tokenColor = NSColor.argonSeaGreen
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .float:
                let tokenColor = NSColor.argonZomp
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .directive:
                let tokenColor = NSColor.argonNamingYellow
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            default:
                return(nil)
            }
        }
    }
