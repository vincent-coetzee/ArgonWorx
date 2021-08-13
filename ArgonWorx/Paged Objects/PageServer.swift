//
//  PageServer.swift
//  PageServer
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class PageServer
    {
    private static let kPageBitCount = 14
    private static let kMaximumPageCount =  (1 << kPageBitCount) - 1
    
    private var pages: Array<Page?>
    
    init()
        {
        self.pages = Array(repeating: nil,count:  Self.kMaximumPageCount)
        self.loadMasterPage()
        self.loadMasterCatalogue()
        self.initPageFaultHandler()
        }
        
    private func loadMasterPage()
        {
        }
        
    private func loadMasterCatalogue()
        {
        }
        
    private func initPageFaultHandler()
        {
        }
    }
