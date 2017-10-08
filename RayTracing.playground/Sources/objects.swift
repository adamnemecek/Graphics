import Foundation
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

struct HitRecord {
    var t: Float
    var hitPoint: float3
    var normal: float3
    var material: MateriaSurface
}

extension HitRecord {
    
    init() {
        t = 0.0
        hitPoint = float3(x: 0.0, y: 0.0, z: 0.0)
        normal = float3(x: 0.0, y: 0.0, z: 0.0)
        material = MetalSurface(a: float3(), f: Float())
    }
}

protocol Hitable {
    func hit(by ray: ray, tmin: Float, tmax: Float, rec: inout HitRecord) -> Bool
}


class HitableList {
    var list : [Hitable] = []
    
    func append(_ hitableInst : Hitable) {
        self.list.append(hitableInst)
    }
}

extension HitableList : Hitable {
    
    func hit(by ray: ray, tmin: Float, tmax: Float, rec: inout HitRecord) -> Bool {
        let itemsThatHits = list.filter { $0.hit(by: ray, tmin: tmin, tmax: tmax, rec: &rec) }
        return (itemsThatHits.count > 0)
    }
}


class Sphere  {
    var center = float3(x: 0.0, y: 0.0, z: 0.0)
    var radius = Float(0.0)
    var material : MateriaSurface
    
    init(center: float3, radius: Float, material : MateriaSurface ) {
        self.center = center
        self.radius = radius
        self.material = material
    }
}

extension Sphere : Hitable {
    
    internal func hit(by r: ray, tmin: Float, tmax: Float, rec: inout HitRecord) -> Bool {
        let oc = r.origin - center
        let a = dot(r.direction, r.direction)
        let b = dot(oc, r.direction)
        let c = dot(oc, oc) - radius*radius
        let discriminant = b*b - a*c
        
        if discriminant > 0 {
            var t = (-b - sqrt(discriminant) ) / a
            if t < tmin {
                t = (-b + sqrt(discriminant) ) / a
            }
            if tmin < t && t < tmax {
                rec.t = t
                rec.hitPoint = r.point_at_parameter(rec.t)
                rec.normal = (rec.hitPoint - center) / float3(radius)
                rec.material = self.material
                return true
            }
        }
        return false
    }
}


func randomInUnitSphere() ->  float3 {
    var p = float3()
    repeat {
        p = 2 * float3(x: Float(drand48()),
                       y: Float(drand48()),
                       z: Float(drand48())) - float3(x: 1, y: 1, z: 1)
    } while dot(p, p) >= 1.0
    
    return p
}

