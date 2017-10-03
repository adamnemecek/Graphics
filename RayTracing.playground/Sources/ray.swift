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

func color(r: ray, world: Hitable) -> float3 {
    var rec = HitRecord()
    if world.hit(by: r, tmin: 0.001, tmax: Float.infinity, rec: &rec) {
        let target = rec.p + rec.normal + randomInUnitSphere()
        return 0.5 * color(r:ray(origin: rec.p, direction: target - rec.p),
                           world: world)
    } else {
        let unit_direction = normalize(r.direction)
        let t = 0.5 * (unit_direction.y + 1)
        return (1.0 - t) * float3(x: 1, y: 1, z: 1) + t * float3(x: 0.5, y: 0.7, z: 1.0)
    }
}

