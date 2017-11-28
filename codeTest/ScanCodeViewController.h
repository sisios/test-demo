//
//  ScanCodeViewController.h
//  codeTest
//
//  Created by 未思语 on 13/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//  扫描二维码的页面

#import <UIKit/UIKit.h>
//将代理换做是block
typedef void(^clickBlock)(NSUInteger tag);
@interface customButton :UIView
@property (nonatomic, strong) UILabel*lable;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, copy) clickBlock click;

@end
@interface ScanCodeViewController : UIViewController

@end
