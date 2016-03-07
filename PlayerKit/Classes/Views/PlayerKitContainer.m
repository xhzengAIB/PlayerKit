//
//  PlayerKitContainer.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import "PlayerKitContainer.h"
#import <MediaPlayer/MediaPlayer.h>

#import "PlayerKitPlayerView.h"
#import "UIViewController+PlayerKitAdditions.h"

// Default Steps
static CGFloat const ZHXPlayerVolumeStep = 0.02f;
static CGFloat const ZHXPlayerBrightnessStep = 0.02f;
static CGFloat const ZHXPlayerPlaybackSpeedStep = 0.25f;
static CGFloat const ZHXPlayerMediaProgressStepStep = 0.5f;

// KVO Contexts
static NSString * const ZXHPlayerObserverContext = @"ZXHPlayerObserverContext";
static NSString * const ZXHPlayerItemObserverContext = @"ZXHPlayerItemObserverContext";
static NSString * const ZXHPlayerPreloadObserverContext = @"ZXHPlayerPreloadObserverContext";
static NSString * const ZXHPlayerLayerObserverContext = @"ZXHPlayerLayerObserverContext";

// KVO Player Keys
static NSString * const ZXHPlayerContainerRateKey = @"rate";

// KVO Player Item Keys
static NSString * const ZXHPlayerContainerStatusKey = @"status";
static NSString * const ZXHPlayerContainerEmptyBufferKey = @"playbackBufferEmpty";
static NSString * const ZXHPlayerContainerPlayerKeepUpKey = @"playbackLikelyToKeepUp";
static NSString * const ZXHPlayerContainerPlayerBufferFullKey = @"playbackBufferFull";

// KVO Player Preload Keys
static NSString * const ZXHPlayerContainerPlayerLoadedTimeRanges = @"loadedTimeRanges";

// KVO Player Layer Keys
static NSString * const ZXHPlayerContainerReadyForDisplay = @"readyForDisplay";

// Player Item Load Keys
static NSString * const ZXHPlayerContainerTracksKey = @"tracks";
static NSString * const ZXHPlayerContainerPlayableKey = @"playable";
static NSString * const ZXHPlayerContainerDurationKey = @"duration";

@interface PlayerKitContainer () {
    
@private
    // Observer
    id _playbackTimeObserver;
    
    // Gestures
    CGPoint _currentLocation;
    
    // Flags
    struct {
        unsigned int firstDeadyForDisplay:1;
        unsigned int userPaused:1;
        unsigned int userNeedFullScreenMode:1;
        unsigned int readPlayer:1;
        unsigned int animating:1;
        unsigned int recordPlaybackState:1;
        unsigned int localFiled:1;
    } _flags;
}

// AVFoundation
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) CGFloat currentTimeValue;

// Orientation
@property (nonatomic, assign) UIDeviceOrientation currnetOrientation;

// Animation Type
@property (nonatomic, assign, readwrite) PlayerKitAnimationType animationType;

// Base Info
@property (nonatomic, assign, readwrite) CMTime totalDuration;
@property (nonatomic, assign, readwrite) CMTime readDuration;
@property (nonatomic, assign, readwrite) CMTime bufferDuration;
@property (nonatomic, assign, readwrite) PlayerKitPlaybackState playbackState;
@property (nonatomic, assign, readwrite) PlayerKitBufferingState bufferingState;

// Gestures
@property (nonatomic, assign) PlayerKitGestureState gestureState;
@property (nonatomic, assign) PlayerKitGestureDirection gestureDirection;
@property (nonatomic, assign) CGFloat gestureTimeValue;

@end

@implementation PlayerKitContainer
@synthesize volume = _volume;

- (void)commit {
    self.clipsToBounds = YES;
    
    _readDuration = kCMTimeZero;
    _bufferDuration = kCMTimeZero;
    _minPreloadBufferTimeToPlay = 10.0f;
    _volume = 1.0;
    
    _autoPlaybackToMinPreloadBufferTime = YES;
    _playbackLoops = NO;
    _allowControlVolumeForGesture = YES;
    _allowControlBrightnessForGesture = YES;
    _allowControlPlaybackSpeedForGesture = NO;
    _allowControlMediaProgressForGesture = YES;
    _leaveblackBorderAtStatusBar = YES;
    
    _flags.firstDeadyForDisplay = NO;
    _flags.userPaused = NO;
    _flags.userNeedFullScreenMode = NO;
    _flags.readPlayer = NO;
    _flags.animating = NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commit];
        _presentFrame = frame;
    }
    return self;
}

- (instancetype)init {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]) / 3.0);
    self = [self initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [self commit];
    _presentFrame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]) / 3.0);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self destroyPlayerContainer];
    }
}

- (void)dealloc {
    [self disBuildInterface];
    
    [self playerPause];
    
    _delegate = nil;
    
    _playerView.player = nil;
    
    [self removeObserverWithPlayer:_player];
    _player = nil;
    
    [self removeNotification];
    
    [self setPlayerItem:nil];
    
    [self setPlayerView:nil];
}

#pragma mark - Public Methods

- (void)buildInterface {
    [self setup];
    
    [self setupPlayer];
    [self setupPlayerView];
    [self addNotification];
    [self loadMediaData];
}

