//
//  PlayerKitPlayerView.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "PlayerKitPlayerView.h"

#import "PlayerKitContainer.h"
#import "PlayerKitToolsTopView.h"
#import "PlayerKitToolsBottomView.h"
#import "PlayerKitControlProgressTipsView.h"
#import "PlayerKitReloadTipsView.h"

#import "PlayerKitTimeTools.h"

@interface PlayerKitPlayerView () {
    struct {
        unsigned int showingToolsView:1;
    } _flags;
}

// UI
@property (nonatomic, strong) PlayerKitControlProgressTipsView *controlProgressTipsView;
@property (nonatomic, strong) PlayerKitToolsTopView *toolsTopView;
@property (nonatomic, strong) PlayerKitToolsBottomView *toolsBottomView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) PlayerKitReloadTipsView *reloadTipsView;

// Block
@property (nonatomic, copy) PlayerKitAnimationBlock animationCompletion;

@property (nonatomic, copy) PlayerKitDidChangeTimeBlock didChangeTimeCompletion;

@property (nonatomic, copy) PlayerKitReloadBlock reloadCompletion;

@property (nonatomic, copy) PlayerKitDidTapButtonBlock playCompletion;
@property (nonatomic, copy) PlayerKitDidTapButtonBlock pauseCompletion;

//
@property (nonatomic, assign) CMTime totalTime;
@property (nonatomic, assign) PlayerKitAnimationType animationType;


@end

@implementation PlayerKitPlayerView
@synthesize playerContainer = _playerContainer;
@synthesize title = _title;

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

- (void)dealloc {
    [self destroyManuallyElement];
}

- (void)setup {
    _flags.showingToolsView = YES;
    _animationType = PlayerKitAnimationTypeNone;
    
    [self addSubview:self.indicatorView];
    [self addSubview:self.toolsTopView];
    [self addSubview:self.toolsBottomView];
    [self addSubview:self.controlProgressTipsView];
    [self addSubview:self.reloadTipsView];
    [self autoFadeOutControlBar];
}

- (void)animationToolsView:(BOOL)showing completion:(void (^ __nullable)(BOOL finished))completion {
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.toolsTopView.alpha = showing;
        self.toolsBottomView.alpha = showing;
    } completion:^(BOOL finished) {
        _flags.showingToolsView = showing;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)animateHideToolsView {
    if (!_flags.showingToolsView) {
        return;
    }
    if (self.playerContainer.animationType != PlayerKitAnimationTypeNone || !self.playerContainer.leaveblackBorderAtStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    [self animationToolsView:NO completion:NULL];
}

- (void)animateShowToolsView {
    if (_flags.showingToolsView) {
        return;
    }
    
    if (self.playerContainer.animationType != PlayerKitAnimationTypeNone || !self.playerContainer.leaveblackBorderAtStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    [self animationToolsView:YES completion:^(BOOL finished) {
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar {
    if (!_flags.showingToolsView) {
        return;
    }
    [self cancelAutoFadeOutControlBar];
    [self performSelector:@selector(animateHideToolsView) withObject:nil afterDelay:5];
}

- (void)cancelAutoFadeOutControlBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHideToolsView) object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIndicator];
    [self layoutReloadTips];
    [self layoutToolsTopViewWithType:self.animationType];
    [self layoutToolsBottomViewWithType:self.animationType];
    [self layoutControlProgressTipsView];
}

- (void)layoutIndicator {
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)layoutReloadTips {
    self.reloadTipsView.frame = self.bounds;
}

- (void)layoutToolsTopViewWithType:(PlayerKitAnimationType)animationType {
    self.toolsTopView.hidden = (animationType == PlayerKitAnimationTypeNone);
    self.toolsTopView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 64);
}

- (void)layoutToolsBottomViewWithType:(PlayerKitAnimationType)animationType {
    self.toolsBottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 44, CGRectGetWidth(self.bounds), 44);
    [self.toolsBottomView updateElments];
    [self.toolsBottomView updateAnimated:animationType != PlayerKitAnimationTypeNone];
}

