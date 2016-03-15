//
//  PlayerKitReloadTipsView.h
//  Pods
//
//  Created by Jack_iMac on 16/1/18.
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerKitReloadTipsView : UIView

@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, strong) UILabel *tipsLabel;

- (void)show;
- (void)dismiss;

@end
