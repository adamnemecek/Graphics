//: Playground - noun: a place where people can play

import Cocoa

let width = 200
let height = 100
var pixelSet = makePixelSet(width: width, height)
var image = imageFromPixels(pixels: pixelSet, width: width, height: height)
image
