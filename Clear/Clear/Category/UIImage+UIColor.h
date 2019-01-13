//
//  UIImage+UIColor.h
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,GradientType){
    topToBottom = 0,//从上到下
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
};

@interface UIImage (UIColor)


/**
 <#Description#>

 @param colors <#colors description#>
 @param size <#size description#>
 @param gradientType <#gradientType description#>
 @return <#return value description#>
 */
+ (UIImage *) imageWithGradientColors:(NSArray*)colors size:(CGSize)size gradientType:(GradientType)gradientType;


/**
 根据颜色生成一张尺寸为1*1的相同颜色图片

 @param color UIColor
 @return UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


@end

NS_ASSUME_NONNULL_END
