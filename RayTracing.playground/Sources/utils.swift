import Foundation
import CoreImage

public func makePixelSet(width: Int, _ height: Int) -> [Pixel] {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width * height)
    
    DispatchQueue.concurrentPerform(iterations: width) { i in
        for j in 0..<height {
        
            pixel = Pixel(red: 0,
                          green: UInt8(Double(i * 255 / width)),
                          blue: UInt8(Double(j * 255 / height)))
            
            pixels[i + j * width] = pixel
        }
    }
    
    return pixels
}

public func imageFromPixels(pixels: [Pixel], width: Int, height: Int) -> CIImage? {
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let providerRef = CGDataProvider(data:NSData(bytes: pixels,
                                                       length: pixels.count * MemoryLayout<Pixel>.size))
        else { return nil }
    
    let image = CGImage(width: width,
                        height: height,
                        bitsPerComponent: bitsPerComponent,
                        bitsPerPixel: bitsPerPixel,
                        bytesPerRow: width * MemoryLayout<Pixel>.size,
                        space: rgbColorSpace,
                        bitmapInfo: bitmapInfo,
                        provider: providerRef,
                        decode: nil,
                        shouldInterpolate: true,
                        intent: .defaultIntent)
    
    return CIImage(cgImage: image!)
}
