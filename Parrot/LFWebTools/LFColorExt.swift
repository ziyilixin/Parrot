import UIKit

extension UIColor {
    
    // MARK: - hex (0x000000) -> UIColor
    ///
    /// - Parameter hex (0x000000)
    /// - Returns: UIColor
    class func lf_hex(hex: String) -> UIColor {
       var alpha, red, blue, green: CGFloat
       let colorString = hex.replacingOccurrences(of: "#", with: "")
       switch colorString.count {
       case 3: // #RGB
           alpha = 1.0
           red = colorComponent(hex: colorString, start: 0, length: 1)
           green = colorComponent(hex: colorString, start: 1, length: 1)
           blue = colorComponent(hex: colorString, start: 2, length: 1)
       case 4: // #ARGB
           alpha = colorComponent(hex: colorString, start: 0, length: 1)
           red = colorComponent(hex: colorString, start: 1, length: 1)
           green = colorComponent(hex: colorString, start: 2, length: 1)
           blue = colorComponent(hex: colorString, start: 3, length: 1)
       case 6: // #RRGGBB
           alpha = 1.0
           red = colorComponent(hex: colorString, start: 0, length: 2)
           green = colorComponent(hex: colorString, start: 2, length: 2)
           blue = colorComponent(hex: colorString, start: 4, length: 2)
       case 8: // #AARRGGBB
           alpha = colorComponent(hex: colorString, start: 0, length: 2)
           red = colorComponent(hex: colorString, start: 2, length: 2)
           green = colorComponent(hex: colorString, start: 4, length: 2)
           blue = colorComponent(hex: colorString, start: 6, length: 2)
       default:
           alpha =  0
           red = 0
           green = 0
           blue = 0
       }
       return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    private class func colorComponent(hex: String, start: Int, length: Int) -> CGFloat {
       let subString = hex.sliceString(start..<(start + length))
       let fullHex = length == 2 ? subString : (subString + subString)
       var val: CUnsignedInt = 0
       Scanner(string: fullHex).scanHexInt32(&val)
       return CGFloat(val) / 255.0
    }
}


