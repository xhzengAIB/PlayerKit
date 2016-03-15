//
//  PlayerKitControlProgressTipsView.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "PlayerKitControlProgressTipsView.h"
#import "PlayerKitTimeTools.h"

@interface PlayerKitControlProgressTipsView () {
    struct {
        unsigned int showing:1;
    } _flags;
}

@property (nonatomic, strong) UIImageView *processingIconImageView;
@property (nonatomic, strong) UILabel *processingTimeLabel;

@end

@implementation PlayerKitControlProgressTipsView

- (void)setup {
    self.alpha = 0.0;
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.6];
    self.layer.cornerRadius = 8.0;
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.processingIconImageView];
    [self addSubview:self.processingTimeLabel];
}

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
    CGFloat width = 83;
    CGFloat height = 76;
    CGRect processingIconImageViewFrame = CGRectMake((CGRectGetWidth(self.bounds) - width) / 2.0, 15, width, height);
    self.processingIconImageView.frame = processingIconImageViewFrame;
    
    [self.processingTimeLabel sizeToFit];
    CGRect processingTimeLabelFrame = self.processingTimeLabel.frame;
    processingTimeLabelFrame.size.width = CGRectGetWidth(self.bounds);
    processingTimeLabelFrame.origin.y = CGRectGetMaxY(processingIconImageViewFrame) + 10;
    self.processingTimeLabel.frame = processingTimeLabelFrame;
}

- (void)layoutProcessingTimeLabel {
}

- (void)show {
    if (_flags.showing) {
        return;
    }
    self.alpha = 1.0;
    _flags.showing = YES;
}

- (void)dismiss {
    [self dismissDelay:0];
}

- (void)dismissDelay:(NSTimeInterval)delay {
    if (!_flags.showing) {
        return;
    }
    [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        _flags.showing = NO;
    }];
}

- (void)setTotalTimeString:(NSString *)totalTimeString {
    _totalTimeString = totalTimeString;
    [self updateTimeLabel];
}

- (void)setPlayingTimeString:(NSString *)playingTimeString {
    _playingTimeString = playingTimeString;
    [self updateTimeLabel];
}

- (void)setProcessingState:(PlayerKitProcessingState)processingState {
    _processingState = processingState;
    
    switch (processingState) {
        case PlayerKitProcessingStateBackward:
        case PlayerKitProcessingStateForward: {
            NSString *processingIconImageName = nil;
            if (processingState == PlayerKitProcessingStateBackward) {
                processingIconImageName = @"player-kit-backward";
            } else if (processingState == PlayerKitProcessingStateForward) {
                processingIconImageName = @"player-kit-forward";
            }
            self.processingIconImageView.image = [UIImage imageNamed:processingIconImageName];
            [self show];
            break;
        }
        default:
            [self dismissDelay:1];
            break;
    }
}

- (UIImageView *)processingIconImageView {
    if (!_processingIconImageView) {
        _processingIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _processingIconImageView;
}
- (UILabel *)processingTimeLabel {
    if (!_processingTimeLabel) {
        _processingTimeLabel = [UILabel new];
        _processingTimeLabel.text = @"Testing";
        _processingTimeLabel.backgroundColor = [UIColor clearColor];
        _processingTimeLabel.textColor = [UIColor whiteColor];
        _processingTimeLabel.font = [UIFont systemFontOfSize:16.0f];
        _processingTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _processingTimeLabel;
}

- (void)updateTimeLabel {
    NSString *playingTimeString = self.playingTimeString;
    if (!playingTimeString) {
        playingTimeString = @"00:00:00";
    }
    NSString *totalTimeString = self.totalTimeString;
    if (!totalTimeString) {
        totalTimeString = @"00:00:00/%@";
    } else {
        totalTimeString = [NSString stringWithFormat:@"/%@", self.totalTimeString];
    }
    
    NSString *processingTimeString = [NSString stringWithFormat:@"%@%@", playingTimeString, totalTimeString];
    
    self.processingTimeLabel.text = processingTimeString;
}

@end
