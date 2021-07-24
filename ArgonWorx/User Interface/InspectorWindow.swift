//
//  InspectorView.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 23/7/21.
//

import SwiftUI

struct InspectorWindow: View
    {
    private let someWords = 1024
    
    @State var startAddress: Word = 0
    @State var endAddress: Word = 0
    @State var wordCount: Int = 0
    @State var isExpanded: Bool = false
    
    var body: some View
        {
        HStack
            {
            TextField("Start Address:",value: self.$startAddress,formatter: NumberFormatter())
            TextField("End Address:",value: self.$endAddress,formatter: NumberFormatter())
            TextField("Word Count:",value: self.$wordCount,formatter: NumberFormatter())
            }
        VStack
            {
            List(self.loadObjectWords())
                {
                block in
                    VStack
                        {
                        Text("\(block.address.addressString)").font(Font.custom("Menlo",size: 11)).frame(alignment:.top)
                        Spacer()
                        }
                    VStack
                        {
                        ForEach(block.words)
                            {
                            slotWord in
                            Text("\(slotWord.bitString)").font(Font.custom("Menlo",size: 11))
                            }
                        }
                }
            }
        }
        
    private func loadObjectWords() -> Array<WordBlock>
        {
        let segment = ManagedSegment.shared
        let start = segment.startOffset
        let end = segment.endOffset
        var offset = start
        var objects = Array<WordBlock>()
        while offset < end
            {
            print("STARTING OBJECT AT \(offset.addressString)")
            var words = Array<Word>()
            let header = segment.word(atOffset: offset)
            words.append(header)
            var size = Header(header).sizeInWords
            print("OBJECT SIZE IN WORDS = \(size)")
            size = min(1024,size)
            offset += Word(MemoryLayout<Word>.size)
            for _ in 1..<size
                {
                words.append(segment.word(atOffset: offset))
                offset += Word(MemoryLayout<Word>.size)
                }
            objects.append(WordBlock(address:offset,words:words))
            }
        return(objects)
        }
    }

struct InspectorView_Previews: PreviewProvider {
    static var previews: some View {
        InspectorWindow()
    }
}


struct ObjectView: View
    {
    private let block:WordBlock
    
    init(block:WordBlock)
        {
        self.block = block
        }
        
    var body: some View
        {
        Text("\(block.address.addressString)")
        }
    }

struct HeaderView: View
    {
    var word:Word
    
    var body: some View
        {
        Text("HEADER: \(word.bitString)")
        }
    }

struct SlotView: View
    {
    var word:Word
    
    var body: some View
        {
        Text("SLOT:   \(word.bitString)")
        }
    }

struct WordBlock:Identifiable
    {
    public var bitString:String
        {
        self.words[0].bitString
        }
        
    public var addressString:String
        {
        address.addressString
        }
        
    public var typeString:String
        {
        "OBJECT"
        }
        
    public var id:Word
        {
        self.address
        }
        
    public let address:Word
    public let words:Words
    
    public var children: Array<SlotWord>?
        {
        return(words.map{SlotWord(word:$0)})
        }
        
    init(address:Word,words:Words)
        {
        self.address = address
        self.words = words
        }
    }

struct SlotWord:Identifiable,Hashable
    {
    public var children:Array<Word>?
        {
        nil
        }
        
    public let id = UUID()
    public let word:Word
    }
