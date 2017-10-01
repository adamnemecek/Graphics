import Foundation
import simd

struct ray {
    var origin: float3
    var direction: float3
    func point_at_parameter(_ t: Float) -> float3 {
        return origin + t * direction
    }
}

func color(r: ray, world: Hitable) -> float3 {
    var rec = HitRecord()
    if world.hit(by: r, tmin: 0.0, tmax: Float.infinity, rec: &rec) {
        return 0.5 * float3(rec.normal.x + 1, rec.normal.y + 1, rec.normal.z + 1);
    } else {
        let unit_direction = normalize(r.direction)
        let t = 0.5 * (unit_direction.y + 1)
        return (1.0 - t) * float3(x: 1, y: 1, z: 1) + t * float3(x: 0.5, y: 0.7, z: 1.0)
    }
}

