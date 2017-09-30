import Foundation
import CoreImage
import simd

public func makePixelSet(width: Int, _ height: Int) -> [Pixel] {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width * height)
    let lower_left_corner = float3(x: -2.0, y: 1.0, z: -1.0)
    let horizontal = float3(x: 4.0, y: 0, z: 0)
    let vertical = float3(x: 0, y: -2.0, z: 0)
    let origin = float3()
    
    DispatchQueue.concurrentPerform(iterations: width) { i in
        for j in 0..<height {
        
            let u = Float(i) / Float(width)
            let v = Float(j) / Float(height)
            let rayInstanse = ray(origin: origin,
                        direction: lower_left_corner + u * horizontal + v * vertical)
            let col = color(for:rayInstanse)
            
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
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
