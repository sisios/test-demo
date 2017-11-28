//
//  UIImage+Extend.m
//  codeTest
//
//  Created by 未思语 on 27/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//

#import "UIImage+Extend.h"

@implementation UIImage (Extend)
-(NSString *)scanCodeContext {
    //uiimage -nsdata-ciimage-cicontext-cidetector-nsarray
    NSData *data = UIImagePNGRepresentation(self);
    CIImage *ciimage = [CIImage imageWithData:data];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(false),kCIContextPriorityRequestLow:@(false)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciimage];
    CIQRCodeFeature *feature = [features firstObject];
    return feature.messageString ? feature.messageString : @"未识别";
}
-(UIImage *)getRoundRectImageWithSize:(CGFloat)size radius:(CGFloat)radius {
    return [self getRoundRectImageWithSize:size radius:radius borderWidth:0 borderColor:nil];
}
- (UIImage *)getRoundRectImageWithSize:(CGFloat)size radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    //同步进行扩大
    CGFloat scale = self.size.width/size * 1.0f;
    CGFloat defalutBorderWidth = borderWidth * scale;
    UIColor *defalutBorderColor = borderColor ? borderColor :[UIColor clearColor];
    radius = radius *scale;
    CGRect rect = CGRectMake(defalutBorderWidth, defalutBorderWidth, self.size.width-2*defalutBorderWidth, self.size.height-2*defalutBorderWidth);
    UIGraphicsBeginImageContextWithOptions(self.size, false, [UIScreen mainScreen].scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    path.lineWidth = defalutBorderWidth;
    [defalutBorderColor setStroke];
    [path stroke];
    [path addClip];
    [self drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end
