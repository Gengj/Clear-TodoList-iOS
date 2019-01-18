//
//  UIView+UIImage.h
//  Clear
//
//  Created by GMax on 2019/1/8.
//  Copyright © 2019 GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (UIImage)

/**
 截图对应的view
 
 @param inputView 输入view
 @return UIImageView
 */
+ (UIImageView *)snapshotUIImageView:(UIView *)inputView;

/**
 截图对应的view
 
 @param inputView 输入view
 @return UIImage
 */
+ (UIImage *)snapshotUIImage:(UIView *)inputView;


@end

NS_ASSUME_NONNULL_END
