//
//  WDGRoomController.m
//  WDGRoomDemo
//
//  Created by han wp on 2017/11/2.
//  Copyright © 2017年 wilddog. All rights reserved.
//

#import "WDGRoomController.h"
#import "BoardToolBar.h"
#import "WDGRoomMemberCell.h"
#import <WilddogCore/WilddogCore.h>
#import <WilddogVideoRoom/WilddogVideoRoom.h>
#import <WilddogVideoBase/WilddogVideoBase.h>
#import "WDGChatView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <WilddogAuth/WilddogAuth.h>
#import "AppDelegate.h"
#import "WDGNavigationController.h"
#define animationTime .5

@import WilddogBoard;

@implementation UIAlertController(Autorotate)
//-(BOOL)shouldAutorotate
//{
//    return NO;
//}

@end

@interface WDGRoomController ()<UITableViewDataSource,UITableViewDelegate,RoomMemberCellDelegate,WDGRoomDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UILabel *membersCountLabel;
@property (nonatomic,strong) UIButton *footerBtn;
@property (nonatomic,assign) RoomMemberStyle style;
@property (nonatomic, strong) WDGRoom *room;
@property (nonatomic, strong) WDGLocalStream *localStream;
@property (nonatomic, strong) NSMutableArray<WDGStream *> *streams;
@property (nonatomic, strong) WDGBoard *boardView;

@property (nonatomic,copy) NSString *roomId;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,assign) WDGVideoDimensions dimension;

@property (nonatomic,strong) WDGChatView *chatView;

@end

@implementation WDGRoomController
{
    UIButton *_hideButton;
    UIView *_header;
    UIView *_footer;
}

+(instancetype)roomControllerWithRoomId:(NSString *)roomId uid:(NSString *)uid nickName:(NSString *)nickname dimension:(WDGVideoDimensions)dimension
{
    WDGRoomController *roomController = [[WDGRoomController alloc] init];
    roomController.roomId =roomId;
    roomController.uid =uid;
    roomController.nickName = nickname;
    roomController.dimension =dimension;
    return roomController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled =YES;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self initData];
    [self createBoard];
    [self addExitButton];
    [self createTableView];
    [self addTableViewHeaderAndFooter];
    [self createChatView];
    [self setupLocalStream];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    // 创建或加入房间
    _room = [[WDGRoom alloc] initWithRoomId:_roomId url:@"wss://bt-sh.wilddog.com:2600/ws" delegate:self];
    [_room connect];
}

- (void)didSessionRouteChange:(NSNotification *)notification
{
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

-(void)initData
{
    self.streams = [NSMutableArray array];
}

#pragma mark - views create
-(void)createBoard
{
    WDGBoardOptions *option = [WDGBoardOptions defaultOptions];
    //画布尺寸，保持与其它端统一
    option.canvasSize = CGSizeMake(1366, 768);
    
    WDGBoard *boardView = [WDGBoard creatBoardWithAppID:@"wd0018753635ifkvjw"
                                                   Path:[NSString stringWithFormat:@"%@/board",_roomId]
                                                 userID:[WDGAuth auth].currentUser.uid
                                               opthions:option];
    
    
    boardView.frame = CGRectMake(0, 0,
                                 self.view.frame.size.height,
                                 self.view.frame.size.width);
    
    boardView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:boardView];
    _boardView = boardView;
    
    BoardToolBar *toolbar = [BoardToolBar new];
    [toolbar setupWithBoard:boardView
                  direction:BoardToolBarDirectionHorizontal
                      theme:BoardToolThemeDark
                      frame:CGRectMake((self.view.frame.size.height - 350)*.5,self.view.frame.size.width -55,350,55)
     ];
    
    [self.view addSubview:toolbar];
}

-(void)addExitButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"退出群聊" forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"timg"] forState:UIControlStateNormal];
    [button setTitle:@"退出\n房间" forState:UIControlStateNormal];
    button.titleLabel.lineBreakMode = 0;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setBackgroundColor: [UIColor colorWithRed:46/255. green:46/255. blue:46/255. alpha:1.]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(exitRoom) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(15, 20, 30, 30);
    [self.view addSubview:button];
}