- (void)prepareForReuse {
    [self stop];
}

#pragma mark - Setup Methods

- (void)setup {
    [self updateLayout];
}

- (void)setupPlayer {
    self.player = [[AVPlayer alloc] init];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    self.player.volume = self.volume;
    
    // Player KVO
    [self addObserverWithPlayer:self.player];
}

- (void)setupPlayerView {
    // load the playerLayer view
    if (!_playerView) {
        // 如果外部没有定制的话，直接使用内部的UI
        PlayerKitPlayerView *playerView = [[PlayerKitPlayerView alloc] initWithFrame:CGRectZero];
        [self setPlayerView:playerView];
    }
}

- (void)loadMediaData {
    if (!self.mediaAsset) {
        return;
    }
    [self showIndicator];
    
    NSArray *keys = @[ZXHPlayerContainerTracksKey,
                      ZXHPlayerContainerPlayableKey,
                      ZXHPlayerContainerDurationKey];
    
    __weak typeof(self.mediaAsset) weakAsset = self.mediaAsset;
    __weak typeof(self) weakSelf = self;
    [self.mediaAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // check the keys
            for (NSString *key in keys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [weakAsset statusOfValueForKey:key error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    [weakSelf callBackDelegateWithPlaybackState:PlayerKitPlaybackStateFailed];
                    NSLog(@"error (%@)", [[error userInfo] objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey]);
                    return;
                }
            }
            
            // check playable
            if (!weakAsset.playable) {
                [weakSelf callBackDelegateWithPlaybackState:PlayerKitPlaybackStateFailed];
                return;
            }
            
            // setup player
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:weakAsset];
            [weakSelf setPlayerItem:playerItem];
        });
    }];
}

- (void)reloadMediaData {
    [self updateMediaAssetWithMediaPath:self.mediaPath];
    [self loadMediaData];
}

#pragma mark - Propertys

- (void)setPlaybackState:(PlayerKitPlaybackState)playbackState {
    _playbackState = playbackState;
    if (playbackState == PlayerKitPlaybackStateFailed) {
        [self showDownloadFailed];
    }
}

- (void)setBufferingState:(PlayerKitBufferingState)bufferingState {
    _bufferingState = bufferingState;
    switch (bufferingState) {
        case PlayerKitBufferingStateBuffering:
        case PlayerKitBufferingStateDelayed: {
            // 判断现在是否有网络，如果没有网络就需要通知缓冲停止了
            if (self.bufferingState != PlayerKitBufferingStateFull && !_flags.localFiled) {
                [self showIndicator];
            }
            break;
        }
        case PlayerKitBufferingStateFull:
        case PlayerKitBufferingStateUpToGrade: {
            [self hideIndicator];
            break;
        }
        default:
            break;
    }
}

- (void)setPlaybackLoops:(BOOL)playbackLoops {
    _playbackLoops = playbackLoops;
    if (!self.player)
        return;
    
    if (!playbackLoops) {
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
}

- (CGFloat)volume {
    return self.player.volume;
}

- (void)setVolume:(CGFloat)volume {
    if (!self.player) {
        return;
    }
    
    self.player.volume = volume;
}

- (void)setVideoFillMode:(NSString *)videoFillMode {
    if (_videoFillMode == videoFillMode) {
        return;
    }
    _videoFillMode = videoFillMode;
    self.playerView.videoFillMode = videoFillMode;
}

- (void)setMediaPath:(NSString *)mediaPath {
    if (_mediaPath == mediaPath) {
        return;
    }
    if (!mediaPath || !mediaPath.length) {
        _mediaPath = nil;
        [self setMediaAsset:nil];
        return;
    }
    
    _mediaPath = [mediaPath copy];
    [self updateMediaAssetWithMediaPath:_mediaPath];
}

- (void)updateMediaAssetWithMediaPath:(NSString *)mediaPath {
    NSURL *mediaURL = [NSURL URLWithString:mediaPath];
    
    _flags.localFiled = NO;
    if (!mediaURL || ![mediaURL scheme]) {
        _flags.localFiled = YES;
        mediaURL = [NSURL fileURLWithPath:mediaPath];
    }
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:mediaURL options:nil];
    [self setMediaAsset:urlAsset];
}

