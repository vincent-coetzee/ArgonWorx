//
//  ArgonStoreFile.swift
//  ArgonStoreFile
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class PageStore
    {
    private static let kStorePath = "/Users/vincent/Desktop/Argon.store"
    
    init()
        {
        }
        
    public func initializeStore(pageCount: Int)
        {
        let fileHandle = fopen(Self.kStorePath,"wb+")
        let blankPage = Page.blankPage
        for index in 0..<pageCount
            {
            blankPage.writeToFile(fileHandle,atIndex: index)
            }
        fclose(fileHandle)
        }
    }
