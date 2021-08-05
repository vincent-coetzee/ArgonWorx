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
            List(self.loadNodes())
                {
                node in
                OutlineGroup(node,children: \.children)
                    {
                    inner in
                    if inner.children.isNotNil
                        {
                        OutlineGroup(inner,children: \.children)
                            {
                            child in
                            Text(child.displayString)
                            }
                        }
                    else
                        {
                        Text(inner.displayString)
                        }
                    }
                }
            }
        }
        
    private func loadBlocks() -> Array<WordBlock>
        {
        let segment = ManagedSegment.shared
        let start = segment.startOffset
        let end = Int((segment.endOffset - start) / 8)
        var offset = 0
        var objects = Array<WordBlock>()
        let pointer = WordPointer(address: start)!
        while offset < end
            {
            print("STARTING OBJECT AT \(Word(offset*8).addressString)")
            let startOffset = offset
            var words = Array<Word>()
            let header = pointer[offset]
            words.append(header)
            var size = Header(header).sizeInWords
            print("OBJECT SIZE IN WORDS = \(size)")
            size = min(1024,size)
            offset += size
            for _ in 1..<size
                {
                words.append(pointer[offset])
                offset += 1
                }
            objects.append(WordBlock(address:Word(startOffset*8),words:words))
            }
        return(objects)
        }
        
    private func loadNodes() -> Array<AddressNode>
        {
        let segment = ManagedSegment.shared
        let start = segment.startOffset
        let end = Int((segment.endOffset - start) / 8)
        var offset = 0
        var objects = Array<ObjectNode>()
        let pointer = WordPointer(address: start)!
        while offset < end
            {
            print("STARTING OBJECT AT \((Word(offset*8) + start).addressString)")
            let objectNode = ObjectNode(address: Word(offset*8) + start)
            let header = pointer[offset]
            let size = Header(header).sizeInWords
            offset += size
            objects.append(objectNode)
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

struct SlotIndex:Identifiable,Hashable
    {
    var id:Int
        {
        return(self.index)
        }
        
    let index:Int
    
    init(index:Int)
        {
        self.index = index
        }
    }
    
struct SlotRowView: View
    {
    var atIndex:Int
    var inBlock:WordBlock
    let slotValue:Word
    let slotName:String
    var offset:Int = 0
//    let slotPointer:InnerSlotPointer
//    let slotName:String
    
    init(atIndex:Int,inBlock:WordBlock)
        {
        self.atIndex = atIndex
        self.inBlock = inBlock
        self.slotValue = inBlock.words[atIndex].tagDropped
        if atIndex < self.inBlock.classPointer.slotCount
            {
            self.slotName = inBlock.classPointer.slot(atIndex: atIndex).name
            }
        else
            {
            self.slotName = ""
            }
//        self.slotPointer = self.inBlock.classPointer().slot(atIndex: atIndex)
//        self.slotName = self.slotPointer.name.aligned(.left, in: 30)
        }
        
    var body: some View
        {
        HStack
            {
//            Text(self.slotName)
            Text(self.slotName.aligned(.right,in:24)).inspectorFont()
            Text(String(format: " %05d ",atIndex * 8)).inspectorFont()
            Text("\(slotValue.bitString)").inspectorFont().foregroundColor(self.colorChooser())
            if atIndex < inBlock.classPointer.slots.count
                {
                Text(" \(inBlock.classPointer.slot(atIndex: atIndex).format(value: slotValue))".aligned(.left,in:25)).inspectorFont().foregroundColor(self.colorChooser())
                }
            else
                {
                Text(" ".aligned(.left,in:25)).inspectorFont()
                }
            }
        }
        
    private func colorChooser() -> Color
        {
        if atIndex == 2 && inBlock.words[atIndex] == 0
            {
            return(.orange)
            }
        if atIndex >= self.inBlock.classPointer.slotCount
            {
            return(.red)
            }
        if self.inBlock.classPointer.slot(atIndex: atIndex).isArraySlot
            {
            return(.green)
            }
        return(.white)
        }
    }

struct HeaderRowView: View
    {
    var atIndex:Int
    var inBlock:WordBlock
    let slotValue:Word
//    let slotPointer:InnerSlotPointer
//    let slotName:String
    
    init(atIndex:Int,inBlock:WordBlock)
        {
        self.atIndex = atIndex
        self.inBlock = inBlock
        self.slotValue = inBlock.words[atIndex]
//        self.slotPointer = self.inBlock.classPointer().slot(atIndex: atIndex)
//        self.slotName = self.slotPointer.name.aligned(.left, in: 30)
        }
        
    var body: some View
        {
        HStack
            {
//            Text(self.slotName)
            Text("\(slotValue.bitString)").font(Font.custom("Menlo",size: 11))
            }
        }
    }
    
struct WordBlock:Identifiable
    {
    public var indices: Array<SlotIndex>
        {
        var set = Array<SlotIndex>()
        for index in 0..<self.words.count
            {
            set.append(SlotIndex(index: index))
            }
        return(set)
        }
        
    public var addressString:String
        {
        address.addressString
        }
        
    public var typeString:String
        {
        "OBJECT"
        }
        
    public var className: String
        {
        self.classPointer.name
        }
        
    public var classPointer: InnerClassPointer
        {
        InnerPointer(address: self.address).classPointer
        }
        
    public var id:Word
        {
        self.address
        }
        
    public let address:Word
    public let words:Words
    public var _classPointer:InnerClassPointer?
    
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

struct InspectorFont: ViewModifier
    {
    func body(content: Content) -> some View
        {
        content.font(Font.custom("Menlo",size: 11))
        }
    }

extension View
    {
    func inspectorFont() -> some View
        {
        self.modifier(InspectorFont())
        }
    }

class AddressNode:Identifiable
    {
    public var displayString: String
        {
        return("AddressNode")
        }
        
    public let id = UUID()
    public var children: Array<AddressNode>?
        {
        return(nil)
        }
    }
    
class ObjectNode: AddressNode
    {
    public override var displayString: String
        {
        return("HEADER: \(self.header.bitString)")
        }
        
    public override var children: Array<AddressNode>?
        {
        var children = Array<AddressNode>()
        if !self.classPointer.isNil
        {
        for index in 1..<self.classPointer.slots.count
            {
            if self.classPointer.isNil
                {
                children.append(ChildAddressNode(word: self.wordPointer[index]))
                }
            else
                {
                let slot = self.classPointer.slot(atIndex: index)
                let typeCode = slot.typeCode
                if typeCode == 17
                    {
                    children.append(ArrayAddressNode(word: self.wordPointer[index]))
                    }
                else
                    {
                    children.append(ChildAddressNode(word: self.wordPointer[index]))
                    }
                }
            }
        for index in self.classPointer.slots.count..<self.wordCount
            {
            children.append(ChildAddressNode(word: self.wordPointer[index]))
            }
            }
        else
            {
            for index in 1..<self.wordCount
                {
                children.append(ChildAddressNode(word: self.wordPointer[index]))
                }
            }
        return(children)
        }
        
    private let address: Word
    private let header: Header
    private let wordCount: Int
    private let wordPointer:WordPointer
    private let classPointer: InnerClassPointer
    
    init(address: Word)
        {
        self.address = address
        let pointer = WordPointer(address: address)!
        self.wordPointer = pointer
        let header = Header(pointer[0])
        self.wordCount = header.sizeInWords
        self.header = header
        self.classPointer = InnerClassPointer(address: pointer[2])
        }
    }
    
class ArrayAddressNode: AddressNode
    {
    public override var displayString: String
        {
        return("ARRAY: \(self.word.bitString)")
        }
        
    public override var children: Array<AddressNode>?
        {
        var children = Array<AddressNode>()
        for index in 0..<self.arrayPointer.count
            {
            let aWord = self.arrayPointer[index]
            children.append(ChildAddressNode(word: aWord))
            }
        return(children)
        }
        
    public var word: Word
    private let arrayPointer: InnerArrayPointer
    
    init(word: Word)
        {
        self.word = word
        self.arrayPointer = InnerArrayPointer(address: word)
        }
    }

class ChildAddressNode: AddressNode
    {
    public override var displayString: String
        {
        return("CHILD: \(self.word.bitString)")
        }
        
    public var word: Word
    
    init(word: Word)
        {
        self.word = word
        }
    }
