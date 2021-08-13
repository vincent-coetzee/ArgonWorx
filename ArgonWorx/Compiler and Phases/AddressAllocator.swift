//
//  AddressAllocator.swift
//  AddressAllocator
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class AddressAllocator
    {
    public static func allocateAddresses(_ node:ParseNode,in compiler: Compiler)
        {
        let allocator = AddressAllocator(compiler: compiler)
        allocator.allocateAddresses(node)
        }
        
    internal let compiler: Compiler
    internal let managedSegment: ManagedSegment = ManagedSegment.shared
    internal let stack = StackSegment(sizeInBytes: 50 * 1024 * 1024)
    internal let fixed = FixedSegment(sizeInBytes: 50 * 1024 * 1024)
    internal let data = DataSegment(sizeInBytes: 50 * 1024 * 1024)
    
    init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    private func allocateAddresses(_ node:ParseNode)
        {
        node.allocateAddresses(using: self)
        }
    }
