//
//  ScanCodeViewController.m
//  codeTest
//
//  Created by 未思语 on 13/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//

#import "ScanCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Extend.h"


// button 上图下文可以采用，可以直接设置button，可以封装image+label
#define Bottom_Height 70
#define Label_Height 20
#define Image_Width 50
//全局常量
const static CGFloat animationTime = 2.5f;


@interface customButton ()


@end
@implementation customButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [[UIImageView alloc]initWithFrame:CGRectMake((Bottom_Height-Image_Width)/2, 0, Image_Width, Image_Width)];
        //利用CAShapeLayer跟UIBerziPath画一个固定角是圆角的图片
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.image.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *layer = [[CAShapeLayer alloc]init];
        layer.frame = self.image.bounds;
        layer.path = path.CGPath;
        self.image.layer.mask = layer;
        [self addSubview:self.image];
        
        self.lable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.image.frame), Bottom_Height, Label_Height)];
        self.lable.textAlignment = NSTextAlignmentCenter;
        self.lable.textColor = [UIColor whiteColor];
        self.lable.font = [UIFont systemFontOfSize:14.f];
    }
    return self;
    
}

@end


@interface ScanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate>
{
    //二维码扫描用到的系统类
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureMetadataOutput *output;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *preview;
    UIImageView *scanMask;
    UIImageView *scanLine;
    UIActivityIndicatorView *loading;
    UILabel *contentLabel;
    CAShapeLayer *scanMaskBgLayer;//背景色
    UIView *bottomView;
    
    
}
@property (nonatomic, strong) NSMutableArray *buttonsArr;


@end

@implementation ScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainBgColor;
    [self initView];
    [self initScan];
    
    
   
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBar];
}
-(void)setNavigationBar {
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];

    self.navigationItem.leftBarButtonItems = @[back];
    UIBarButtonItem *retry = [[UIBarButtonItem alloc]initWithTitle:@"retry" style:UIBarButtonItemStylePlain target:self action:@selector(retry)];
    UIBarButtonItem *image = [[UIBarButtonItem alloc]initWithTitle:@"image" style:UIBarButtonItemStylePlain target:self action:@selector(image)];
    self.navigationItem.rightBarButtonItems = @[retry,image];
    
    // 设置bar上字体的样式
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16.f]};
    //设置barTintcolor
//    self.navigationController.navigationBar.barTintColor = [UIColor yellowColor];
    //设置tintcolor
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置导航栏为透明色
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}
-(NSMutableArray *)buttonsArr {
    if (!_buttonsArr) {
        _buttonsArr = [NSMutableArray array];
    }
    return _buttonsArr;
}
//初始化扫描类
- (void)initScan {
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    //判断是否有输入源
    if (!input) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"摄像头不可用，请开启" message:@"设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //从应用中打开系统设置  系统设置的url是ios8，0以上才有的
            if (devieceVersion>8.0) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 10000
                    if (devieceVersion>=10.0) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    } else
#endif
                        [[UIApplication sharedApplication] openURL:url];
                    {
                        
                }
                
            }
          }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:setting];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // 设置device的硬件属性
    if ([device lockForConfiguration:nil]) {
        //自动白平衡
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动对焦模式
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光模式
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    }
    output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    //output 设置输出类型
    [output setMetadataObjectTypes:@[
                                                         AVMetadataObjectTypeQRCode,
                                                         AVMetadataObjectTypeCode39Code,
                                                         AVMetadataObjectTypeCode128Code,
                                                         AVMetadataObjectTypeCode39Mod43Code,
                                                         AVMetadataObjectTypeEAN13Code,
                                                         AVMetadataObjectTypeEAN8Code,
                                                         AVMetadataObjectTypeCode93Code
                                                         ]];

    preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    [self loadScan];
    
}
//获取二维码类初始化之后开始加载扫描
- (void)loadScan {
    //当开始加载的时候显示菊花
    [loading startAnimating];
    //真正的扫描是放在子线程中进行，避免卡顿
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [session startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [loading stopAnimating];
            [UIView animateWithDuration:0.25 animations:^{
                scanMask.hidden = NO;
                contentLabel.hidden = NO;
            } completion:^(BOOL finished) {
                //此处进行line的frame的重新布局
                scanLine.frame = CGRectMake(0, 0, scanMask.frame.size.width, [UIImage imageNamed:@"mx_qr_scan_line_phone"].size.height);
                [scanLine.layer addAnimation:[self moveAnimation] forKey:@"moveAnimation"];
            }];
            output.rectOfInterest = [self calculateRectOfInterest];
        
        });
        
    });
    
}