- (void)setMediaAsset:(AVAsset *)mediaAsset {
    if (_mediaAsset == mediaAsset) {
        return;
    }
    
    // 判断是否在播放，如果在播放，需要先暂停一下
    if (self.playbackState == PlayerKitPlaybackStatePlaying && _mediaAsset) {
        [self stop];
    }
    
    [self callBackDelegateWithBufferingState:PlayerKitBufferingStateBuffering];
    
    _mediaAsset = mediaAsset;
    
    // 如果没有媒体资源文件，那就置空PlayerItem
    if (!_mediaAsset) {
        [self setPlayerItem:nil];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {
        return;
    }
    
    if (_playerItem) {
        // Remove KVO
        [self removeObserverWithPlayerItem:_playerItem];
        [self removeNotificationWithPlayerItem:_playerItem];
        [_playerItem cancelPendingSeeks];
        _playerItem = nil;
    }
    
    _playerItem = playerItem;
    // 再次确认不是为空的
    if (playerItem) {
        // Add KVO and Notification
        [self addObserverWithPlayerItem:playerItem];
        
        [self addNotificationWithPlayerItem:playerItem];
        
        [self callBackDelegateWithDidLoadMediaTotalDuration];
    }
    
    if (!self.playbackLoops) {
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)setPresentFrame:(CGRect)presentFrame {
    _presentFrame = presentFrame;
    // Update Control Layout
    [self updateLayout];
}

- (void)setPlayerView:(UIView <PlayerKitPlayerViewProtocol> *)playerView {
    if (_playerView) {
        // Remove PlayerLayer KVO
        [self removeObserverWithPlayerLayer:_playerView.playerLayer];
        [self destroyPlayerContainer];
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
    _playerView = playerView;
    if (_playerView) {
        [self addSubview:playerView];
        
        if (self.videoFillMode) {
            playerView.videoFillMode = self.videoFillMode;
        }
        playerView.frame = self.bounds;
        playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if ([playerView respondsToSelector:@selector(playerContainer)]) {
            playerView.playerContainer = self;
        }
        
        playerView.player = self.player;
        
        // Add PlayerLayer KVO
        [self addObserverWithPlayerLayer:playerView.playerLayer];
        
        // Mornitor player view protocol
        [self mornitorPlayerView];
    }
}

- (CMTime)totalDuration {
    CMTime totalDuration = kCMTimeZero;
    
    if (CMTIME_IS_NUMERIC(self.playerItem.duration)) {
        totalDuration = self.playerItem.duration;
    }
    
    return totalDuration;
}

- (BOOL)isPlaying {
    return self.player.rate != 0.f;
}

- (CGRect)topToolsBarFrame {
    if ([self.playerView respondsToSelector:@selector(topToolsBarFrame)]) {
        return self.playerView.topToolsBarFrame;
    }
    return CGRectZero;
}

- (CGRect)bottomToolsBarFrame {
    if ([self.playerView respondsToSelector:@selector(bottomToolsBarFrame)]) {
        return self.playerView.bottomToolsBarFrame;
    }
    return CGRectZero;
}

#pragma mark - Animation Actions

- (void)controlAnimation {
    if (self.animationType != PlayerKitAnimationTypeNone) {
        [self restoreMode];
        _flags.userNeedFullScreenMode = NO;
    } else {
        _flags.userNeedFullScreenMode = YES;
        [self animationWithAnimationType:PlayerKitAnimationTypeClockwise];
    }
}

- (void)updateLayout {
    if (self.leaveblackBorderAtStatusBar) {
        CGRect presentFrame = self.presentFrame;
        presentFrame.origin.y = 20;
        presentFrame.size.height -= 20;
        _presentFrame = presentFrame;
    }
    self.frame = self.presentFrame;
    self.playerView.frame = self.bounds;
    [self.playerView setNeedsLayout];
    [self.playerView layoutIfNeeded];
}

- (void)dismiss {
    if ([self.delegate respondsToSelector:@selector(dismissPlayer)]) {
        [(UIViewController *)self.delegate dismissPlayer];
    }
}

- (void)mornitorPlayerView {
    __weak typeof(self) weakSelf = self;
    if ([self.playerView respondsToSelector:@selector(animationCompletion:)]) {
        [self.playerView animationCompletion:^(void) {
            [weakSelf controlAnimation];
        }];
    }
    
    if ([self.playerView respondsToSelector:@selector(playCompletion:)]) {
        [self.playerView playCompletion:^(UIButton *sender) {
            if (weakSelf.playbackState == PlayerKitPlaybackStateStopped) {
                [weakSelf playBeginning];
            } else {
                [weakSelf playCurrentTime];
            }
        }];
    }
    if ([self.playerView respondsToSelector:@selector(pauseCompletion:)]) {
        [self.playerView pauseCompletion:^(UIButton *sender) {
            [weakSelf userPause];
        }];
    }
    if ([self.playerView respondsToSelector:@selector(sliderCurrentTimeValueCompletion:)]) {
        [self.playerView sliderCurrentTimeValueCompletion:^(float currentTimeValue) {
            CGFloat currentMediaDuration = currentTimeValue * CMTimeGetSeconds(weakSelf.totalDuration);
            [weakSelf seekCurrentTimaValue:currentMediaDuration];
        }];
    }
    if ([self.playerView respondsToSelector:@selector(handleDownloadFailedReloadCompletion:)]) {
        [self.playerView handleDownloadFailedReloadCompletion:^{
            [weakSelf reloadMediaData];
        }];
    }
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation {
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
}

- (void)disBuildInterface {
    [self setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [self callBackDelegateWithDimiss];
}

#pragma mark - Player Control Actions

- (void)destroyPlayerContainer {
    if ([_playerView respondsToSelector:@selector(destroyManuallyElement)]) {
        [_playerView destroyManuallyElement];
    }
}

- (void)playerControl {
    if (self.mediaPath || self.mediaAsset) {
        switch (self.playbackState) {
            case PlayerKitPlaybackStateStopped: {
                [self playBeginning];
                break;
            }
            case PlayerKitPlaybackStatePaused: {
                [self playCurrentTime];
                break;
            }
            case PlayerKitPlaybackStatePlaying:
            case PlayerKitPlaybackStateFailed:
            default: {
                [self userPause];
                break;
            }
        }
    }
}

- (void)playBeginning {
    [self callBackDelegateWithWillStartBeginning];
    [self hideIndicator];
    self.readDuration = kCMTimeZero;
    [self.player seekToTime:kCMTimeZero];
    [self playCurrentTime];
}

- (void)playCurrentTime {
    if (self.playbackState == PlayerKitPlaybackStatePlaying) {
        return;
    }
    [self hideIndicator];
    [self playerPlay];
    [self callBackDelegateWithPlaybackState:PlayerKitPlaybackStatePlaying];
}

- (void)pause {
    if (self.playbackState == PlayerKitPlaybackStatePaused) {
        return;
    }
    [self playerPause];
    [self callBackDelegateWithPlaybackState:PlayerKitPlaybackStatePaused];
}

- (void)machinePause {
    _flags.userPaused = NO;
    [self pause];
}

- (void)userPause {
    _flags.userPaused = YES;
    [self pause];
}

- (void)stop {
    if (self.playbackState == PlayerKitPlaybackStateStopped) {
        return;
    }
    [self playerPause];
    [self callBackDelegateWithDidChangeReadDuration:kCMTimeZero];
    [self callBackDelegateWithDidChangeBufferDuration:kCMTimeZero];
    [self callBackDelegateWithPlaybackState:PlayerKitPlaybackStateStopped];
}

- (void)seekCurrentTimaValue:(float)currentTimeValue {
    __weak typeof(self) weakSelf = self;
    [self pause];
    [self.player seekToTime:CMTimeMake(currentTimeValue, 1.0f) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf playCurrentTime];
    }];
}

- (void)playerPlay {
    if (![self isPlaying]) {
        [self.player play];
    }
}

- (void)playerPause {
    if ([self isPlaying]) {
        [self.player pause];
    }
}

- (void)playerStop {
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

#pragma mark - UIGesture Handle Methods

- (void)handleDoubleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self playerControl];
    }
}

#pragma mark - AVFoundation Handle NSNotificaion Methods

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    if (!self.playbackLoops) {
        [self stop];
        [self callBackDelegateWithPlaybackDidEnd];
    } else {
        [self.player seekToTime:kCMTimeZero];
    }
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification {
    [self callBackDelegateWithPlaybackState:PlayerKitPlaybackStateFailed];
    NSLog(@"error (%@)", [[notification userInfo] objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey]);
}

#pragma mark - App Handle NSNotificaion Methods

- (void)applicationWillResignActive:(NSNotification *)notification {
    _flags.recordPlaybackState = self.playbackState;
    if (self.playbackState == PlayerKitPlaybackStatePlaying) {
        [self machinePause];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.playbackState == PlayerKitPlaybackStatePlaying) {
        [self machinePause];
    }
}

- (void)deviceOrientationDidChange {
    // 这里有两个逻辑，第一个是水平反转映射，第二是90度旋转（分别顺时针和逆时针）
    // 搞清楚情况，在什么情况下水平反转呢？在什么情况下旋转呢？
    
    UIDeviceOrientation currnetOrientation = [[UIDevice currentDevice] orientation];
    UIDeviceOrientation oldOrientation = _currnetOrientation;
    self.currnetOrientation = currnetOrientation;
    
    if (_flags.userNeedFullScreenMode) {
        // 用户自己想要全屏，所以程序不会自动控制
        return;
    }
    
    switch (currnetOrientation) {
        case UIDeviceOrientationPortrait: {
            if (self.animationType != PlayerKitAnimationTypeNone) {
                [self restoreMode];
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            if (self.animationType == PlayerKitAnimationTypeAnticlockwise) {
                // 水平反转
                self.animationType = PlayerKitAnimationTypeClockwise;
                [self horizontalFlipOrientation:oldOrientation];
            } else {
                [self animationWithAnimationType:PlayerKitAnimationTypeClockwise];
            }
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            if (self.animationType == PlayerKitAnimationTypeClockwise) {
                // 水平反转
                self.animationType = PlayerKitAnimationTypeAnticlockwise;
                [self horizontalFlipOrientation:oldOrientation];
            } else {
                [self animationWithAnimationType:PlayerKitAnimationTypeAnticlockwise];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Delegate Helper Methods

- (void)callBackDelegateWithPlaybackState:(PlayerKitPlaybackState)playbackState {
    self.playbackState = playbackState;
    if ([self.delegate respondsToSelector:@selector(playerKitContainerPlaybackStateDidChange:)]) {
        [self.delegate playerKitContainerPlaybackStateDidChange:self];
    }
}

- (void)callBackDelegateWithBufferingState:(PlayerKitBufferingState)bufferingState {
    self.bufferingState = bufferingState;
    if ([self.delegate respondsToSelector:@selector(playerKitContainerBufferringStateDidChange:)]) {
        [self.delegate playerKitContainerBufferringStateDidChange:self];
    }
}

- (void)callBackDelegateWithWillStartBeginning {
    if ([self.delegate respondsToSelector:@selector(playerKitContainerPlaybackWillStartBeginning:)]) {
        [self.delegate playerKitContainerPlaybackWillStartBeginning:self];
    }
}

- (void)callBackDelegateWithPlaybackDidEnd {
    if ([self.delegate respondsToSelector:@selector(playerKitContainerPlaybackDidEnd:)]) {
        [self.delegate playerKitContainerPlaybackDidEnd:self];
    }
}

- (void)callBackDelegateWithReady {
    if ([self.delegate respondsToSelector:@selector(playerKitContainerReady:)]) {
        [self.delegate playerKitContainerReady:self];
    }
}

- (void)callBackDelegateWithDidChangeBufferDuration:(CMTime)bufferDuration {
    self.bufferDuration = bufferDuration;
    if ([self.playerView respondsToSelector:@selector(updateBufferringTime:)]) {
        [self.playerView updateBufferringTime:bufferDuration];
    }
    if ([self.delegate respondsToSelector:@selector(playerKitContainer:didChangeBufferDuration:)]) {
        [self.delegate playerKitContainer:self didChangeBufferDuration:bufferDuration];
    }
}

- (void)callBackDelegateWithDidChangeReadDuration:(CMTime)readDuration {
    self.readDuration = readDuration;
    if ([self.playerView respondsToSelector:@selector(updatePlayingTime:)]) {
        [self.playerView updatePlayingTime:readDuration];
    }
    if ([self.delegate respondsToSelector:@selector(playerKitContainer:didChangeReadDuration:)]) {
        [self.delegate playerKitContainer:self didChangeReadDuration:readDuration];
    }
}

- (void)callBackDelegateWithDidLoadMediaTotalDuration {
    if ([self.playerView respondsToSelector:@selector(updateTotalTime:)]) {
        [self.playerView updateTotalTime:self.totalDuration];
    }
    if ([self.delegate respondsToSelector:@selector(playerKitContainer:didLoadMediaTotalDuration:)]) {
        [self.delegate playerKitContainer:self didLoadMediaTotalDuration:self.totalDuration];
    }
}

- (void)callBackDelegateWithDimiss {
    if ([self.delegate respondsToSelector:@selector(playerKitContainerDidDismiss:)]) {
        [self.delegate playerKitContainerDidDismiss:self];
    }
}

- (void)callBackDelegateWithAnimationType:(PlayerKitAnimationType)animationType {
    if ([self.delegate respondsToSelector:@selector(playerKitContainer:willAnimationWithType:)]) {
        [self.delegate playerKitContainer:self willAnimationWithType:animationType];
    }
}

- (void)callBackDelegateWithAnimationElement {
    if ([self.delegate respondsToSelector:@selector(playerKitContainerDidAnimationElement:)]) {
        [self.delegate playerKitContainerDidAnimationElement:self];
    }
}

#pragma mark - PlayerView Protocal Helper Methods

#pragma mark - Animation Helper Methods

- (void)animationWithAnimationType:(PlayerKitAnimationType)animationType {
    if (_animationType == animationType) {
        return;
    }
    if (_flags.animating) {
        return;
    }
    self.animationType = animationType;
    _flags.animating = YES;
    [self callBackDelegateWithAnimationType:self.animationType];
    switch (animationType) {
        case PlayerKitAnimationTypeZoom: {
            [UIView animateWithDuration:0.3 animations:^{
                self.transform = CGAffineTransformMakeScale(2.0, 2.0);
                [self animationPlayerView];
            } completion:^(BOOL finished) {
                _flags.animating = NO;
            }];
            break;
        }
        case PlayerKitAnimationTypeAnticlockwise:
        case PlayerKitAnimationTypeClockwise: {
            CGRect mainBounds = [[UIScreen mainScreen] bounds];
            CGFloat height = CGRectGetWidth(mainBounds);
            CGFloat width = CGRectGetHeight(mainBounds);
            CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
            UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationLandscapeRight;
            CGFloat angle = M_PI_2;
            if (animationType == PlayerKitAnimationTypeAnticlockwise) {
                interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
                angle = -M_PI_2;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = frame;
                [self setTransform:CGAffineTransformMakeRotation(angle)];
                [self setStatusBarOrientation:interfaceOrientation];
                [self animationPlayerView];
            } completion:^(BOOL finished) {
                _flags.animating = NO;
            }];
            break;
        }
        default:
            break;
    }
}

- (void)horizontalFlipOrientation:(UIDeviceOrientation)orientation {
    if (_flags.animating) {
        return;
    }
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationLandscapeRight;
    CGFloat angle = M_PI_2;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
        angle = -M_PI_2;
    }
    CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    _flags.animating = YES;
    [self callBackDelegateWithAnimationType:self.animationType];
    [UIView animateWithDuration:0.55 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.layer.transform = transform;
        [self setStatusBarOrientation:interfaceOrientation];
        [self animationPlayerView];
    } completion:^(BOOL finished) {
        _flags.animating = NO;
    }];
}

- (void)restoreMode {
    self.animationType = PlayerKitAnimationTypeNone;
    _flags.animating = YES;
    [self callBackDelegateWithAnimationType:self.animationType];
    [UIView animateWithDuration:0.3 animations:^{
        [self setTransform:CGAffineTransformIdentity];
        self.frame = self.presentFrame;
        [self setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [self animationPlayerView];
    } completion:^(BOOL finished) {
        _flags.animating = NO;
    }];
}

- (void)showIndicator {
    if ([self.playerView respondsToSelector:@selector(showIndicator)]) {
        [self.playerView showIndicator];
    }
}

- (void)hideIndicator {
    if ([self.playerView respondsToSelector:@selector(hideIndicator)]) {
        [self.playerView hideIndicator];
    }
}

- (void)showDownloadFailed {
    [self hideIndicator];
    if ([self.playerView respondsToSelector:@selector(showDownloadFailed)]) {
        [self.playerView showDownloadFailed];
    }
}

- (void)animationPlayerView {
    if ([self.playerView respondsToSelector:@selector(animationAction:)]) {
        [self.playerView animationAction:self.animationType];
    }
}

#pragma mark - KVO Helper Methods

- (void)addObserverWithPlayer:(AVPlayer *)player {
    [player addObserver:self forKeyPath:ZXHPlayerContainerRateKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)ZXHPlayerObserverContext];
    // Player Observer
    __weak __typeof(self) weakSelf = self;
    _playbackTimeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1.0f, 1.0f) queue:NULL usingBlock:^(CMTime time) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf->_flags.readPlayer && strongSelf.playbackState == PlayerKitPlaybackStatePlaying && strongSelf.playerItem && strongSelf.player) {
            [strongSelf callBackDelegateWithDidChangeReadDuration:time];
        }
    }];
}

