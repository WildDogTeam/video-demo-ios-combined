//
//  WDGRoomMemberCell.h
//  WDGRoomDemo
//
//  Created by han wp on 2017/11/2.
//  Copyright © 2017年 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  WDGRoomMemberCell;
@class WDGVideoView;
@protocol RoomMemberCellDelegate <NSObject>
-(void)roomMemberCell:(WDGRoomMemberCell *)cell audioEnabled:(BOOL)audioEnabled;
-(void)roomMemberCell:(WDGRoomMemberCell *)cell boardEnabled:(BOOL)boardEnabled;
@end

typedef NS_ENUM(NSUInteger,RoomMemberStyle){
    RoomMemberStyleSimple,
    RoomMemberStyleComplex
};

@interface WDGRoomMemberCell : UITableViewCell
@property (nonatomic,assign) id<RoomMemberCellDelegate> delegate;
@property (nonatomic) RoomMemberStyle style;
@property (nonatomic) BOOL audioEnabled;
@property (nonatomic) BOOL boardEnabled;
@property (nonatomic,copy) NSString *nickname;
@property (nonatomic,strong) WDGVideoView *videoView;
@end

@interface WDGInviteCell : UITableViewCell
@property (nonatomic) RoomMemberStyle style;
@end
