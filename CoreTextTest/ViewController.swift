//
//  ViewController.swift
//  CoreTextTest
//
//  Created by Li Yuan on 8/27/15.
//  Copyright © 2015 Li Yuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        ctView.frame = CGRectMake(30, 50, 300, 0)
        self.view.addSubview(ctView)
    }

    var ctView: CTDisplayView = CTDisplayView();
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let config : CTConfigure = CTConfigure()
//        config.width = self.ctView.frame.width
//        config.textColor = UIColor.blackColor()
//        let content : String = " 对于上面的例子，我们给 CTFrameParser 增加了一个将 NSString 转" +
//                                " 换为 CoreTextData 的方法。" +
//                                " 但这样的实现方式有很多局限性，因为整个内容虽然可以定制字体 " +
//                                " 大小，颜色，行高等信息，但是却不能支持定制内容中的某一部分。" +
//                                " 例如，如果我们只想让内容的前三个字显示成红色，而其它文字显 " +
//                                " 示成黑色，那么就办不到了。" +
//                                "\n\n" +
//                                " 解决的办法很简单，我们让`CTFrameParser`支持接受 " +
//                                "NSAttributeString 作为参数，然后在 NSAttributeString 中设置好 " +
//                                " 我们想要的信息。"
//        
//        let attr : [String : AnyObject!] = CTFrameParser.attributesWithConfig(config)
//        let attrString : NSMutableAttributedString = NSMutableAttributedString(string: content, attributes: attr)
//        attrString .addAttributes([NSForegroundColorAttributeName:UIColor.redColor()], range: NSMakeRange(0, 7))
//        
//        let data : CoreTextData = CTFrameParser.parseAttributedContent(attrString, config: config)
        
        
        let config : CTConfigure = CTConfigure()
        config.width = self.ctView.width
        let path : String? = NSBundle.mainBundle().pathForResource("data", ofType: "json")
        let data : CoreTextData? = CTFrameParser.parseTemplateFile(path, config: config)
        
        self.ctView.data = data
        self.ctView.backgroundColor = UIColor.yellowColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

