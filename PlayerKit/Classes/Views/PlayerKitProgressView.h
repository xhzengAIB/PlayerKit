//
//  PlayerKitProgressView.h
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import <UIKit/UIKit.h>

@interface PlayerKitProgressView : UISlider

@property (nonatomic, assign) CGFloat progressWidth;

@property (nonatomic, strong) UIColor *bufferProgressTintColor;

@property (nonatomic, assign) CGFloat bufferProgress;
@property (nonatomic, assign) CGFloat progress;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setBufferProgress:(CGFloat)bufferProgress animated:(BOOL)animated;

+ (instancetype)initilzerProgressView;
+ (instancetype)initilzerProgressViewWithFrame:(CGRect)frame;

@end
