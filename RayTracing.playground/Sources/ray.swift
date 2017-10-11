import Foundation
import simd

struct ray {
    var origin: float3
    var direction: float3
    func point_at_parameter(_ t: Float) -> float3 {
        return origin + t * direction
    }
}


struct Camera {
    let lower_left_corner: float3
    let horizontal: float3
    let vertical: float3
    let origin: float3
}

extension Camera {
    
    // Placing camera described there :
    // https://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/lookat-function
    
    init(lookFrom : float3,
         lookAt:float3,
         upVec : float3,
         forward : Float,
         aspect : Float) {
        
        let theta = forward * Float(Double.pi) / 180
        let half_height = tan(theta/2)
        let half_width = aspect * half_height
        
        let w = normalize(lookFrom - lookAt)
        let u = normalize(cross(upVec, w))
        let v = cross(w, u)
        
        // Init basic property
        origin = lookFrom
        lower_left_corner = origin - half_width * u - half_height * v - w
        horizontal = 2 * half_width * u
        vertical = 2 * half_height * v
    }
}

extension Camera {
    
    init() {
        lower_left_corner = float3(x: -2.0, y: 1.0, z: -1.0)
        horizontal = float3(x: 4.0, y: 0, z: 0)
        vertical = float3(x: 0, y: -2.0, z: 0)
        origin = float3()
    }
    
    func getRay(for u: Float, _ v: Float) -> ray {
        return ray(origin: origin, direction: lower_left_corner + u * horizontal + v * vertical - origin);
    }
}


// Depth of reflection is described there:
// https://www.scratchapixel.com/lessons/3d-basic-rendering/introduction-to-shading/reflection-refraction-//fresnel

func color(r: ray, world: Hitable, depth : Int) -> float3 {
    var rec = HitRecord()
    if world.hit(by: r, tmin: 0.001, tmax: Float.infinity, rec: &rec) {
        var scattered = r
        var attenuantion = float3()

        if depth < 50 && rec.material.scatter(rayIn:r,
                                              rec:rec,
                                              attenuation: &attenuantion,
                                              scattered: &scattered) {
            return attenuantion * color(r:scattered,
                                        world:world,
                                        depth:depth + 1)
        } else {
            return float3(x:0, y:0, z:0)
        }
    } else {
        // Calculate background color
        let unit_direction = normalize(r.direction)
        let t = 0.5 * (unit_direction.y + 1)
        return (1.0 - t) * float3(x: 1, y: 1, z: 1) + t * float3(x: 0.5, y: 0.7, z: 1.0)
    }
}

