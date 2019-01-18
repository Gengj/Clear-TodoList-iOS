//
//  UIImage+Rect.h
//  Clear
//
//  Created by GMax on 2019/1/13.
//  Copyright © 2019 GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GAGCropImageStyle){
    GAGCropImageStyleTop                     =0,
    GAGCropImageStyleBottom                  =1,
    GAGCropImageStyleRight                   =2,   // 右半部分
    GAGCropImageStyleCenter                  =3,   // 中间部分
    GAGCropImageStyleLeft                    =4,   // 左半部分
    GAGCropImageStyleRightOneOfThird         =5,   // 右侧三分之一部分
    GAGCropImageStyleCenterOneOfThird        =6,   // 中间三分之一部分
    GAGCropImageStyleLeftOneOfThird          =7,   // 左侧三分之一部分
    GAGCropImageStyleRightQuarter            =8,   // 右侧四分之一部分
    GAGCropImageStyleCenterRightQuarter      =9,   // 中间右侧四分之一部分
    GAGCropImageStyleCenterLeftQuarter       =10,   // 中间左侧四分之一部分
    GAGCropImageStyleLeftQuarter             =11,   // 左侧四分之一部分
};


@interface UIImage (Rect)

//截取部分图像
- (UIImage *)imageByCroppingWithStyle:(GAGCropImageStyle)style;

@end

NS_ASSUME_NONNULL_END
