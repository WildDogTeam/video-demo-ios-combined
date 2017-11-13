//
//  ViewController.m
//  WDGRoomDemo
//
//  Created by han wp on 2017/11/2.
//  Copyright © 2017年 wilddog. All rights reserved.
//

#import "ViewController.h"
#import "WDGRoomController.h"
#import <WilddogCore/WilddogCore.h>
#import <WilddogAuth/WilddogAuth.h>
#import <WilddogVideoBase/WilddogVideoBase.h>
#import "AppDelegate.h"
#import "WDGNavigationController.h"
#import "WDGRoomConfig.h"
@interface ViewController ()<UIActionSheetDelegate>
@property (nonatomic,strong) UIButton *resolutionButton;
@property (nonatomic,strong) UIButton *enterButton;
@property (nonatomic,strong) UITextField *roomField;
@property (nonatomic,strong) UITextField *nickField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.hidden =YES;
    ((WDGNavigationController *)self.navigationController).orientationMask =UIInterfaceOrientationMaskPortrait;
    self.view.backgroundColor = [UIColor colorWithRed:219/255. green:226/255. blue:231/255. alpha:1.];
    [self login];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glyphs"]];
    imageView.frame = CGRectMake(0, 0, 100, 100);
    imageView.center = CGPointMake(self.view.frame.size.width*.5, 140);
    [self.view addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+20, self.view.frame.size.width, 20)];
    titleLabel.text = @"野狗多人视频互动";
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    CGFloat itemHeight = 30;
    CGFloat itemGap = 15;
    
    UILabel *roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+50, 90, itemHeight)];
    roomLabel.text = @"房间号";
    roomLabel.font = [UIFont fontWithName:@"" size:15];
    roomLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:roomLabel];
    
    UITextField *roomField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(roomLabel.frame)+itemGap, CGRectGetMinY(roomLabel.frame), 210, CGRectGetHeight(roomLabel.frame))];
    _roomField =roomField;
    roomField.backgroundColor = [UIColor whiteColor];
    roomField.borderStyle = UITextBorderStyleNone;
    roomField.layer.borderWidth = 1;
    roomField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:roomField];
    
    UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(roomLabel.frame)+itemGap, CGRectGetWidth(roomLabel.frame), itemHeight)];
    nickLabel.text = @"昵称";
    nickLabel.font = [UIFont fontWithName:@"" size:15];
    nickLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:nickLabel];
    
    UITextField *nickField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nickLabel.frame)+itemGap, CGRectGetMinY(nickLabel.frame), CGRectGetWidth(roomField.frame)  , CGRectGetHeight(nickLabel.frame))];
    _nickField =nickField;
    nickField.backgroundColor = [UIColor whiteColor];
    nickField.borderStyle = UITextBorderStyleNone;
    nickField.layer.borderWidth = 1;
    nickField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:nickField];
    
    UILabel *resolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nickLabel.frame)+itemGap, CGRectGetWidth(nickLabel.frame), itemHeight)];
    resolutionLabel.text = @"清晰度";
    resolutionLabel.font = [UIFont fontWithName:@"" size:15];
    resolutionLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:resolutionLabel];
    
    UIButton *resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _resolutionButton =resolutionBtn;
    [resolutionBtn setBackgroundColor:[UIColor lightGrayColor]];
    [resolutionBtn addTarget:self action:@selector(resolutionSelect) forControlEvents:UIControlEventTouchUpInside];
    [resolutionBtn setTitle:@"360p" forState:UIControlStateNormal];
    resolutionBtn.frame =CGRectMake(CGRectGetMaxX(resolutionLabel.frame)+itemGap, CGRectGetMinY(resolutionLabel.frame), CGRectGetWidth(nickField.frame)  , CGRectGetHeight(resolutionLabel.frame));
    [self.view addSubview:resolutionBtn];
    
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [enterButton setTitle:@"进入房间" forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(enterRoom) forControlEvents:UIControlEventTouchUpInside];
    enterButton.frame = CGRectMake(0, 0, 200, 38);
    enterButton.center = CGPointMake(self.view.frame.size.width*.5, CGRectGetMaxY(resolutionLabel.frame)+30+CGRectGetHeight(enterButton.frame)*.5);
    enterButton.backgroundColor = [UIColor colorWithRed:195/255. green:48/255. blue:34/255. alpha:1.];
    [self.view addSubview:enterButton];
    _enterButton =enterButton;
    enterButton.enabled =NO;
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    rightLabel.center = CGPointMake(self.view.frame.size.width*.5, self.view.frame.size.height-10);
    rightLabel.text = @"Copyright © 2017 野狗通信云";
    rightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:rightLabel];
    
//    roomField.text=@"111";
//    nickField.text = @"123123";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidLayoutSubviews
{
    
}

-(void)resolutionSelect
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"选择清晰度" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"360p",@"480p",@"720p", nil];
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==3) return;
    [_resolutionButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
}

-(void)enterRoom
{
    if(_roomField.text.length&&_nickField.text.length){
        WDGVideoDimensions dimension =WDGVideoDimensions360p;
        NSString *resolution =_resolutionButton.titleLabel.text;
        if([resolution isEqualToString:@"480p"]){
            dimension = WDGVideoDimensions480p;
        }else if([resolution isEqualToString:@"720p"]){
            dimension = WDGVideoDimensions720p;
        }
        ((WDGNavigationController *)self.navigationController).orientationMask =UIInterfaceOrientationMaskLandscapeRight;
        [self presentViewController:[WDGRoomController roomControllerWithRoomId:_roomField.text uid:nil nickName:_nickField.text dimension:dimension] animated:YES completion:nil];

    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"信息不完整" message:@"请正确填写以上信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)login
{
    // 配置 Wilddog App
    NSString *videoAppID = WDGRoomVideoId;
    NSString *syncAppID = WDGRoomSyncId;
    WDGOptions *options = [[WDGOptions alloc] initWithSyncURL:[NSString stringWithFormat:@"https://%@.wilddogio.com", syncAppID]];
    [WDGApp configureWithOptions:options];
    
    // 匿名登录
    [[WDGAuth auth] signOut:nil];
    __weak __typeof__(self) weakSelf = self;
    [[WDGAuth auth] signInAnonymouslyWithCompletion:^(WDGUser *user, NSError *error) {
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (error) {
            NSLog(@"请在控制台为您的AppID开启匿名登录功能，错误信息: %@", error);
            return;
        }
        // 获取 token 并配置 WilddogVideoInitializer
        [user getTokenWithCompletion:^(NSString * _Nullable idToken, NSError * _Nullable error) {
            // 配置 Video Initializer
            [[WDGVideoInitializer sharedInstance] configureWithVideoAppId:videoAppID token:idToken];
            strongSelf.enterButton.enabled =YES;
        }];
    }];

}


//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}

//支持的方向 因为界面A我们只需要支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}
@end
