//
//  RawPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public typealias RawPointer = Word

extension RawPointer
    {
    public var isOptional:Bool
        {
        get
            {
            let mask = Self.kOptionalBits << Self.kOptionalShift
            return(((self & mask) >> Self.kOptionalShift) == 1)
            }
        set
            {
            let value = ((newValue ? 1 : 0) & Self.kOptionalBits) << Self.kOptionalShift
            self = (self & ~(Self.kOptionalBits << Self.kOptionalShift)) | value
            }
        }
    }
