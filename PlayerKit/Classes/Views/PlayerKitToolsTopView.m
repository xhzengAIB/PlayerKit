//
//  PlayerKitToolsTopView.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "PlayerKitToolsTopView.h"

@implementation PlayerKitToolsTopView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.88];

    [self addSubview:self.closeButton];
    [self addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat size = 44;
    CGRect closeButtonFrame = self.closeButton.frame;
    closeButtonFrame.size = CGSizeMake(size, size);
    closeButtonFrame.origin.y = 20;
    self.closeButton.frame = closeButtonFrame;
    
    CGRect titleLabelFrame = CGRectMake(CGRectGetMaxX(closeButtonFrame) + 10, 20, CGRectGetMidX(self.bounds), 42);
    self.titleLabel.frame = titleLabelFrame;
}

#pragma mark - Propertys

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"player-kit-close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"测试标题";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

@end