- (void)startScan {
    [scanLine.layer addAnimation:[self moveAnimation] forKey:@"moveAnimation"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [session startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    });
    
}
- (void)stopScan {
    [scanLine.layer removeAnimationForKey:@"moveAnimation"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([session isRunning]) {
            [session stopRunning];
        }
    });
    
}
//这是单纯的移动动画
- (CABasicAnimation *)moveAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, scanMask.frame.size.height-[UIImage imageNamed:@"mx_qr_scan_line_phone"].size.height)];
    animation.repeatCount = 1000;
    //动画节奏时间函数 实际就是以哪种方式进行动画
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = animationTime;
    //上下运动方式
    animation.autoreverses = YES;
    return animation;
}
//限定扫描范围
- (CGRect)calculateRectOfInterest {
    CGFloat x = scanMask.frame.origin.y/appHeight;
    CGFloat y = scanMask.frame.origin.x/appWidth;
    CGFloat width = scanMask.frame.size.height/appHeight;
    CGFloat height = scanMask.frame.size.width/appWidth;
    CGRect rect = CGRectMake(x, y, width, height);
    return rect;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self stopScan];
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = metadataObjects[0];
        NSString *result = object.stringValue;
        [self dealWithResult:result];
    }
}
//根据扫描结果进行结果处理
- (void)dealWithResult:(NSString *)result {
    [self playScanSound];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:result delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
//扫描成功之后的声音提示
- (void)playScanSound {
    SystemSoundID soundID = 0;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scancode.caf" ofType:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL URLWithString:path], &soundID);
    AudioServicesPlayAlertSound(soundID);
    
    
}
//初始化扫描二维码的视图上用到view控件
- (void)initView {
    [self setScanMask:YES];
    
    scanMask = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mx_qr_scan_mask_phone"]];
    scanMask.frame = CGRectMake((appWidth-200)/2, (appHeight-200)/2, 200, 200);
    scanMask.hidden = YES;
    [self.view addSubview:scanMask];
    
    contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxX(scanMask.frame)+10, appWidth, 20)];
    contentLabel.text = NSLocalizedStringFromTable(@"tip", @"localization", nil);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = [UIColor redColor];
    contentLabel.font = [UIFont systemFontOfSize:20.f];
    contentLabel.hidden = YES;
    [self.view addSubview:contentLabel];
    
    
    scanLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mx_qr_scan_line_phone"]];
    [scanMask addSubview:scanLine];
    
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, appHeight-Bottom_Height, appWidth, Bottom_Height)];
    bottomView.backgroundColor = [UIColor whiteColor];
    CGFloat padding = (appWidth-3*Bottom_Height)/4;
    for (int i =  0; i < 3; i ++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(padding*(i+1)+Bottom_Height*i, 0, Bottom_Height, Bottom_Height)];
        button.tag = i + 100;
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor purpleColor]];
        [self.buttonsArr addObject:button];
        [bottomView addSubview:button];
    }
    [self.view addSubview:bottomView];
    
    loading = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((appWidth-20)/2, (appHeight-20)/2, 20, 20)];
    loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:loading];
    
}
- (void)click:(UIButton *)sender {
    switch (sender.tag) {
        case 100://重新扫描
            {
                [self retry];
                break;
            }
        case 101://打开闪光灯
        {
            sender.selected = !sender.selected;
            [self tourch:sender.selected];
        }
            break;
        case 102://选择相册
        {
            [self image];
              break;
        }
            
        default:
            break;
    }
}
//根据是否正在loading来加载view
- (void)setScanMask:(BOOL)loading {
    scanMaskBgLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [scanMaskBgLayer setFillRule:kCAFillRuleEvenOdd];
    [scanMaskBgLayer setPath:path.CGPath];
    [scanMaskBgLayer setFillColor:[UIColor colorWithWhite:0 alpha:loading?1:0.6].CGColor];
    [self.view.layer insertSublayer:scanMaskBgLayer above:preview];
    
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
//点击重新进行扫描
- (void)retry {
    [self stopScan];
    [self startScan];
}
//打开闪光灯
- (void)tourch:(BOOL)on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if ([device hasFlash] && [device hasTorch]) {
            [device lockForConfiguration:nil];
            if (on && device.torchMode == AVCaptureTorchModeOff) {
                device.torchMode = AVCaptureTorchModeOn;
                device.flashMode = AVCaptureFlashModeOn;
            }
            if (!on && device.torchMode == AVCaptureTorchModeOn) {
                device.torchMode = AVCaptureTorchModeOff;
                device.flashMode = AVCaptureFlashModeOff;
            }
            [device unlockForConfiguration];
        }
    }
}
//打开相册
- (void)image {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *img = info[UIImagePickerControllerEditedImage];
    if (!img) {
        img = info[UIImagePickerControllerOriginalImage];
    }
    [loading startAnimating];
    [picker dismissViewControllerAnimated:YES completion:^{
        //根据选中的image进行扫描二维码，输出result字符串
        NSString *result = [img scanCodeContext];
        [loading stopAnimating];
        [self dealWithResult:result];
        
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
