//
//  TokenMappedView.swift
//  TokenMappedView
//
//  Created by Vincent Coetzee on 5/8/21.
//

import SwiftUI
import Combine

struct TokenView: NSViewRepresentable
    {
    typealias NSViewType = NSScrollView
    
    @Binding var text: String
    
    public func makeNSView(context:Context) -> NSScrollView
        {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let view = LineNumberTextView(frame: .zero)
        scrollView.documentView = view
        view.gutterBackgroundColor = NSColor.black
        view.gutterForegroundColor = NSColor.white
        view.initOutsideNib()
        return(scrollView)
        }
        
    func updateNSView(_ nsView: NSScrollView,context: Context)
        {
        (nsView.documentView as! LineNumberTextView).textStorage?.append(self.format(source:self.$text.wrappedValue))
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
        TokenMappedViewControllerView(source: self.$source)
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
    private let systemClassNames = ArgonModule.argonModule.classes.map{$0.label}
    
    func decorate(_ token:Token) -> WrappedToken?
        {
        let range = NSRange(location: token.location.tokenStart, length: token.location.tokenStop - token.location.tokenStart)
        switch(token)
            {
            case .invisible:
                return(nil)
            case .keyword:
                let tokenColor = NSColor.argonXGreen
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .identifier:
                let identifier = token.identifier
                if self.systemClassNames.contains(identifier)
                    {
                    return(WrappedToken(textColor: NSColor.argonNeonOrange, font: font, range: range))
                    }
                let tokenColor = NSColor.argonXcodePink
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .name:
                let tokenColor = NSColor.argonXOrange
                return(WrappedToken(textColor: tokenColor, font: font, range: range))
            case .comment:
                let tokenColor = NSColor.argonXPurple
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

class TokenMappedViewController: NSViewController
    {
    var textView = LineNumberTextView()
    internal var source: String = ""
    internal var compiler: Compiler = Compiler()
    
    override func loadView()
        {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        textView.autoresizingMask = [.width]
        textView.allowsUndo = true
        textView.font = NSFont(name:"Menlo",size:11)!
        scrollView.documentView = textView
        textView.gutterBackgroundColor = NSColor.black
        textView.gutterForegroundColor = NSColor.white
        textView.backgroundColor = NSColor.black
        textView.initOutsideNib()
        self.view = scrollView
        }
    
    override func viewDidAppear()
        {
        self.view.window?.makeFirstResponder(self.view)
        }
        
    public func setSource(_ source:String)
        {
        compiler.compileChunk(source)
        self.view.setNeedsDisplay(.zero)
        }
    }

struct TokenMappedViewControllerView: NSViewControllerRepresentable
    {
    @Binding var source: String
    
    func makeCoordinator() -> Coordinator
        {
        return Coordinator(self)
        }
    
    class Coordinator: NSObject, NSTextStorageDelegate
        {
        private var parent: TokenMappedViewControllerView
        var shouldUpdateText = true
        
        init(_ parent: TokenMappedViewControllerView)
            {
            self.parent = parent
            }
        
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)
            {
//            guard shouldUpdateText else {
//                return
//            }
//            let edited = textStorage.attributedSubstring(from: editedRange).string
//            let insertIndex = parent.text.utf16.index(parent.text.utf16.startIndex, offsetBy: editedRange.lowerBound)
//
//            func numberOfCharactersToDelete() -> Int
//                {
//                editedRange.length - delta
//                }
//            let endIndex = parent.text.utf16.index(insertIndex, offsetBy: numberOfCharactersToDelete())
//            self.parent.text.replaceSubrange(insertIndex..<endIndex, with: edited)
            }
        }

    func makeNSViewController(context: Context) -> TokenMappedViewController
        {
        let vc = TokenMappedViewController()
        vc.textView.textStorage?.delegate = context.coordinator
        return vc
        }
    
    func updateNSViewController(_ nsViewController: TokenMappedViewController, context: Context)
        {
        let compiler = Compiler()
        compiler.compileChunk(self.$source.wrappedValue)
        let mutable = NSMutableAttributedString(string: self.$source.wrappedValue,attributes: [:])
        let tokens = compiler.visualTokens
        for token in tokens
            {
            mutable.setAttributes(token.attributes,range: token.range)
            }
        nsViewController.textView.textStorage?.append(mutable)
        }
        
//    private func format(source:String) -> NSMutableAttributedString
//        {
//        let tokens = TokenStream(source: source,context: NullReportingContext.shared).allTokens(withComments: true, context: NullReportingContext.shared)
//        let decorator = TokenDecorator()
//        let wrapped = tokens.flatMap{decorator.decorate($0)}
//        let attributes:[NSAttributedString.Key:Any] = [.font:NSFont(name:"Menlo",size: 11)!,.foregroundColor: NSColor.argonXcodePink]
//        let mutable = NSMutableAttributedString(string: source,attributes: attributes)
//        for token in wrapped
//            {
//            mutable.setAttributes(token.attributes, range: token.range)
//            }
//        return(mutable)
//        }
    }
