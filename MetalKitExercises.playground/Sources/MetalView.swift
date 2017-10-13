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
    
    
    struct Vertex {
        var position : vector_float4
        var color : vector_float4
    }
    
    public override init() {
        super.init()
        render()
    }
    
    func render() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        (vertexBuffer,uniformBuffer,indexBuffer) = makeBuffers(for: device)
        registerShaders(for: device)
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    public func draw(in view: MTKView) {
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
}

extension MetalView {
    
    func makeBuffers(for gpuDevice : MTLDevice) -> (MTLBuffer?,MTLBuffer?, MTLBuffer?)  {
         let vertexData = [Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
                           Vertex(position: [ 1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
                           Vertex(position: [ 0.0,  1.0, 0.0, 1.0], color: [0, 0, 1, 1])]
        
        let indexData: [UInt16] = [
            0, 1, 2, 2, 3, 0
        ]
        
        return (gpuDevice.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.size * 3, options:[]),
                device!.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: []),
                gpuDevice.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.size * indexData.count, options:[]))
    }
    
    func registerShaders(for gpuDevice : MTLDevice) {
        let library = gpuDevice.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: "vertex_func")
        let frag_func = library.makeFunction(name: "fragment_func")
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            try rps = gpuDevice.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
             Swift.print("\(error)")
        }
    }
}

