import Foundation

struct ray {
    var origin: vec3
    var direction: vec3
    func point_at_parameter(_ t: Double) -> vec3 {
        return origin + t * direction
    }
}


func color(r:ray) -> vec3 {
    let minusZ = vec3(x:0, y:0, z:-1.0)
    var t = hit_sphere(minusZ, 0.5, r)
    if t > 0.0 {
        let norm = unit_vector(r.point_at_parameter(t) - minusZ)
        return 0.5 * vec3(x: norm.x + 1.0, y: norm.y + 1.0, z: norm.z + 1.0)
    }
    let unit_direction = unit_vector(r.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - t) * vec3(x: 1.0, y: 1.0, z: 1.0) + t * vec3(x: 0.5, y: 0.7, z: 1.0)
}

func hit_sphere(_ center: vec3, _ radius: Double, _ r: ray) -> Double {
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
