//
//  MetalView.swift
//  MetalKitExamples
//
//  Created by Andrew Denisov on 9/7/17.
//

import Foundation
import Metal
import MetalKit

public class MetalView : NSObject, MTKViewDelegate {
    
    public var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var rps: MTLRenderPipelineState!
    var vertexData: [Vertex]?
    var vertexBuffer: MTLBuffer?
    var uniformBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var rotation: Float = 0
    
    public override init() {
        super.init()
        render()
    }
    
    func render() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        makeBuffers(for: device)
        makePipeline(for: device)
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    public func draw(in view: MTKView) {
        update()
        if let rpd = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd),
            let indexBuffer = indexBuffer,
            let vertexBuffer = vertexBuffer,
            let uniformBuffer = uniformBuffer {
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
            commandEncoder.setRenderPipelineState(rps)
            commandEncoder.setFrontFacing(.counterClockwise)
                commandEncoder.setCullMode(.back)
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            commandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indexBuffer.length / MemoryLayout<UInt16>.size,
                indexType: MTLIndexType.uint16,
                indexBuffer: indexBuffer, indexBufferOffset: 0)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    func update() {
        let scaled = scalingMatrix(scale: 0.5)
        rotation += 1 / 100 * Float.pi / 4
        let rotatedY = rotationMatrix(angle: rotation, axis: float3(0, 1, 0))
        let rotatedX = rotationMatrix(angle: Float.pi / 4, axis: float3(1, 0, 0))
        let modelMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
        let cameraPosition = vector_float3(0, 0, -3)
        let viewMatrix = translationMatrix(position: cameraPosition)
        let projMatrix = projectionMatrix(near: 0, far: 10, aspect: 1, fovy: 1)
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        let bufferPointer = uniformBuffer!.contents()
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
    }
}

// Read https://www.scratchapixel.com/lessons/3d-basic-rendering/computing-pixel-coordinates-of-3d-point/mathematics-computing-2d-coordinates-of-3d-points

extension MetalView {
    
    func makeBuffers(for gpuDevice : MTLDevice)  {
        
        let vertexData = [
            Vertex(position: [-1.0, -1.0,  1.0, 1.0], color: [1, 1, 1, 1]),
            Vertex(position: [ 1.0, -1.0,  1.0, 1.0], color: [1, 0, 0, 1]),
            Vertex(position: [ 1.0,  1.0,  1.0, 1.0], color: [1, 1, 0, 1]),
            Vertex(position: [-1.0,  1.0,  1.0, 1.0], color: [0, 1, 0, 1]),
            Vertex(position: [-1.0, -1.0, -1.0, 1.0], color: [0, 0, 1, 1]),
            Vertex(position: [ 1.0, -1.0, -1.0, 1.0], color: [1, 0, 1, 1]),
            Vertex(position: [ 1.0,  1.0, -1.0, 1.0], color: [0, 0, 0, 1]),
            Vertex(position: [-1.0,  1.0, -1.0, 1.0], color: [0, 1, 1, 1])]
        
        let indexData: [UInt16] = [0, 1, 2, 2, 3, 0,   // front
            1, 5, 6, 6, 2, 1,   // right
            3, 2, 6, 6, 7, 3,   // top
            4, 5, 1, 1, 0, 4,   // bottom
            4, 0, 3, 3, 7, 4,   // left
            7, 6, 5, 5, 4, 7]   // back
        
        vertexBuffer = gpuDevice.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.size * vertexData.count, options: [])
        indexBuffer = gpuDevice.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.size * indexData.count , options: [])
        uniformBuffer = gpuDevice.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
    }
    
    func makePipeline(for gpuDevice : MTLDevice) {

        let path = Bundle.main.path(forResource: "Shaders", ofType: "metal")
        let input: String?
        let library: MTLLibrary
        let vert_func: MTLFunction
        let frag_func: MTLFunction
        do {
            input = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            library = try gpuDevice.makeLibrary(source: input!, options: nil)
            vert_func = library.makeFunction(name: "vertex_func")!
            frag_func = library.makeFunction(name: "fragment_func")!
            let rpld = MTLRenderPipelineDescriptor()
            rpld.vertexFunction = vert_func
            rpld.fragmentFunction = frag_func
            rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
            rps = try device!.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            print(error)
        }
    }
}

