//
//  NSString+QRCode.h
//  codeTest
//
//  Created by 未思语 on 27/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QRCode)
//学一下这种说明方法
/**
  生成固定尺寸大小的二维码 默认大小是300
 @return 生成的二维码
 */
- (UIImage *)generateQRCode;
/**
 生成给定尺寸大小的二维码
 paramter:size : 给定的大小
 @return 生成的二维码
 */
- (UIImage *)generateQRCodeWithSize:(CGFloat)size;
/**
 生成中间给定logo的二维码
 paramter logo: logo 图片
 @return 生成带有logo的二维码
 */
- (UIImage *)generateQRCodeWithLogo:(UIImage *)logo;
/**
 生成给定大小，中间带有logo的二维码
 paramter size:给定大小
 logo: logo 图片
 */
- (UIImage *)generateQRCodeWithSize:(CGFloat)size
                               logo:(UIImage *)logo;
/**
 生成给定大小，logo，color，bgcolor的二维码
 paramter size：给定大小
 logo：logo图片
 color：二维码本身颜色，默认是黑白色
 bgcolor：二维码背景颜色
 */
- (UIImage *)generateQRCodeWithSize:(CGFloat)size
                               logo:(UIImage *)logo
                              color:(UIColor *)color
                            bgColor:(UIColor *)bgcolor;
/**
 生成给定下列参数的二维码
 paramter size：给定大小
 logo：logo图片
 color：二维码本身的颜色
 bgcolor：二维码背景颜色
 radius：logo图片的圆角大小
 borderLineWidth:线宽度
 borderLineColor：线颜色
 borderWidth：条宽度
 borderColor：条颜色
 
 
 */
- (UIImage *)generateQRCodeWithSize:(CGFloat)size
                               logo:(UIImage *)logo
                               color:(UIColor *)color
                               bgColor:(UIColor *)bgcolor
                             radius:(CGFloat)radius
                    borderLineWidth:(CGFloat)borderLineWidth
                    borderLineColor:(UIColor *)borderLineColor
                        borderWidth:(CGFloat)borderWidth
                        borderColor:(UIColor *)borderColor;



@end
