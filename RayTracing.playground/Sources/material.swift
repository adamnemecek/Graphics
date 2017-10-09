import Foundation
import simd

protocol MateriaSurface {
    func scatter(rayIn: ray, rec: HitRecord,
                 attenuation: inout float3,
                 scattered:inout ray) -> Bool
}

class LambertianSurface: MateriaSurface {
    var albedo: float3
    init(a: float3) {
        albedo = a
    }
    
    func scatter(rayIn: ray, rec: HitRecord,
                 attenuation: inout float3,
                 scattered:inout ray) -> Bool {
        let target = rec.hitPoint + rec.normal + randomInUnitSphere()
        scattered = ray(origin: rec.hitPoint, direction: target - rec.hitPoint)
        attenuation = albedo
        return true
    }
}


class MetalSurface : MateriaSurface {
    var albedo: float3
    var fuzz: Float
    
    init(a: float3, f: Float) {
        albedo = a
        if f < 1 {
            fuzz = f
        } else {
            fuzz = 1
        }
    }
    
    func scatter(rayIn: ray, rec: HitRecord,
                 attenuation: inout float3,
                 scattered:inout ray) -> Bool {
        let reflected = reflect(normalize(rayIn.direction), n: rec.normal)
        scattered = ray(origin: rec.hitPoint, direction: reflected + fuzz * randomInUnitSphere())
        attenuation = albedo
        return dot(scattered.direction, rec.normal) > 0
    }
}


struct Dielectric : MateriaSurface {
    
    
    func scatter(rayIn: ray, rec: HitRecord,
                 attenuation: inout float3,
                 scattered:inout ray) -> Bool {
        
        return true
    }
}

