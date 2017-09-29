import Foundation
import Cocoa
import simd


public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8

    init(red: UInt8, green: UInt8, blue: UInt8) {
        r = red
        g = green
        b = blue
        a = 255
    }
}

