//
//  Page.swift
//  Page
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class Page
    {
    public static let blankPage = Page().allocate().initializePage()
    
    private static let kPageSizeInBytes = 16 * 1024 * 1024
    private static let kPageAlignmentInBytes = 16 * 1024 * 1024
    private static let kPageSizeOffset = 0
    private static let kSizeRemainingOffset = 8
    private static let kFreePointerOffset = 16
    private static let kNextPagePointerOffset = 24
    private static let kBookeepingSizeInBytes = 48
    
    private var nextFreeOffset: Word
        {
        get
            {
            return(self.word(atOffset: Self.kFreePointerOffset))
            }
        set
            {
            self.setWord(newValue,atOffset: Self.kFreePointerOffset)
            }
        }
        
    private var memory: UnsafeMutableRawPointer
    public  var wordPointer: WordPointer
    private var isMapped: Bool = false
    private var isAllocated: Bool = false
        
    init()
        {
        self.memory = UnsafeMutableRawPointer(bitPattern: 100)!
        self.wordPointer = WordPointer(address: 100)!
        }
        
    public func allocate() -> Self
        {
        self.memory = UnsafeMutableRawPointer.allocate(byteCount: Self.kPageSizeInBytes, alignment: Self.kPageAlignmentInBytes)
        self.isAllocated = true
        let address = Word(Int(bitPattern: self.memory))
        self.wordPointer = WordPointer(address: address)!
        print("Address of aligned page memory is \(address.addressString) \(address.bitString)")
        return(self)
        }
        
    public func initializePage() -> Self
        {
        memset(self.memory,0,Self.kPageSizeInBytes)
        self.setWord(Word(Self.kPageSizeInBytes),atOffset: Self.kPageSizeOffset)
        self.setWord(Word(Self.kPageSizeInBytes - Self.kBookeepingSizeInBytes),atOffset: Self.kSizeRemainingOffset)
        self.setWord(Word(Self.kBookeepingSizeInBytes),atOffset: Self.kFreePointerOffset)
        self.setWord(0,atOffset: Self.kNextPagePointerOffset)
        return(self)
        }
        
    @inline(__always)
    @inlinable
    public func word(atOffset: Int) -> Word
        {
        return(self.wordPointer[atOffset / 8])
        }
        
    @inline(__always)
    @inlinable
    public func setWord(_ word: Word,atOffset: Int)
        {
        self.wordPointer[atOffset / 8] = word
        }
        
    public func writeToFile(_ handle:UnsafeMutablePointer<FILE>?,atIndex: Int)
        {
        let offset = atIndex * Self.kPageSizeInBytes
        fseek(handle,offset,SEEK_SET)
        fwrite(self.memory,1,Self.kPageSizeInBytes,handle)
        }
        
    public func allocateObject(ofClass pointer: InnerClassPointer) -> Word
        {
        let address = self.nextFreeOffset
        self.nextFreeOffset += Word(pointer.instanceSizeInBytes)
        let objectPointer = WordPointer(address: address)!
        var header = Header(0)
        header.sizeInWords = pointer.instanceSizeInWords
        header.flipCount = 0
        header.isForwarded = false
        header.hasBytes = false
        header.typeCode = pointer.typeCode
        objectPointer[0] = header
        objectPointer[1] = Word(bitPattern: pointer.magicNumber)
        objectPointer[2] = pointer.address
        return(address)
        }
    }
