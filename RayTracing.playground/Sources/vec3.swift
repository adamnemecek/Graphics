import Foundation

public struct vec3 {
    var x = 0.0
    var y = 0.0
    var z = 0.0
}

func * (left: Double, right: vec3) -> vec3 {
    return vec3(x: left * right.x, y: left * right.y, z: left * right.z)
}

func + (left: vec3, right: vec3) -> vec3 {
    return vec3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func - (left: vec3, right: vec3) -> vec3 {
    return vec3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

func dot (_ left: vec3, _ right: vec3) -> Double {
    return left.x * right.x + left.y * right.y + left.z * right.z
}

func unit_vector(_ v: vec3) -> vec3 {
    let length : Double = sqrt(dot(v, v))
    return vec3(x: v.x/length, y: v.y/length, z: v.z/length)
}
