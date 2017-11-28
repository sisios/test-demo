//
//  UIImage+Extend.h
//  codeTest
//
//  Created by 未思语 on 27/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extend)
/**
 识别图片二维码
 @return 二维码内容
 */
-(NSString *)scanCodeContext;
/**
 根据特定大小生成圆角图片
 paramter size:图片大小
 radius：圆角半径
 borderWidth：边框宽度
 borderColor：边框颜色
 @return  生成圆角image
 */
- (UIImage *)getRoundRectImageWithSize:(CGFloat)size
                                radius:(CGFloat)radius
                           borderWidth:(CGFloat)borderWidth
                           borderColor:(UIColor *)borderColor;
/**
 生成特定大小，圆角半径的image
 paramter size:特定大小
 radius：圆角半径
 */
- (UIImage *)getRoundRectImageWithSize:(CGFloat)size
                                radius:(CGFloat)radius;


@end
