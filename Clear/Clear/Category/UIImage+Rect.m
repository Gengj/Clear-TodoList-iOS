//
//  UIImage+Rect.m
//  Clear
//
//  Created by GMax on 2019/1/13.
//  Copyright © 2019 GAG. All rights reserved.
//

#import "UIImage+Rect.h"

@implementation UIImage (Rect)
//截取部分图像
- (UIImage *)imageByCroppingWithStyle:(GAGCropImageStyle)style
{
    CGRect rect;
    switch (style) {
        case GAGCropImageStyleTop:
            rect = CGRectMake(0, 0, self.size.width, self.size.height  / 2);
            break;
        case GAGCropImageStyleBottom:
            rect = CGRectMake(0, self.size.height / 2, self.size.width, self.size.height / 2);
            break;
        case GAGCropImageStyleLeft:
            rect = CGRectMake(0, 0, self.size.width/2, self.size.height);
            break;
        case GAGCropImageStyleCenter:
            rect = CGRectMake(self.size.width/4, 0, self.size.width/2, self.size.height);
            break;
        case GAGCropImageStyleRight:
            rect = CGRectMake(self.size.width/2, 0, self.size.width/2, self.size.height);
            break;
        case GAGCropImageStyleLeftOneOfThird:
            rect = CGRectMake(0, 0, self.size.width/3, self.size.height);
            break;
        case GAGCropImageStyleCenterOneOfThird:
            rect = CGRectMake(self.size.width/3, 0, self.size.width/3, self.size.height);
            break;
        case GAGCropImageStyleRightOneOfThird:
            rect = CGRectMake(self.size.width/3*2, 0, self.size.width/3, self.size.height);
            break;
        case GAGCropImageStyleLeftQuarter:
            rect = CGRectMake(0, 0, self.size.width/4, self.size.height);
            break;
        case GAGCropImageStyleCenterLeftQuarter:
            rect = CGRectMake(self.size.width/4, 0, self.size.width/4, self.size.height);
            break;
        case GAGCropImageStyleCenterRightQuarter:
            rect = CGRectMake(self.size.width/4*2, 0, self.size.width/4, self.size.height);
            break;
        case GAGCropImageStyleRightQuarter:
            rect = CGRectMake(self.size.width/4*3, 0, self.size.width/4, self.size.height);
            break;
        default:
            break;
    }
    /*
    CGImageRef imageRef = self.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, rect);
    
    
    UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);*/
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));

//    UIGraphicsBeginImageContext(smallBounds.size);
    UIGraphicsBeginImageContextWithOptions(smallBounds.size, NO, [[UIScreen mainScreen] scale]);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@end
