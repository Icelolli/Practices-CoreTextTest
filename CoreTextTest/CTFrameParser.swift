//
//  CTFrameParser.swift
//  CoreTextTest
//
//  Created by Li Yuan on 8/27/15.
//  Copyright © 2015 Li Yuan. All rights reserved.
//

import UIKit

var A : [Dictionary<String, AnyObject>]!;

extension UIView{
    var width : CGFloat {
        get {
            return self.frame.size.width
        }
        set(newWidth) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height)
        }
    }
    
    var height : CGFloat {
        get {
            return self.frame.size.height
        }
        set(newHeight) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight)
        }
    }
}

class CTFrameParser: NSObject {
    
    // 解析文本配置，封装成CoreTextData 模型
    class func parseContent(content:String,config:CTConfigure)->CoreTextData? {
        let attributes = self.attributesWithConfig(config);
        let contentString = NSAttributedString(string: content, attributes: attributes);
        
        
        let framesetter = CTFramesetterCreateWithAttributedString(contentString);
        
        // 获得绘制区域高度
        let restrictSize = CGSizeMake(config.width, CGFloat.max);
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
        let textHeight = coreTextSize.height;
        
        // 生成 CTFrameRef 实例
        let frame : CTFrameRef = self.createFrameWithFramesetter(framesetter, config: config, height: textHeight);
        
        // 存数结果到CoreTextData 中
        let data : CoreTextData = CoreTextData();
        data.ctFrame = frame;
        data.height = textHeight;
        
        return nil;
    }

    // 从配置模型中获取样式列表
    class func attributesWithConfig(config:CTConfigure) -> [String : AnyObject]{
        let fontSize : CGFloat = config.fontSize;
        let fontRef : CTFontRef = CTFontCreateWithName("ArialMT", fontSize, nil);
        var lineSpacing : CGFloat = config.lineSpace;
        let kNumberOfSettings : CFIndex = 3;
        
        let theSettings : [CTParagraphStyleSetting] = [
            CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.LineSpacingAdjustment, valueSize: sizeof(CGFloat), value: &lineSpacing),
            CTParagraphStyleSetting( spec: CTParagraphStyleSpecifier.MaximumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing ),
            CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.MinimumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing )];
        let theParagraphRef : CTParagraphStyleRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings)
        let textColr = config.textColor
        var dic  = [String: AnyObject]();
        
        dic.updateValue(textColr, forKey: NSForegroundColorAttributeName)
        dic.updateValue(fontRef, forKey: NSFontAttributeName)
        dic.updateValue(theParagraphRef, forKey: NSParagraphStyleAttributeName)
        return dic;
    }
    
    // 创建CTFrame
    class func createFrameWithFramesetter(framesetter:CTFramesetterRef,config:CTConfigure,height:CGFloat) -> CTFrameRef {
        let path : CGMutablePathRef = CGPathCreateMutable();
        CGPathAddRect(path, nil, CGRectMake(0, 0, config.width, height));
        let frame : CTFrameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
        return frame;
    }
    
    class func parseAttributedContent(content:NSAttributedString,config : CTConfigure)->CoreTextData {
        let framesetter : CTFramesetterRef = CTFramesetterCreateWithAttributedString(content)
        
        let restrictSize : CGSize = CGSizeMake(config.width, CGFloat.max)
        let coreTextSize : CGSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil)
        let textHeight : CGFloat = coreTextSize.height
        
        
        // 生成 CTFrameRef 实例
        let frame : CTFrameRef = self.createFrameWithFramesetter(framesetter, config: config, height: textHeight)
        
        let data : CoreTextData = CoreTextData();
        data.ctFrame = frame
        data.height = textHeight
        
        return data
    }
    
    // 解析模板文件
    class func parseTemplateFile(path : String?, config : CTConfigure) -> CoreTextData? {
        var imageArray : Array<CoreTextImageData> = Array<CoreTextImageData>()
        var linkArray : Array<CoreTextLinkData> = Array<CoreTextLinkData>()
        let content : NSAttributedString = self.loadTemplateFile(path,config: config,imageArray:&imageArray,linkArray: &linkArray)
        let data : CoreTextData = self.parseAttributedContent(content, config: config)
        data.imageArray = imageArray
        return data
    }
    
    // 加载模板文件
    class func loadTemplateFile(path:String?,
                                config:CTConfigure,
                        inout imageArray:[CoreTextImageData],
                        inout linkArray:[CoreTextLinkData]) -> NSAttributedString {
        let data : NSData? = NSData(contentsOfFile: path!)
        let result : NSMutableAttributedString = NSMutableAttributedString()
        if (data != nil) {
            let array : AnyObject?
            do {
                array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            } catch {
                array = nil
            }
            if (array!.isKindOfClass(NSArray)) {
                A = array! as! [Dictionary<String, AnyObject>]
                for dict in array as! [Dictionary<String, AnyObject>] {
                    let type : String = dict["type"] as! String
                    switch type {
                    case "txt":
                        let attributedStr = self.parseAttributedCotnentFromDictionary(dict, config: config)
                        if attributedStr != nil {
                            result.appendAttributedString(attributedStr!)
                        }
                        break
                    case "img" :
                        let imageData = CoreTextImageData()
                        imageData.name = (dict["name"] as! String?)
                        imageData.position = result.length
                        imageArray.append(imageData)
                        let attributedStr : NSAttributedString = self.parseImageDataFromNSDictionary(dict, config: config)
                        result .appendAttributedString(attributedStr)
                        break;
                    case "link" :
                        let startPos = result.length
                        if let attributedStr = self.parseAttributedCotnentFromDictionary(dict, config: config) {
                            result.appendAttributedString(attributedStr)
                            let length = result.length - startPos
                            let linkRange = CFRangeMake(startPos, length)
                            let linkData : CoreTextLinkData = CoreTextLinkData()
                            linkData.title = dict["content"] as! String
                            linkData.url = dict["url"] as! String
                            linkData.range = linkRange
                            linkArray.append(linkData)
                        }
                    default :
                        
                        break
                    }
                    
                }
            }
        }
        return result
    }
    
    // 从字典中解析属性文字
    class func parseAttributedCotnentFromDictionary(dict : Dictionary<String,AnyObject>?,config : CTConfigure)->NSAttributedString? {
        if dict == nil {return nil};
        var attributes = self.attributesWithConfig(config)
        // 设置颜色
        let color : UIColor? = self.colorFromTemplate(dict!["color"] as! String?)
        if color != nil {
            attributes[NSForegroundColorAttributeName] = color!
        }
        // 设置字体
        
        let fontSize = dict!["size"]?.floatValue
        if fontSize > 0 {
            let fontRef: CTFontRef = CTFontCreateWithName("ArialMT" as CFString, CGFloat(fontSize!), nil)
            attributes[NSFontAttributeName] = fontRef
        }
        if let content = dict!["content"] {
            return NSAttributedString(string: content as! String, attributes: attributes)
        } else {
            return nil
        }
    }
    
    //MARK: C functions
    
    
    
    class func parseImageDataFromNSDictionary(var dict:[String:AnyObject],config:CTConfigure) -> NSAttributedString {
        
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1,
                                                dealloc: deallocCallBack,
                                                getAscent: ascentCallback,
                                                getDescent: descentCallback,
                                                getWidth: widthCallback)
        
        let dictMPointer = withUnsafeMutablePointer(&dict) {UnsafeMutablePointer<[String:AnyObject]>($0)}
        let funcPointer = withUnsafePointer(&callbacks) {UnsafePointer<CTRunDelegateCallbacks>($0)}
        
        let dict22 : [String : AnyObject] = UnsafePointer<[String : AnyObject]>(dictMPointer).memory
