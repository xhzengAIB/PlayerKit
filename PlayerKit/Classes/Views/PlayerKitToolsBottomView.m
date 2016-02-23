//
//  PlayerKitToolsBottomView.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import "PlayerKitToolsBottomView.h"
#import "PlayerKitTimeTools.h"

@interface PlayerKitToolsBottomView ()

@property (nonatomic, copy) NSString *totalTimeString;
@property (nonatomic, copy) NSString *playingTimeString;

@end

@implementation PlayerKitToolsBottomView

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

- (void)setup {
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.8];
    
    [self addSubview:self.mediaControlButton];
    
    [self addSubview:self.progressView];
    [self addSubview:self.processingTimeLabel];
    
    [self addSubview:self.animationButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateElments];
}

- (void)updateElments {
    [self updateButtons];
    [self updateProgressView];
    [self updateProcessingTimeLabel];
}

- (void)updateTotalTimeString:(NSString *)totalTimeString {
    self.totalTimeString = totalTimeString;
    [self updateProcessingTimeLabelStyle];
    [self updateProcessingTimeLabel];
}

- (void)updatePlayingTimeString:(NSString *)playingTimeString {
    self.playingTimeString = playingTimeString;
    [self updateProcessingTimeLabelStyle];
    [self updateProcessingTimeLabel];
}

- (void)updateProcessingTimeLabelStyle {
    NSString *playingTimeString = self.playingTimeString;
    if (!playingTimeString) {
        playingTimeString = @"00:00:00";
    }
    if (!self.totalTimeString) {
        self.totalTimeString = @"00:00:00";
    }
    NSString *totalTimeString = [NSString stringWithFormat:@"/%@", self.totalTimeString];
    NSString *processingTimeString = [NSString stringWithFormat:@"%@%@", playingTimeString, totalTimeString];
    
    self.processingTimeLabel.attributedText = [PlayerKitTimeTools processingTimeAttributedString:processingTimeString
                                                                               playingTimeString:playingTimeString
                                                                                 totalTimeString:totalTimeString];
}

- (void)updateButtons {
    CGFloat sepator = 5;
    CGFloat animationButtonWidth = CGRectGetHeight(self.bounds);
    CGFloat animationButtonHeight = animationButtonWidth;
    
    CGRect mediaControlButtonFrame = CGRectMake(sepator, 0, animationButtonWidth, animationButtonHeight);
    self.mediaControlButton.frame = mediaControlButtonFrame;
    
    CGRect animationButtonFrame = CGRectMake(CGRectGetWidth(self.bounds) - animationButtonWidth - sepator, 0, animationButtonWidth, animationButtonHeight);
    self.animationButton.frame = animationButtonFrame;
}

- (void)updateProgressView {
    CGFloat sepator = 5;
    CGFloat paddingX = CGRectGetMaxX(self.mediaControlButton.frame) + sepator;
    
    CGRect progressViewFrame = CGRectMake(paddingX, 4, CGRectGetMinX(self.animationButton.frame) - sepator - paddingX, 18);
    self.progressView.frame = progressViewFrame;
}

- (void)updateProcessingTimeLabel {
    CGFloat progressIndicatorProtruding = 4;
    [self.processingTimeLabel sizeToFit];
    CGRect processingTimeLabelFrame = self.processingTimeLabel.frame;
    processingTimeLabelFrame.origin.x = CGRectGetMinX(self.progressView.frame);
    processingTimeLabelFrame.origin.y = (CGRectGetHeight(self.bounds) + CGRectGetMaxY(self.progressView.frame) - CGRectGetHeight(processingTimeLabelFrame) - progressIndicatorProtruding) / 2.0;
    self.processingTimeLabel.frame = processingTimeLabelFrame;
}

- (void)updatePlayControl:(BOOL)play {
    self.mediaControlButton.selected = play;
}

- (void)updateAnimated:(BOOL)animated {
    self.animationButton.selected = animated;
}

#pragma mark - Propertys

- (UIButton *)mediaControlButton {
    if (!_mediaControlButton) {
        _mediaControlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mediaControlButton setImage:[UIImage imageNamed:@"player-kit-play"] forState:UIControlStateNormal];
        [_mediaControlButton setImage:[UIImage imageNamed:@"player-kit-pause"] forState:UIControlStateSelected];
    }
    return _mediaControlButton;
}

- (PlayerKitProgressView *)progressView {
    if (!_progressView) {
        _progressView = [PlayerKitProgressView initilzerProgressViewWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.bounds), 20)];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressView;
}
- (UILabel *)processingTimeLabel {
    if (!_processingTimeLabel) {
        _processingTimeLabel = [UILabel new];
        _processingTimeLabel.backgroundColor = [UIColor clearColor];
        _processingTimeLabel.font = [UIFont systemFontOfSize:10.0f];
        _processingTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _processingTimeLabel;
}

- (UIButton *)animationButton {
    if (!_animationButton) {
        _animationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_animationButton setImage:[UIImage imageNamed:@"player-kit-animation-none"] forState:UIControlStateNormal];
        [_animationButton setImage:[UIImage imageNamed:@"player-kit-animation-animated"] forState:UIControlStateSelected];
    }
    return _animationButton;
}

@end
