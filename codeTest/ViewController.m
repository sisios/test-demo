//
//  ViewController.m
//  codeTest
//
//  Created by 未思语 on 13/11/2017.
//  Copyright © 2017 wsy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *info;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *actions;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainBgColor;
    self.title = NSLocalizedStringFromTable(@"code", @"localization", nil);
    [self.view addSubview:self.info];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(UITableView *)info {
    if (!_info) {
        _info = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,appWidth, appHeight-64) style:UITableViewStylePlain];
        _info.delegate = self;
        _info.dataSource = self;
        _info.tableFooterView = [UIView new];
        if (devieceVersion>=9.0) {
            _info.cellLayoutMarginsFollowReadableWidth = NO;
        }
       
    }
    return _info;

    
}
-(NSArray *)data {
    if (!_data) {
        _data = @[NSLocalizedStringFromTable(@"scan", @"localization", nil),NSLocalizedStringFromTable(@"myCode", @"localization", nil)];
    }
    return _data;
}
-(NSArray *)actions {
    if (!_actions) {
        _actions = @[@"ScanCodeViewController",@"MyCodeViewController"];
    }
    return _actions;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *action = self.actions[indexPath.row];
    Class class = NSClassFromString(action);
    UIViewController *vc = [[class alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
