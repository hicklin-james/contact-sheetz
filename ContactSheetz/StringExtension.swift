//
//  StringExtension.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2017-08-22.
//  Copyright © 2017 James Hicklin. All rights reserved.
//

import Foundation

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
