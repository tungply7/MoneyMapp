//
//  CustomTextField.swift
//  MoneyMapp
//
//  Created by Tung Ly on 6/2/16.
//  Copyright © 2016 Tung Ly. All rights reserved.
//

import Foundation
import UIKit

/** extension to UIColor to allow setting the color
 value by hex value */
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        /** Verify that we have valid values */
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /** Initializes and sets color by hex value */
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
}

class CustomTextField: UITextField {
    
    // MARK: - IBInspectable
    @IBInspectable var tintCol: UIColor = UIColor(netHex: 0x707070)
    @IBInspectable var fontCol: UIColor = UIColor(netHex: 0x707070)
    @IBInspectable var shadowCol: UIColor = UIColor(netHex: 0x707070)
    
    
    // MARK: - Properties
    var textFont = UIFont(name: "Helvetica Neue", size: 14.0)
    
    override func drawRect(rect: CGRect) {
        self.layer.masksToBounds = false
        self.backgroundColor = UIColor(red: 230, green: 230, blue: 230)
        self.layer.cornerRadius = 3.0
        self.tintColor = tintCol
        self.textColor = fontCol
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 255, green: 255, blue: 255).CGColor
        
        if let phText = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: phText, attributes: [NSForegroundColorAttributeName: UIColor(netHex: 0xB3B3B3)])
        }
        
        if let fnt = textFont {
            self.font = fnt
        } else {
            self.font = UIFont(name: "Helvetica Neue", size: 14.0)
        }
    }
    
    // Placeholder text
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
    // Editable text
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
}