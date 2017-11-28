//
//  NSString+QRCode.m
//  codeTest
//
//  Created by 未思语 on 27/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//  通过nsstring的分类，生成各种类型的二维码

#import "NSString+QRCode.h"
#import "UIImage+Extend.h"


@implementation NSString (QRCode)
- (UIImage *)generateQRCode {
    return [self generateQRCodeWithSize:0.f];
}
-(UIImage *)generateQRCodeWithSize:(CGFloat)size {
    return [self generateQRCodeWithSize:size logo:nil];
}
-(UIImage *)generateQRCodeWithLogo:(UIImage *)logo {
    return [self generateQRCodeWithSize:0.f logo:logo];
}
-(UIImage *)generateQRCodeWithSize:(CGFloat)size logo:(UIImage *)logo {
    UIColor *color = [UIColor blackColor];
    UIColor *bgColor = [UIColor whiteColor];
    return [self generateQRCodeWithSize:size logo:logo color:color bgColor:bgColor];
}
-(UIImage *)generateQRCodeWithSize:(CGFloat)size logo:(UIImage *)logo color:(UIColor *)color bgColor:(UIColor *)bgcolor {
    CGFloat radius = 5.f;//圆角
    CGFloat borderLineWidth = 1.5f;//宽度
    UIColor * borderLineColor = [UIColor redColor];
    CGFloat borderWidth = 8.f;//宽度
    UIColor * borderColor = [UIColor greenColor];
    return [self generateQRCodeWithSize:size logo:logo color:color bgColor:bgcolor radius:radius borderLineWidth:borderLineWidth borderLineColor:borderLineColor borderWidth:borderWidth borderColor:borderColor];
    
}
//这个才是最终生成二维码的方法
- (UIImage *)generateQRCodeWithSize:(CGFloat)size
                               logo:(UIImage *)logo
                              color:(UIColor *)color
                            bgColor:(UIColor *)bgcolor
                             radius:(CGFloat)radius
                    borderLineWidth:(CGFloat)borderLineWidth
                    borderLineColor:(UIColor *)borderLineColor
                        borderWidth:(CGFloat)borderWidth
                        borderColor:(UIColor *)borderColor {
    CIImage *ciimage = [self generateCIImageWithSize:size color:color bgColor:bgcolor];
    UIImage *image = [UIImage imageWithCIImage:ciimage];
    if(!logo) return image;
    if(!image) return nil;
    //绘制logo
    CGFloat logoWidth = image.size.width/4;
    CGRect logoFrame = CGRectMake((image.size.width-logoWidth)/2, (image.size.height-logoWidth)/2, logoWidth, logoWidth);
    UIGraphicsBeginImageContextWithOptions(image.size, false, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //线框
    UIImage *logoImage = [image getRoundRectImageWithSize:logoWidth radius:radius borderWidth:borderLineWidth borderColor:borderLineColor];
    //边框
    UIImage *logoBorderImage = [logoImage getRoundRectImageWithSize:logoWidth radius:radius borderWidth:borderWidth borderColor:borderColor];
    [logoBorderImage drawInRect:logoFrame];
    UIImage *qrImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return qrImage;
     
    
}
- (CIImage *)generateCIImageWithSize:(CGFloat)size color:(UIColor *)color bgColor:(UIColor *)bgColor {
    CGFloat QRCodeSize = 200;
    UIColor *QRCodeColor = [UIColor blackColor];
    UIColor *QRCodeBgColor = [UIColor whiteColor];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *ciimage = filter.outputImage;
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:ciimage forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithCGColor:QRCodeColor.CGColor] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithCGColor:QRCodeBgColor.CGColor] forKey:@"inputColor1"];
    CIImage *outImage = colorFilter.outputImage;
    CGFloat scale = QRCodeSize/outImage.extent.size.width;
    return [colorFilter.outputImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
    
}
@end
