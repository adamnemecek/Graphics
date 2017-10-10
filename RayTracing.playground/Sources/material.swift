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
    
    init(albedo: float3, fuzz: Float) {
        self.albedo = albedo
        self.fuzz = fuzz < 1 ? fuzz : 1
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


struct DielectricSurface : MateriaSurface {
    
    func scatter(rayIn: ray, rec: HitRecord,
                 attenuation: inout float3,
                 scattered:inout ray) -> Bool {
        
        let refractionIndex: Float = 1.3
        let reflected = reflect(rayIn.direction, n: rec.normal)
        attenuation = float3(1, 1, 1)
        
        if let refracted = refract(v:rayIn.direction,
                                n: rec.normal,
                                refractionIndex : refractionIndex) {
            scattered = ray(origin: rec.hitPoint, direction: refracted)
        } else {
            scattered = ray(origin: rec.hitPoint, direction: reflected)
            return false
        }
        
        return true
    }
}

extension DielectricSurface {
    
    func refract(v: float3, n: float3, refractionIndex: Float) -> float3? {
        let uv = normalize(v)
        let dt = dot(uv, n)
        
        var etai : Float = 1.0
        var etat = refractionIndex
        var N = n
        
        var cosI = clamp(value: dt,
                         lower: -1,
                         upper: 1)
        if cosI < 0 {
            cosI = -cosI
        } else {
            (etai, etat) = (etat, etai)
            N = -n
        }
        
        let eta = etai/etat
        
        let discriminant = 1.0 - eta * eta * (1.0 - dt * dt)
        // If discriminant < 0, we have total internal reflection,
        // there is no refraction in this case
        if discriminant > 0 {
            return eta * (uv - N * dt) - N * sqrt(discriminant)
        }
        return nil
    }
    
    func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }
    
    func schlick(cosine: Float, _ index: Float) -> Float {
        var r0 = (1 - index) / (1 + index)
        r0 = r0 * r0
        return r0 + (1 - r0) * powf(1 - cosine, 5)
    }
}

