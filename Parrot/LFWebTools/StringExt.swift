//
//  StringExt.swift
//  swift_web_kit
//
//  Created by Chen on 2025/9/3.
//

import Foundation

extension String {
    var isNotEmpty : Bool {
       return !self.isEmpty
    }
    func sliceString(_ range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
