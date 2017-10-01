import Foundation
import CoreImage
import simd


public func imageFromPixels(width: Int, height: Int) -> CIImage? {
    
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width * height)
    let lower_left_corner = float3(x: -2.0, y: 1.0, z: -1.0)
    let horizontal = float3(x: 4.0, y: 0, z: 0)
    let vertical = float3(x: 0, y: -2.0, z: 0)
    let origin = float3()
    
    // Init scene
    let world = makeWorldScene()
    
    DispatchQueue.concurrentPerform(iterations: width) { i in
        for j in 0..<height {
            
            let u = Float(i) / Float(width)
            let v = Float(j) / Float(height)
            let rayInstanse = ray(origin: origin,
                                  direction: lower_left_corner + u * horizontal + v * vertical)
            let col = color(r: rayInstanse, world: world)
            
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            pixels[i + j * width] = pixel
        }
    }
    
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

func makeWorldScene() -> Hitable {
    let world = HitableList()
    let globalSphere = Sphere(c: float3(x: 0, y: -100.5, z: -1), r: 100)
    world.append(globalSphere)
    let localSphere = Sphere(c: float3(x: 0, y: 0, z: -1), r: 0.5)
    world.append(localSphere)
    return world
}
