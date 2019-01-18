//
//  GAGStrikethroughTextField.h
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

//需要改进的地方
//可以通过NSAttributedString设置删除线，就避免了layer的概念，不过可能没有动画
//NSAttributedString *attrStr = [[NSAttributedString alloc]
//initWithString:_model.originPrice
//attributes:@{
//             NSFontAttributeName:[UIFont systemFontOfSize:20.f],
//             NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#5bcec0"],
//             NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid),
//             NSStrikethroughColorAttributeName:[UIColor colorWithHexString:@"#5bcec0"]}];
//self.orginPriceLabel.attributedText = attrStr;
//
//作者：lance017
//链接：https://www.jianshu.com/p/207e2c0a64b2
//來源：简书
//简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GAGStrikethroughTextField : UITextField

@property(nonatomic,assign) BOOL strikethrough;
// default is YES

@end

NS_ASSUME_NONNULL_END
