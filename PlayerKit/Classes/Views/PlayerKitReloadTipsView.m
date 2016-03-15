//
//  PlayerKitReloadTipsView.m
//  Pods
//
//  Created by Jack_iMac on 16/1/18.
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "PlayerKitReloadTipsView.h"

@implementation PlayerKitReloadTipsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tipsLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.reloadButton.center = CGPointMake(self.tipsLabel.center.x, CGRectGetMaxY(self.tipsLabel.frame) + 20);
}

- (void)setup {
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.reloadButton];
    [self addSubview:self.tipsLabel];
    
    [self dismiss];
}

- (void)show {
    self.hidden = NO;
}

- (void)dismiss {
    self.hidden = YES;
}

#pragma mark - Propertys

- (UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_reloadButton setTitle:@"重试" forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor colorWithRed:0.072 green:0.579 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadButtonClcik) forControlEvents:UIControlEventTouchUpInside];
        [_reloadButton sizeToFit];
    }
    return _reloadButton;
}

- (void)reloadButtonClcik {
    [self dismiss];
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = [UIColor colorWithWhite:0.798 alpha:1.000];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:15];
        _tipsLabel.text = @"网络出错";
        [_tipsLabel sizeToFit];
    }
    return _tipsLabel;
}

@end
