//
//  UIView+UIImage.m
//  Clear
//
//  Created by GMax on 2019/1/8.
//  Copyright © 2019 GAG. All rights reserved.
//

#import "UIView+UIImage.h"

@implementation UIView (UIImage)

/**
 截图对应的view

 @param inputView 输入view
 @return UIImageView
 */
+ (UIImageView *)snapshotUIImageView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIImageView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

/**
 截图对应的view成为上下两张imageView
 
 @param inputView 输入view
 @return NSArray of UIImageViews

+ (NSArray<UIImageView *> *)snapshotUIImageViews:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *firstImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0,0,image.size.width,image.size.height * 0.5))];
    UIImage *secondImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0,image.size.height * 0.5,image.size.width,image.size.height * 0.5))];

    // Create firstImageView.
    UIImageView *firstImageView = [[UIImageView alloc] initWithImage:firstImage];
    firstImageView.center = CGPointMake(inputView.center.x, inputView.center.y * 0.25);
    firstImageView.layer.masksToBounds = NO;
    firstImageView.layer.cornerRadius = 0.0;
    firstImageView.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    firstImageView.layer.shadowRadius = 5.0;
    firstImageView.layer.shadowOpacity = 0.4;
    
    // Create an image view.
    UIImageView *secondImageView = [[UIImageView alloc] initWithImage:secondImage];
    secondImageView.center = CGPointMake(inputView.center.x, inputView.center.y * 0.75);
    secondImageView.layer.masksToBounds = NO;
    secondImageView.layer.cornerRadius = 0.0;
    secondImageView.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    secondImageView.layer.shadowRadius = 5.0;
    secondImageView.layer.shadowOpacity = 0.4;
    return  @[firstImageView,secondImageView];
}
 */
/**
 截图对应的view
 
 @param inputView 输入view
 @return UIImage
 */
+ (UIImage *)snapshotUIImage:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
@end
