//
//  CoreTextData.swift
//  CoreTextTest
//
//  Created by Li Yuan on 8/27/15.
//  Copyright © 2015 Li Yuan. All rights reserved.
//

import UIKit

class CoreTextData: NSObject {
    
    var ctFrame : CTFrameRef?
    var height : CGFloat = 0
    var imageArray : Array<CoreTextImageData> = Array<CoreTextImageData>() {
        didSet (newImageArray){
            
        }
    }
    
    func fillImagePosition() {
        if self.imageArray.isEmpty {
            return;
        }
        
        
        if self.ctFrame == nil {
            return;
        }
        
        let lines : NSArray = CTFrameGetLines(self.ctFrame!)
        let lineCount = lines.count
        var lineOrigins = UnsafeMutablePointer<CGPoint>.alloc(lineCount)
        CTFrameGetLineOrigins(self.ctFrame!, CFRangeMake(0, 0), lineOrigins)
        
        var imgIndex : Int = 0
        var imageData : CoreTextImageData? = self.imageArray[0]
        for var index = 0 ; index < lineCount ; ++index {
            let line : CTLineRef = lines[0] as! CTLineRef
            let runObjArray : NSArray = CTLineGetGlyphRuns(line)
            for runObj in runObjArray  {
                let run = runObj as! CTRunRef
                let runAttributes : NSDictionary = CTRunGetAttributes(run)
                let delegate = runAttributes["kCTRunDelegateAttributeName"] as! CTRunDelegateRef?
                if delegate == nil {
                    continue
                }
                
                let dicMPoint : UnsafeMutablePointer<Void> = CTRunDelegateGetRefCon(delegate!)
                if dicMPoint == nil {
                    continue
                }
                let metaDic = unsafeBitCast(dicMPoint, NSDictionary.self)
                if !metaDic.isKindOfClass(NSDictionary) {
                    continue;
                }
                
                var runBounds : CGRect
                let ascent : CGFloat = 0
                let descent : CGFloat = 0
                runBounds = CGRect()
                runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil))
                runBounds.size.height = ascent + descent
                
                let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                runBounds.origin.x = lineOrigins[index].x + xOffset
                runBounds.origin.y = lineOrigins[index].y
                runBounds.origin.y = descent
                
                let pathRef = CTFrameGetPath(self.ctFrame!)
                let colRect = CGPathGetBoundingBox(pathRef)
                
                let delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y)
                
                imageData!.imagePosition = delegateBounds
                imgIndex++
                if imgIndex == self.imageArray.count {
                    imageData = nil
                    break
                } else {
                    imageData = self.imageArray[imgIndex]
                }
                
                
            }
        }
        
        
    }
}