//        var intPtr = unsafeBitCast(voidPtr, UnsafePointer<Int>.self)
//        intPtr.memory //100
        
//        if let dict : [String:AnyObject] = unsafeBitCast(dictMPointer, [String:AnyObject].self) {
//            //        if let height = dict["height"]?.floatValue {
//            //            return CGFloat(height)
//            //        }
//        }
        
        // CTRunDelegateCreate的第二个参数会作为每一个回调调用时的入参
        let delegate : CTRunDelegateRef? = CTRunDelegateCreate(funcPointer, dictMPointer)
        let replaceChar = 0xFFFC
        let content = String(replaceChar)
        let attributes : Dictionary = self.attributesWithConfig(config)
        let space = NSMutableAttributedString(string: content, attributes: attributes)
        
        CFAttributedStringSetAttribute(space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate)
        return space;
    }

    
    
    
    //MARK:
    // 获取颜色
    class func colorFromTemplate(name:String?) -> UIColor? {
        switch name! {
            case "blue":
                return UIColor.blueColor()
            case "red":
                return UIColor.redColor()
            case "black":
                return UIColor.blackColor()
            case "default":
                return nil
            default:
                return nil
        }
    }
}

func deallocCallBack(ref : UnsafeMutablePointer<Void>) -> Void {
    
}

func ascentCallback(ref : UnsafeMutablePointer<Void>) -> CGFloat {
//    if ref == nil {return 0}
//    let dict : [String : AnyObject] = UnsafePointer<[String : AnyObject]>(ref).memory
//    if let height = dict["height"]?.floatValue {
//        return CGFloat(height)
//    }
    return 0
}

func descentCallback(ref : UnsafeMutablePointer<Void>) -> CGFloat {
    return 0;
}

func widthCallback(ref : UnsafeMutablePointer<Void>) -> CGFloat {
//    if ref == nil {return 0}
//    let dict : [String : AnyObject] = UnsafePointer<[String : AnyObject]>(ref).memory
//    if let width = dict["width"]?.floatValue {
//        return CGFloat(width)
//    }
    return 0
}