- (void)removeObserverWithPlayer:(AVPlayer *)player {
    [player removeObserver:self forKeyPath:ZXHPlayerContainerRateKey context:(__bridge void *)ZXHPlayerObserverContext];
    
    [player removeTimeObserver:_playbackTimeObserver];
}

- (void)addObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem addObserver:self forKeyPath:ZXHPlayerContainerEmptyBufferKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ZXHPlayerItemObserverContext)];
    [playerItem addObserver:self forKeyPath:ZXHPlayerContainerPlayerKeepUpKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ZXHPlayerItemObserverContext)];
    [playerItem addObserver:self forKeyPath:ZXHPlayerContainerPlayerBufferFullKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ZXHPlayerItemObserverContext)];
    [playerItem addObserver:self forKeyPath:ZXHPlayerContainerStatusKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ZXHPlayerItemObserverContext)];
    [playerItem addObserver:self forKeyPath:ZXHPlayerContainerPlayerLoadedTimeRanges options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ZXHPlayerPreloadObserverContext)];
}

- (void)removeObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:ZXHPlayerContainerEmptyBufferKey context:(__bridge void *)ZXHPlayerItemObserverContext];
    [playerItem removeObserver:self forKeyPath:ZXHPlayerContainerPlayerKeepUpKey context:(__bridge void *)ZXHPlayerItemObserverContext];
    [playerItem removeObserver:self forKeyPath:ZXHPlayerContainerPlayerBufferFullKey context:(__bridge void *)ZXHPlayerItemObserverContext];
    [playerItem removeObserver:self forKeyPath:ZXHPlayerContainerStatusKey context:(__bridge void *)ZXHPlayerItemObserverContext];
    [playerItem removeObserver:self forKeyPath:ZXHPlayerContainerPlayerLoadedTimeRanges context:(__bridge void *)ZXHPlayerPreloadObserverContext];
}