-(void)exitRoom
{
    [_boardView destroy];
    _boardView = nil;
    [UIApplication sharedApplication].idleTimerDisabled =YES;
    ((WDGNavigationController *)self.presentingViewController).orientationMask = UIInterfaceOrientationMaskPortrait;
    [_room disconnect];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

-(void)createTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 60, 260) style:UITableViewStylePlain];
    tableView.delegate =self;
    tableView.dataSource =self;
    _tableView =tableView;
    tableView.backgroundColor = [UIColor colorWithRed:46/255. green:46/255. blue:46/255. alpha:1.];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    UISwipeGestureRecognizer * recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    recognizer.delegate = self;
    [_tableView addGestureRecognizer:recognizer];
}

-(void)addTableViewHeaderAndFooter
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 15)];
    header.backgroundColor =[UIColor colorWithWhite:0 alpha:.5];
    UILabel *membersCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, header.frame.size.width, 10)];
    membersCountLabel.text = [NSString stringWithFormat:@"成员(%lu)",(unsigned long)_streams.count];
    membersCountLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    membersCountLabel.textAlignment = NSTextAlignmentCenter;
    membersCountLabel.textColor = [UIColor whiteColor];
    [header addSubview:membersCountLabel];
    _membersCountLabel =membersCountLabel;
    [self.view addSubview:header];
    _header =header;
    self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, CGRectGetMaxY(self.tableView.frame)-15, self.tableView.frame.size.width, 15)];
    footer.backgroundColor =[UIColor colorWithWhite:0 alpha:.5];
    UIButton *footerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    footerBtn.frame = CGRectMake(0, 0, 25, 15);
    footerBtn.center = CGPointMake(CGRectGetWidth(footer.frame)*.5, CGRectGetHeight(header.frame)*.5);
    [footerBtn setImage:[UIImage imageNamed:@"arrows"] forState:UIControlStateNormal];
    [footerBtn addTarget:self action:@selector(showMembersChat) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:footerBtn];
    [self.view addSubview:footer];
    _footer =footer;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"左滑手势");
        [self hideMembersChat];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        NSLog(@"右滑手势");
        [self hideMembersChat];
    }
}

-(void)hideMembersChat
{
    if(self.style==RoomMemberStyleComplex){
        self.style = RoomMemberStyleSimple;
        [_hideButton removeFromSuperview];
        _hideButton =nil;
        [UIView animateWithDuration:animationTime animations:^{
            self.tableView.frame = CGRectMake(0, 60, 60, 260);
            self.chatView.center = CGPointMake(self.chatView.center.x+self.chatView.frame.size.width, self.chatView.center.y);
        } completion:^(BOOL finished) {
            _header.hidden=NO;
            _footer.hidden=NO;
            [self.tableView reloadData];
            self.chatView.hidden =YES;
        }];
    }
}

-(void)showMembersChat
{
    self.style = RoomMemberStyleComplex;
    [self.tableView.tableHeaderView removeFromSuperview];
    self.tableView.tableHeaderView = nil;
    [self.tableView.tableFooterView removeFromSuperview];
    self.tableView.tableFooterView = nil;
    self.chatView.hidden=NO;
    _header.hidden=YES;
    _footer.hidden=YES;
    [UIView animateWithDuration:animationTime animations:^{
        self.tableView.frame = CGRectMake(0, 20, 270, self.view.frame.size.height-20);
        self.chatView.center = CGPointMake(self.chatView.center.x-self.chatView.frame.size.width, self.chatView.center.y);
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        _hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideButton setImage:[UIImage imageNamed:@"division"] forState:UIControlStateNormal];
        [_hideButton addTarget: self action:@selector(hideMembersChat) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hideButton];
        _hideButton.frame = CGRectMake(self.tableView.frame.size.width-30, 0, 30, self.tableView.frame.size.height);
    }];
}

-(void)createChatView
{
    WDGChatView *chatView = [WDGChatView viewWithNickname:_nickName roomId:_roomId frame:CGRectMake(self.view.frame.size.height, 0, self.view.frame.size.height-270, self.view.frame.size.width)];
    self.chatView =chatView;
    chatView.hidden =YES;
    chatView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:chatView];
    UISwipeGestureRecognizer * recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    recognizer.delegate = self;
    [chatView addGestureRecognizer:recognizer];
}

- (void)setupLocalStream {
    // 创建本地流
    WDGLocalStreamOptions *localStreamOptions = [[WDGLocalStreamOptions alloc] init];
    localStreamOptions.shouldCaptureAudio = YES;
    localStreamOptions.dimension = WDGVideoDimensions360p;
    self.localStream = [WDGLocalStream localStreamWithOptions:localStreamOptions];
    [self addStream:self.localStream];
    [self.tableView reloadData];
}

