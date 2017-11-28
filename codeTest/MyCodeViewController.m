//
//  MyCodeViewController.m
//  codeTest
//
//  Created by 未思语 on 13/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//

#import "MyCodeViewController.h"
#import "NSString+QRCode.h"
#import "UIImage+Extend.h"


@interface MyCodeViewController ()
{
    UIView *bgView;
    UIImageView  *headerImg;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UIImageView *QRCodeImg;
    
}
@end

@implementation MyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self initView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *str = @"我是name";
        UIImage *image = [str generateQRCodeWithLogo:headerImg.image];
        dispatch_async(dispatch_get_main_queue(), ^{
            QRCodeImg.image = image;
        });
        
    });
    
    
    // Do any additional setup after loading the view.
}
- (void)initView {
    bgView = [[UIView alloc]init];
    bgView.frame = CGRectMake((appWidth-300)/2, (appHeight-300)/2, 300, 300);
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    headerImg = [[UIImageView alloc]init];
    headerImg.frame = CGRectMake(20, 20, 50, 50);
    headerImg.image = [UIImage imageNamed:@"header.png"];
    [bgView addSubview:headerImg];
    nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(80, 20, 100, 30);
    nameLabel.text = @"我是名字";
    [bgView addSubview:nameLabel];
    addressLabel = [[UILabel alloc]init];
    addressLabel.frame = CGRectMake(80, 50, 100, 20);
    addressLabel.text = @"我是 地址";
    [bgView addSubview:addressLabel];
    QRCodeImg = [[UIImageView alloc]init];
    QRCodeImg.frame = CGRectMake(50, 80, 200, 200);
    [bgView addSubview:QRCodeImg];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