- (void)addObserverWithPlayerLayer:(AVPlayerLayer *)playeraLayer {
    [playeraLayer addObserver:self forKeyPath:ZXHPlayerContainerReadyForDisplay options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ZXHPlayerLayerObserverContext)];
}

- (void)removeObserverWithPlayerLayer:(AVPlayerLayer *)playeraLayer {
    [playeraLayer removeObserver:self forKeyPath:ZXHPlayerContainerReadyForDisplay context:(__bridge void *)ZXHPlayerLayerObserverContext];
}

#pragma mark - Notification Helper Methods

- (void)addNotification {
    // Application NSNotifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)removeNotification {
    // notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)addNotificationWithPlayerItem:(AVPlayerItem *)playerItem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
}

- (void)removeNotificationWithPlayerItem:(AVPlayerItem *)playerItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
}

#pragma mark - Validation Helper Methos

- (void)validationLoadedTimeRanges:(NSArray *)timeRanges {
    if (timeRanges && [timeRanges count]) {
        CMTimeRange timerange = [[timeRanges firstObject] CMTimeRangeValue];
        CMTime bufferDuration = CMTimeAdd(timerange.start, timerange.duration);
        
        [self callBackDelegateWithDidChangeBufferDuration:bufferDuration];
        
        [self validationBufferduration:bufferDuration];
    }
}

