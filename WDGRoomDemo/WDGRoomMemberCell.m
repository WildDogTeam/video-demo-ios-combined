//
//  WDGRoomMemberCell.m
//  WDGRoomDemo
//
//  Created by han wp on 2017/11/2.
//  Copyright © 2017年 wilddog. All rights reserved.
//

#import "WDGRoomMemberCell.h"
#import <WilddogVideoBase/WDGVideoView.h>
@implementation WDGRoomMemberCell
{
    UIView *_backView;
    UILabel *_nickLabel;
    UIButton *_audioBtn;
    UIButton *_boardBtn;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor clearColor];
        _boardEnabled =YES;
        _audioEnabled =YES;
        [self createSubViews];
    }
    return self;
}

-(void)createSubViews
{
    WDGVideoView *playView = [WDGVideoView new];
    playView.mirror = YES;
    playView.contentMode = UIViewContentModeScaleAspectFill;
//    playView.backgroundColor = [UIColor redColor];
    _videoView = playView;
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    _backView = backView;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:nameLabel];
    _nickLabel = nameLabel;
    UIButton *audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioBtn setImage:[UIImage imageNamed:@"语音"] forState:UIControlStateNormal];
    [audioBtn setImage:[UIImage imageNamed:@"语音关闭"] forState:UIControlStateSelected];
    [audioBtn addTarget:self action:@selector(audioBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    audioBtn.frame =CGRectMake(0, 0, 30, 30);
    [_backView addSubview:audioBtn];
    _audioBtn =audioBtn;
    UIButton *boardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [boardBtn setImage:[UIImage imageNamed:@"白板"] forState:UIControlStateNormal];
    [boardBtn setImage:[UIImage imageNamed:@"白板关闭"] forState:UIControlStateSelected];
    [boardBtn addTarget:self action:@selector(boardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    boardBtn.frame =CGRectMake(0, 0, 30, 30);
    [_backView addSubview:boardBtn];
    _boardBtn =boardBtn;
    _backView.hidden = YES;
    [self.contentView addSubview:playView];
    [self.contentView addSubview:_backView];

    _backView.hidden=YES;
    _boardBtn.hidden = YES;
    _audioBtn.hidden = YES;
}

-(void)setAudioEnabled:(BOOL)audioEnabled
{
    _audioEnabled =audioEnabled;
    _audioBtn.selected =!_audioEnabled;
}

-(void)setBoardEnabled:(BOOL)boardEnabled
{
    _boardEnabled = boardEnabled;
    _boardBtn.selected = !_boardEnabled;
}

-(void)setNickname:(NSString *)nickname
{
    _nickname = nickname;
    _nickLabel.text = nickname;
}

-(void)audioBtnClick:(UIButton *)audioBtn
{
    audioBtn.selected =!audioBtn.selected;
    if([self.delegate respondsToSelector:@selector(roomMemberCell:audioEnabled:)]){
        [self.delegate roomMemberCell:self audioEnabled:!audioBtn.selected];
    }
}

-(void)boardBtnClick:(UIButton *)boardBtn
{
    boardBtn.selected =!boardBtn.selected;
    if([self.delegate respondsToSelector:@selector(roomMemberCell:boardEnabled:)]){
        [self.delegate roomMemberCell:self boardEnabled:!boardBtn.selected];
    }
}

-(void)setStyle:(RoomMemberStyle)style
{
    if(_style !=style){
        _style =style;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(_style == RoomMemberStyleSimple){
        _backView.hidden =YES;
        _videoView.frame = CGRectMake(4, 4, self.contentView.frame.size.width-4*2, self.contentView.frame.size.height-4*2);
    }else{
//        _backView.hidden =NO;
        _videoView.frame = CGRectMake(30, 4, self.contentView.frame.size.width-30*2, self.contentView.frame.size.height-4*2);
        _backView.frame = CGRectMake(CGRectGetMinX(_videoView.frame), CGRectGetMaxY(_videoView.frame)-33, _videoView.frame.size.width, 33);
        _nickLabel.frame = _backView.bounds;
        _boardBtn.frame = CGRectMake(_backView.frame.size.width-33, 0, 33, 33);
        _audioBtn.frame = CGRectMake(CGRectGetMinX(_boardBtn.frame)-33, 0, 33, 33);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation WDGInviteCell
{
    UIView *_backGroundView;
    UIView *_view1;
    UIView *_view2;
    UILabel *_label;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor clearColor];
        [self createSubViews];
    }
    return self;
}

-(void)createSubViews
{
    _backGroundView = [UIView new];
    _backGroundView.backgroundColor = [UIColor colorWithRed:32/255. green:35/255. blue:42/255. alpha:1];
    [self.contentView addSubview:_backGroundView];
    _view1 = [UIView new];
    _view1.backgroundColor = [UIColor whiteColor];
    [_backGroundView addSubview:_view1];
    _view2 = [UIView new];
    _view2.backgroundColor = [UIColor whiteColor];
    [_backGroundView addSubview:_view2];
    _label = [[UILabel alloc] init];
    _label.text =@"邀请他人";
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [_backGroundView addSubview:_label];
    _label.hidden =YES;
}

-(void)setStyle:(RoomMemberStyle)style
{
    if(_style !=style){
        _style =style;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(_style == RoomMemberStyleSimple){
        _label.hidden =YES;
        _backGroundView.frame =CGRectMake(4, 4, self.contentView.frame.size.width-4*2, self.contentView.frame.size.height-4*2);
        _view1.frame = CGRectMake(6, (_backGroundView.frame.size.height-1)*.5, _backGroundView.frame.size.width-6*2, 1);
        _view2.frame = CGRectMake((_backGroundView.frame.size.width-1)*.5, 6, 1, _backGroundView.frame.size.height-6*2);
    }else{
        _label.hidden =NO;
        _backGroundView.frame =CGRectMake(30, 4, self.contentView.frame.size.width-30*2, self.contentView.frame.size.height-4*2);
        _view1.frame = CGRectMake(40, (_backGroundView.frame.size.height-1)*.5, _backGroundView.frame.size.width-40*2, 1);
        _view2.frame = CGRectMake((_backGroundView.frame.size.width-1)*.5, 30, 1, _backGroundView.frame.size.height-30*2);
        _label.frame = CGRectMake(0, CGRectGetMaxY(_view2.frame)+10, _backGroundView.frame.size.width, 20);
    }
}
@end
