//
//  WDGRoomController.h
//  WDGRoomDemo
//
//  Created by han wp on 2017/11/2.
//  Copyright © 2017年 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WilddogVideoBase/WDGLocalStreamOptions.h>
@interface WDGRoomController : UIViewController
+(instancetype)roomControllerWithRoomId:(NSString *)roomId uid:(NSString *)uid nickName:(NSString *)nickname dimension:(WDGVideoDimensions)dimension;
@end