- (void)validationBufferduration:(CMTime)bufferDuration {
    CMTime minPreloadBufferDuration = CMTimeMake(self.minPreloadBufferTimeToPlay, 1.0f);
    // 如果预设的最小缓冲时间比总时间大的时候需要做特殊处理
    if (CMTIME_COMPARE_INLINE(minPreloadBufferDuration, >, self.totalDuration)) {
        minPreloadBufferDuration = CMTimeMake(CMTimeGetSeconds(self.totalDuration) / 3.0, 1.0f);
    }
    
    CMTime milestone = CMTimeAdd(self.playerItem.currentTime, minPreloadBufferDuration);
    
    if (CMTIME_COMPARE_INLINE(bufferDuration, >=, milestone)) {
        // 如果不是用户自己手动暂停的话，缓冲达到要求，就会自动播放
        if (self.autoPlaybackToMinPreloadBufferTime && !_flags.userPaused && ![self isPlaying]) {
            [self playCurrentTime];
        }
        
        // 如果缓冲区达到要求
        self.bufferingState = PlayerKitBufferingStateUpToGrade;
    } else {
        // 缓冲区达不到要求
        
        self.bufferingState = PlayerKitBufferingStateDelayed;
    }
}

#pragma mark - Touches handle Methods

// 声音增加
- (void)volumePlus:(CGFloat)step {
    if (self.allowControlVolumeForGesture) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [MPMusicPlayerController applicationMusicPlayer].volume += step;
#pragma clang diagnostic pop
    }
}

