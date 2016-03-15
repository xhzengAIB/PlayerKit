//
//  PlayerKitToolsBottomView.h
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerKitProgressView.h"

@interface PlayerKitToolsBottomView : UIView

@property (nonatomic, strong) UIButton *mediaControlButton;

@property (nonatomic, strong) PlayerKitProgressView *progressView;
@property (nonatomic, strong) UILabel *processingTimeLabel;

@property (nonatomic, strong) UIButton *animationButton;

- (void)updatePlayControl:(BOOL)play;
- (void)updateAnimated:(BOOL)animated;
- (void)updateElments;

- (void)updateTotalTimeString:(NSString *)totalTimeString;
- (void)updatePlayingTimeString:(NSString *)playingTimeString;

@end
