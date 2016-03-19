//
//  BaseBrush.swift
//  DrawingBoard
//
//  Created by 张奥 on 15/3/18.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import CoreGraphics

protocol PaintBrush {
    
    func supportedContinuousDrawing() -> Bool
    
    func drawInContext(context: CGContextRef)
}

class BaseBrush : NSObject, PaintBrush {
    var beginPoint: CGPoint!
    var endPoint: CGPoint!
    var lastPoint: CGPoint?
    
    var strokeWidth: CGFloat=1.0;
    
    var force:CGFloat=1.0
    
    var pencilSense:CGFloat=0.8;//pencil灵敏系数
    
    var magnitude: CGFloat {
        return force*strokeWidth*pencilSense;
    };//apple pencil支持,根据压感确定width放大倍数
    
    
    func supportedContinuousDrawing() -> Bool {
        return false
    }
    
    func drawInContext(context: CGContextRef) {
        assert(false, "must implements in subclass.")
    }
}