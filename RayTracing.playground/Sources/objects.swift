import Foundation
import simd

struct HitRecord {
    var t: Float
    var hitPoint: float3
    var normal: float3
}

extension HitRecord {
    
    init() {
        t = 0.0
        hitPoint = float3(x: 0.0, y: 0.0, z: 0.0)
        normal = float3(x: 0.0, y: 0.0, z: 0.0)
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
    init(c: float3, r: Float) {
        center = c
        radius = r
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

