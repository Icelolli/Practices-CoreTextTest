//
//  CTDisplayView.swift
//  CoreTextTest
//
//  Created by Li Yuan on 8/27/15.
//  Copyright © 2015 Li Yuan. All rights reserved.
//

import UIKit

func RGB(r:CGFloat, g:CGFloat, b:CGFloat)->UIColor { return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)}

class CTDisplayView: UIView,UIGestureRecognizerDelegate{
    
    var data : CoreTextData? {
        didSet(newData) {
            if let height = data?.height {
                self.height = height
            }
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
    
//    override func drawRect(rect: CGRect) {
//        
//        // 获取上下文
//        let context : CGContextRef = UIGraphicsGetCurrentContext();
//        
//        // 变换坐标系
//        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//        CGContextTranslateCTM(context, 0, self.bounds.size.height);
//        CGContextScaleCTM(context, 1.0, -1.0);
//        
//        // 绘制路径
//        let path : CGMutablePathRef = CGPathCreateMutable();
//        CGPathAddRect(path, nil, self.bounds);
//        
//        
//        // 文字
//        let attString : NSAttributedString = NSAttributedString(string: "Hello World\n创建绘制的区域，CoreText 本身支持各种文字排版的区域\n我们这里简单地将 UIView 的整个界面作为排版的区域。\n为了加深理解，建议读者将该步骤的代码替换成如下代码，\n测试设置不同的绘制区域带来的界面变化。");
//        let framesetter : CTFramesetterRef = CTFramesetterCreateWithAttributedString(attString);
//        let frame : CTFrameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, nil);
//        
//        CTFrameDraw(frame, context);
//                
//    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, self.bounds.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        if (self.data != nil) {
            CTFrameDraw((self.data?.ctFrame)!, context)
        }
    }
    
    func setupEvents() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("user"))
        tapRecognizer.delegate = self;
        self.addGestureRecognizer(tapRecognizer)
        self.userInteractionEnabled = true
        
    }
    
    func userTapGestureDetected(recognizer:UIGestureRecognizer) {
        let point = recognizer.locationInView(self)
        for imageData in (self.data?.imageArray)! {
            let imageRect = imageData.imagePosition
            var imagePosition = imageRect.origin
            imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height
            let rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height)
            // 检测点击位置
            if CGRectContainsPoint(rect, point) {
                print("bingo")
                break;
            }
        }
    }

}