// 亮度增加
- (void)brightnessPlus:(CGFloat)step {
    if (self.allowControlBrightnessForGesture) {
        [UIScreen mainScreen].brightness += step;
    }
}

// 播放速度
- (void)playbackSpeedPlus:(CGFloat)step {
    if (self.allowControlPlaybackSpeedForGesture) {
        [self machinePause];
        self.player.rate += step;
    }
}

// 媒体进度
- (void)mediaProgressPlus:(CGFloat)step {
    [self machinePause];
    // 当前时间累加step时间 我知道了，只获取第一次，然后再累加手势，而不是直接累加，哈哈
    CGFloat dragDownTimeValue = CMTimeGetSeconds(self.playerItem.currentTime);
    self.gestureTimeValue += step;
    
    CGFloat dragedTimeValue = dragDownTimeValue + self.gestureTimeValue;
    if (dragedTimeValue > CMTimeGetSeconds(self.totalDuration)) {
        dragedTimeValue = CMTimeGetSeconds(self.totalDuration);
    } else if (dragedTimeValue < 0 || isnan(dragedTimeValue)) {
        dragedTimeValue = 0;
    }
    self.currentTimeValue = dragedTimeValue;
    if ([self.playerView respondsToSelector:@selector(updatePlayingTime:)]) {
        [self.playerView updatePlayingTime:CMTimeMake(self.currentTimeValue, 1.0f)];
    }
    if ([self.playerView respondsToSelector:@selector(updateControlProcessing:)]) {
        [self.playerView updateControlProcessing:(step > 0 ? PlayerKitProcessingStateForward : PlayerKitProcessingStateBackward)];
    }
}

- (void)handleGestureChangeWithPlus:(BOOL)plus {
    switch (self.gestureState) {
        case PlayerKitGestureStateVolume: {
            [self volumePlus:(plus ? ZHXPlayerVolumeStep : -ZHXPlayerVolumeStep)];
            break;
        }
        case PlayerKitGestureStateBrightness: {
            [self brightnessPlus:(plus ? ZHXPlayerBrightnessStep : -ZHXPlayerBrightnessStep)];
            break;
        }
        case PlayerKitGestureStatePlaybackSpeed: {
            [self playbackSpeedPlus:(plus ? ZHXPlayerPlaybackSpeedStep : -ZHXPlayerPlaybackSpeedStep)];
            break;
        }
        case PlayerKitGestureStateProgress: {
            [self mediaProgressPlus:(plus ? ZHXPlayerMediaProgressStepStep : -ZHXPlayerMediaProgressStepStep)];
            break;
        }
        default:
            break;
    }
}

- (void)handelGestureDidEnd {
    if (self.gestureState == PlayerKitGestureStatePlaybackSpeed) {
        if (self.allowControlPlaybackSpeedForGesture) {
            [self playCurrentTime];
        }
    } else if (self.gestureState == PlayerKitGestureStateProgress) {
        self.gestureTimeValue = 0.0;
        if (self.allowControlMediaProgressForGesture) {
            [self seekCurrentTimaValue:self.currentTimeValue];
        }
        if ([self.playerView respondsToSelector:@selector(updateControlProcessing:)]) {
            [self.playerView updateControlProcessing:PlayerKitProcessingStateNone];
        }
    }
}

- (void)handleSingleTap:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    BOOL touchInTopBar = CGRectContainsPoint([self topToolsBarFrame], point);
    BOOL touchInBottomBar = CGRectContainsPoint([self bottomToolsBarFrame], point);
    // 是否点击到工具条的区域
    if (!touchInTopBar && !touchInBottomBar) {
        if ([self.playerView respondsToSelector:@selector(animatedControlElement)]) {
            [self.playerView animatedControlElement];
        }
        [self callBackDelegateWithAnimationElement];
    }
}

- (void)handleDoubelTap:(UITouch *)touch {
    [self playerControl];
}