-(void)addStream:(WDGStream *)stream
{
    [self.streams addObject:stream];
    _membersCountLabel.text = [NSString stringWithFormat:@"成员(%lu)",(unsigned long)_streams.count];
}

-(void)removeStream:(WDGStream *)stream
{
    [self.streams removeObject:stream];
    _membersCountLabel.text = [NSString stringWithFormat:@"成员(%lu)",(unsigned long)_streams.count];
}

#pragma mark - tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _streams.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= _streams.count){
        WDGInviteCell *cell =[tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
        if(!cell){
            cell = [[WDGInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.style =self.style;
        return cell;
    }
    static NSString *cellId =@"RoomMemberCell";
    WDGRoomMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = [[WDGRoomMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate =self;
    cell.audioEnabled = 1;
    cell.boardEnabled = 1;
    cell.style = self.style;
    [self.streams[indexPath.row] attach:cell.videoView];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.style==RoomMemberStyleSimple?60:160;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.streams.count){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"邀请他人" message:@"https://www.wilddog.com/product/webrtc-demo/join" delegate:self cancelButtonTitle:@"去粘贴" otherButtonTitles:nil];
        
        [alert show];
    }
}

#pragma mark - roomMemberCellDelegate
-(void)roomMemberCell:(WDGRoomMemberCell *)cell audioEnabled:(BOOL)audioEnabled
{

}

-(void)roomMemberCell:(WDGRoomMemberCell *)cell boardEnabled:(BOOL)boardEnabled
{
    
}

#pragma mark - WDGRoomDelegate

- (void)wilddogRoomDidConnect:(WDGRoom *)wilddogRoom {
    NSLog(@"Room Connected!");
    // 发布本地流
    [self publishLocalStream];
}

- (void)wilddogRoomDidDisconnect:(WDGRoom *)wilddogRoom {
    NSLog(@"Room Disconnected!");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self exitRoom];
    });
}

- (void)wilddogRoom:(WDGRoom *)wilddogRoom didStreamAdded:(WDGRoomStream *)roomStream {
    NSLog(@"RoomStream Added!");
    [self subscribeRoomStream:roomStream];
}

- (void)wilddogRoom:(WDGRoom *)wilddogRoom didStreamRemoved:(WDGRoomStream *)roomStream {
    NSLog(@"RoomStream Removed!");
    [self unsubscribeRoomStream:roomStream];
    [self removeStream:roomStream];
    [self.tableView reloadData];
}

- (void)wilddogRoom:(WDGRoom *)wilddogRoom didStreamReceived:(WDGRoomStream *)roomStream {
    NSLog(@"RoomStream Received!");
    [self addStream:roomStream];
    [self.tableView reloadData];
}

- (void)wilddogRoom:(WDGRoom *)wilddogRoom didFailWithError:(NSError *)error {
    NSLog(@"Room Failed: %@", error);
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"会议错误: %@", [error localizedDescription]];
        [self showAlertWithTitle:@"提示" message:errorMessage];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [UIPasteboard generalPasteboard].string = alertView.message;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Client Operation

- (void)publishLocalStream {
    if (self.localStream) {
        [self.room publishLocalStream:self.localStream withCompletionBlock:^(NSError * _Nullable error) {
            NSLog(@"Publish Completion Block");
        }];
    }
}

- (void)unpublishLocalStream {
    if (self.localStream) {
        [self.room unpublishLocalStream:self.localStream withCompletionBlock:^(NSError * _Nullable error) {
            NSLog(@"Unpublish Completion Block");
        }];
    }
}

- (void)subscribeRoomStream:(WDGRoomStream *)roomStream {
    if (roomStream) {
        [self.room subscribeRoomStream:roomStream withCompletionBlock:^(NSError * _Nullable error) {
            NSLog(@"Subscribe Completion Block");
        }];
    }
}

- (void)unsubscribeRoomStream:(WDGRoomStream *)roomStream {
    if (roomStream) {
        [self.room unsubscribeRoomStream:roomStream withCompletionBlock:^(NSError * _Nullable error) {
            NSLog(@"Unsubscribe Completion Block");
        }];
    }
}

#pragma mark - controller init
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