- (void)layoutControlProgressTipsView {
    self.controlProgressTipsView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - Actions

- (void)addKVOWithPlayerContainer:(PlayerKitContainer *)playerContainer {
    [playerContainer addObserver:self forKeyPath:@"playbackState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [playerContainer addObserver:self forKeyPath:@"animationType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeKVOWithPlayerContainer:(PlayerKitContainer *)playerContainer {
    [playerContainer removeObserver:self forKeyPath:@"playbackState"];
    [playerContainer removeObserver:self forKeyPath:@"animationType"];
}

#pragma mark - Propertys

- (void)setPlayerContainer:(PlayerKitContainer *)playerContainer {
    PlayerKitContainer *oldPlayerContainer = _playerContainer;
    
    if (oldPlayerContainer != nil) {
        // Remove
        [self removeKVOWithPlayerContainer:oldPlayerContainer];
    }
    _playerContainer = playerContainer;
    if (playerContainer != nil) {
        // Add
        [self addKVOWithPlayerContainer:playerContainer];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.toolsTopView.titleLabel.text = title;
}

- (PlayerKitControlProgressTipsView *)controlProgressTipsView {
    if (!_controlProgressTipsView) {
        _controlProgressTipsView = [[PlayerKitControlProgressTipsView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    }
    return _controlProgressTipsView;
}

- (PlayerKitToolsTopView *)toolsTopView {
    if (!_toolsTopView) {
        _toolsTopView = [[PlayerKitToolsTopView alloc] initWithFrame:CGRectZero];
        _toolsTopView.titleLabel.text = self.title;
        [_toolsTopView.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolsTopView;
}

- (void)closeButtonClick:(UIButton *)sender {
    self.animationCompletion();
}

- (PlayerKitToolsBottomView *)toolsBottomView {
    if (!_toolsBottomView) {
        _toolsBottomView = [[PlayerKitToolsBottomView alloc] initWithFrame:CGRectZero];
        [_toolsBottomView.progressView addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
        [_toolsBottomView.mediaControlButton addTarget:self action:@selector(mediaControlButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toolsBottomView.animationButton addTarget:self action:@selector(animationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [_toolsBottomView.progressView addTarget:self action:@selector(willChange:) forControlEvents:UIControlEventTouchDown];
        [_toolsBottomView.progressView addTarget:self action:@selector(changeDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_toolsBottomView.progressView addTarget:self action:@selector(changeDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
        
        [_toolsBottomView.mediaControlButton addTarget:self action:@selector(willChange:) forControlEvents:UIControlEventTouchDown];
        [_toolsBottomView.mediaControlButton addTarget:self action:@selector(changeDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_toolsBottomView.mediaControlButton addTarget:self action:@selector(changeDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
        
        [_toolsBottomView.animationButton addTarget:self action:@selector(willChange:) forControlEvents:UIControlEventTouchDown];
        [_toolsBottomView.animationButton addTarget:self action:@selector(changeDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_toolsBottomView.animationButton addTarget:self action:@selector(changeDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _toolsBottomView;
}

- (PlayerKitReloadTipsView *)reloadTipsView {
    if (!_reloadTipsView) {
        _reloadTipsView = [[PlayerKitReloadTipsView alloc] init];
        [_reloadTipsView.reloadButton addTarget:self action:@selector(reloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadTipsView;
}

- (void)reloadButtonClick:(UIButton *)sender {
    if (self.reloadCompletion) {
        self.reloadCompletion();
    }
}

- (void)mediaControlButtonClick:(UIButton *)sender {
    if (sender.selected) {
        self.pauseCompletion(sender);
    } else {
        self.playCompletion(sender);
    }
}

- (void)animationButtonClick:(UIButton *)sender {
    self.animationCompletion();
}

- (void)sliderChangeValue:(UISlider *)slider {
    if (self.didChangeTimeCompletion) {
        self.didChangeTimeCompletion(slider.value);
    }
}

- (void)willChange:(UISlider *)slider {
    [self cancelAutoFadeOutControlBar];
}

- (void)changeDidEnd:(UISlider *)slider {
    [self autoFadeOutControlBar];
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

#pragma mark - PlayerKitPlayerViewProtocol Methods

- (void)animationCompletion:(PlayerKitAnimationBlock)completion {
    self.animationCompletion = completion;
}

- (void)playCompletion:(PlayerKitDidTapButtonBlock)completion {
    self.playCompletion = completion;
}
- (void)pauseCompletion:(PlayerKitDidTapButtonBlock)completion {
    self.pauseCompletion = completion;
}
- (void)sliderCurrentTimeValueCompletion:(PlayerKitDidChangeTimeBlock)completion {
    self.didChangeTimeCompletion = completion;
}
- (void)handleDownloadFailedReloadCompletion:(PlayerKitReloadBlock)comepltion {
    self.reloadCompletion = comepltion;
}

- (void)animationAction:(PlayerKitAnimationType)animationType {
    self.animationType = animationType;
    [self layoutIndicator];
    [self layoutReloadTips];
    [self layoutToolsTopViewWithType:animationType];
    [self layoutToolsBottomViewWithType:animationType];
    [self layoutControlProgressTipsView];
    
    if (animationType == PlayerKitAnimationTypeNone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:!_flags.showingToolsView withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)showIndicator {
    [self.indicatorView startAnimating];
}
- (void)hideIndicator {
    [self.indicatorView stopAnimating];
}
- (void)showDownloadFailed {
    [self.reloadTipsView show];
}
- (void)animatedControlElement {
    if (_flags.showingToolsView) {
        [self animateHideToolsView];
    } else {
        [self animateShowToolsView];
    }
}

- (void)updateTotalTime:(CMTime)totalTime {
    self.totalTime = totalTime;
    // 更新时间标签
    NSString *totalTimeString = [PlayerKitTimeTools converTime:totalTime];
    [self.toolsBottomView updateTotalTimeString:totalTimeString];
    self.controlProgressTipsView.totalTimeString = totalTimeString;
}
- (void)updateBufferringTime:(CMTime)bufferringTime {
    [self.toolsBottomView.progressView setBufferProgress:CMTimeGetSeconds(bufferringTime) / CMTimeGetSeconds(self.totalTime)];
}
- (void)updatePlayingTime:(CMTime)playingTime {
    [self.toolsBottomView.progressView setProgress:CMTimeGetSeconds(playingTime) / CMTimeGetSeconds(self.totalTime)];
    // 更新时间标签
    NSString *playingTimeString = [PlayerKitTimeTools converTime:playingTime];
    [self.toolsBottomView updatePlayingTimeString:playingTimeString];
    self.controlProgressTipsView.playingTimeString = playingTimeString;
}
- (void)updateControlProcessing:(PlayerKitProcessingState)processingState {
    self.controlProgressTipsView.processingState = processingState;
}

- (void)destroyManuallyElement {
    self.playerContainer = nil;
    [self cancelAutoFadeOutControlBar];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"playbackState"]) {
        PlayerKitPlaybackState state = [change[NSKeyValueChangeNewKey] integerValue];
        [self.toolsBottomView updatePlayControl:(state == PlayerKitPlaybackStatePlaying)];
    } else if ([keyPath isEqualToString:@"animationType"]) {
        PlayerKitAnimationType animationType = [change[NSKeyValueChangeNewKey] integerValue];
        [self.toolsBottomView updateAnimated:(animationType != PlayerKitAnimationTypeNone)];
    }
}

@end