#pragma mark - Touches Methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat locationX = location.x;
    CGFloat locationY = location.y;
    
    CGFloat offsetX = locationX - _currentLocation.x;
    CGFloat offsetY = locationY - _currentLocation.y;
    if (CGPointEqualToPoint(_currentLocation,CGPointZero)) {
        _currentLocation = location;
        return;
    }
    _currentLocation = location;
    
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    // 屏幕分成三等分，第一等分用于屏幕亮度，第二等分用于播放速度，第三等分用于音量
    CGFloat perWidth = CGRectGetWidth(mainBounds) / 3.0;
    
    BOOL horizontal = (ABS(offsetX) > ABS(offsetY));
    BOOL vertical = !horizontal;
    
    BOOL volumeConditions = (locationX > perWidth * 2) && vertical;
    BOOL brightnessConditions = (locationX < perWidth) && vertical;
    BOOL playbackSpeedConditions = (locationX >= perWidth && locationX <= perWidth * 2) && vertical;
    
    if (self.gestureState == PlayerKitGestureStateNone) {
        if (volumeConditions) {
            self.gestureState = PlayerKitGestureStateVolume;
        } else if (brightnessConditions) {
            self.gestureState = PlayerKitGestureStateBrightness;
        } else if (playbackSpeedConditions) {
            self.gestureState = PlayerKitGestureStatePlaybackSpeed;
        } else if (horizontal) {
            self.gestureState = PlayerKitGestureStateProgress;
        }
    }
    
    if ((self.gestureState == PlayerKitGestureStateVolume) && volumeConditions) {
        // 音量
        [self handleGestureChangeWithPlus:(offsetY <= 0)];
    } else if ((self.gestureState == PlayerKitGestureStateBrightness) && brightnessConditions) {
        // 亮度
        [self handleGestureChangeWithPlus:(offsetY <= 0)];
    } else if (self.gestureState == PlayerKitGestureStatePlaybackSpeed) {
        // 播放速度
        [self handleGestureChangeWithPlus:(offsetY <= 0)];
    } else if ((self.gestureState == PlayerKitGestureStateProgress) && horizontal) {
        // 进度
        [self handleGestureChangeWithPlus:(offsetX > 0)];
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _currentLocation = CGPointZero;
    self.gestureTimeValue = 0.0;
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        // 取消上一次的Perform
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    PlayerKitGestureState gestureState = self.gestureState;
    
    if (gestureState == PlayerKitGestureStateNone) {
        UITouch *touch = [touches anyObject];
        
        if (touch.tapCount == 1) {
            [self performSelector:@selector(handleSingleTap:) withObject:touch afterDelay:0.3];
        } else if (touch.tapCount == 2) {
            [self handleDoubelTap:touch];
        }
    } else if (gestureState == PlayerKitGestureStateProgress) {
        // 隐藏进度指示器，更新进度条
    } else if (gestureState == PlayerKitGestureStateBrightness) {
        // 隐藏亮度指示器
    } else if (gestureState == PlayerKitGestureStatePlaybackSpeed) {
        // 隐藏播放速度指示器
    } else {
        [super touchesEnded:touches withEvent:event];
    }
    [self handelGestureDidEnd];
    self.gestureState = PlayerKitGestureStateNone;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (!_player || !_playerItem) {
        return;
    }
    if (context == (__bridge void *)(ZXHPlayerObserverContext)) {
        // Player KVO
        if ([keyPath isEqualToString:ZXHPlayerContainerRateKey]) {
            float rate = [change[NSKeyValueChangeNewKey] floatValue];
            if (rate) {
                _playbackState = PlayerKitPlaybackStatePlaying;
            } else {
                _playbackState = PlayerKitPlaybackStatePaused;
            }
        }
    } else if (context == (__bridge void *)(ZXHPlayerItemObserverContext)) {
        // PlayerItem KVO
        if ([keyPath isEqualToString:ZXHPlayerContainerEmptyBufferKey]) {
            if (self.playerItem.playbackBufferEmpty) {
                [self callBackDelegateWithBufferingState:PlayerKitBufferingStateDelayed];
            }
        } else if ([keyPath isEqualToString:ZXHPlayerContainerPlayerKeepUpKey]) {
            if (self.playerItem.playbackLikelyToKeepUp) {
                [self callBackDelegateWithBufferingState:PlayerKitBufferingStateKeepUp];
            }
        } else if ([keyPath isEqualToString:ZXHPlayerContainerPlayerBufferFullKey]) {
            if (self.playerItem.playbackBufferFull) {
                [self callBackDelegateWithBufferingState:PlayerKitBufferingStateFull];
            }
        } else if ([keyPath isEqualToString:ZXHPlayerContainerStatusKey]) {
            AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusReadyToPlay: {
                    _flags.readPlayer = YES;
                    break;
                }
                case AVPlayerStatusFailed: {
                    _flags.readPlayer = NO;
                    [self callBackDelegateWithPlaybackState:PlayerKitPlaybackStateFailed];
                    break;
                }
                case AVPlayerStatusUnknown:
                default:
                    break;
            }
        }
    } else if (context == (__bridge void *)ZXHPlayerPreloadObserverContext) {
        if ([keyPath isEqualToString:ZXHPlayerContainerPlayerLoadedTimeRanges]) {
            if (_flags.readPlayer || _flags.localFiled) {
                NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
                [self validationLoadedTimeRanges:timeRanges];
            }
        }
    } else if (context == (__bridge void *)(ZXHPlayerLayerObserverContext)) {
        // PlayerLayer KVO
        if ([keyPath isEqualToString:ZXHPlayerContainerReadyForDisplay]) {
            if (self.playerView.playerLayer.readyForDisplay) {
                if (!_flags.firstDeadyForDisplay) {
                    _flags.firstDeadyForDisplay = YES;
                    [self.player seekToTime:kCMTimeZero];
                    [self.playerView.playerLayer setNeedsDisplay];
                }
                [self callBackDelegateWithReady];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
