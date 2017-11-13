//
//  WDGChatCell.m
//  WDGRoomDemo
//
//  Created by han wp on 2017/11/3.
//  Copyright © 2017年 wilddog. All rights reserved.
//

#import "WDGChatCell.h"
#import "WDGChatMessageLayout.h"
#import <WilddogAuth/WilddogAuth.h>
@implementation WDGChatCell
{
    UILabel *_nameLabel;
    UILabel *_messageLabel;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle =UITableViewCellSelectionStyleNone;
        [self createUI];
        
    }
    return self;
}

-(void)createUI
{
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel =nameLabel;
    nameLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:nameLabel];
    
    UILabel *messageLabel = [UILabel new];
    _messageLabel = messageLabel;
    _messageLabel.textColor = [UIColor blackColor];
    _messageLabel.backgroundColor = [UIColor whiteColor];
    _messageLabel.layer.cornerRadius = 5;
    _messageLabel.clipsToBounds =YES;
    _messageLabel.numberOfLines = 0;
    _messageLabel.preferredMaxLayoutWidth = 150;
    _messageLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_messageLabel];
}

-(void)setLayout:(WDGChatMessageLayout *)layout
{
    _layout = layout;
    _nameLabel.text =layout.message.nickname;
    _messageLabel.text = layout.message.message;
    if([layout.message.uid isEqualToString:[WDGAuth auth].currentUser.uid]){
        _type = WDGChatTypeMe;
    }else{
        _type = WDGChatTypeOther;
    }
}

-(void)setType:(WDGChatType)type
{
    _type=type;
    [self setNeedsLayout];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _nameLabel.frame = CGRectMake(20, 0, self.contentView.frame.size.width-40, 20);
    
    _messageLabel.frame = CGRectMake(0, 0, WDGChatMessageMaxWidth, CGFLOAT_MAX);
    [_messageLabel sizeToFit];
    
    if(_type == WDGChatTypeMe){
        _messageLabel.frame = CGRectMake(self.contentView.frame.size.width -_messageLabel.frame.size.width-20, CGRectGetMaxY(_nameLabel.frame), _messageLabel.frame.size.width, _messageLabel.frame.size.height);
        _nameLabel.textAlignment =NSTextAlignmentRight;

    }else{
        _messageLabel.frame = CGRectMake(20, CGRectGetMaxY(_nameLabel.frame), _messageLabel.frame.size.width, _messageLabel.frame.size.height);
        _nameLabel.textAlignment =NSTextAlignmentLeft;

    }
}
@end
