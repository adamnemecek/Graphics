import Foundation
import CoreImage
import simd


public func imageFromPixels(width: Int, height: Int) -> CIImage? {
    
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width * height)
    
    // Init camera
    let camera = makeCamera(width:width, height : height)
    
    // Init scene
    let world = HitableList()
    hitableObjects().forEach { world.append($0) }
    
    let ns = 100
    
    DispatchQueue.concurrentPerform(iterations: width) { i in
        for j in 0..<height {
    
            var col = float3()
            for _ in 0..<ns {
                let u = (Float(i) + 0.5*Float(drand48())) / Float(width)
                let v = (Float(j) + 0.5*Float(drand48())) / Float(height)
                let ray = camera.getRay(for:u, v)
                col += color(r: ray, world: world, depth : 5)
            }
            
            col /= float3(Float(ns))
            
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

func makeCamera(width:Int, height:Int) -> Camera {
    // Init camera
    let lookFrom = float3(0, 1, -4)
    let lookAt = float3()
    let vup = float3(0, -1, 0)
    let camera = Camera(lookFrom: lookFrom,
                        lookAt: lookAt,
                        upVec: vup,
                        forward: 50,
                        aspect: Float(width) / Float(height))
    return camera
}


func hitableObjects() -> [Hitable] {
    let globalSphere = Sphere(center: float3(x: 0, y: -100.5, z: -1),
                              radius: 100,
                              material: LambertianSurface(a: float3(x: 0.1, y: 0.7, z: 0.3)))
    
    let localSphere = Sphere(center: float3(x: 0, y: 0, z: -1),
                             radius: 0.5,
                             material: MetalSurface(albedo: float3(x: 0.8, y: 0.6, z: 0.2),
                                                    fuzz: 0.7))
    
    let anotherLocalSphere = Sphere(center:float3(x: -1, y: 0, z: -1),
                                    radius:0.7,
                                    material : DielectricSurface())
    
    return [globalSphere, localSphere, anotherLocalSphere]
}
