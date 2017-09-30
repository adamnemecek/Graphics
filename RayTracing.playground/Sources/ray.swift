import Foundation
import simd

struct ray {
    var origin: float3
    var direction: float3
    func point_at_parameter(_ t: Float) -> float3 {
        return origin + t * direction
    }
}


func color(for r:ray) -> float3 {
    let minusZ = float3(x:0, y:0, z: -1.0)
    var t = hit_sphere(minusZ, 0.5, r)
    if t > 0.0 {
        let norm = normalize(r.point_at_parameter(t) - minusZ)
        return 0.5 * float3(x: norm.x + 1.0, y: norm.y + 1.0, z: norm.z + 1.0)
    }
    let unit_direction = normalize(r.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - t) * float3(x: 1.0, y: 1.0, z: 1.0) + t * float3(x: 0.5, y: 0.7, z: 1.0)
}

func hit_sphere(_ center: float3, _ radius: Float, _ r: ray) -> Float {
    let oc = r.origin - center
    let a = dot(r.direction, r.direction)
    let b = 2.0 * dot(oc, r.direction)
    let c = dot(oc, oc) - radius * radius
    let discriminant = b * b - 4 * a * c
    if discriminant < 0 {
        return -1.0
    } else {
        return (-b - sqrt(discriminant)) / (2.0 * a)
    }
}
