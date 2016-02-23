//
//  PlayerKitPlayerViewProtocol.h
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 *  Video view animation type
 */
typedef NS_ENUM(NSInteger, PlayerKitAnimationType) {
    /**
     *  None
     */
    PlayerKitAnimationTypeNone = 0,
    /**
     *  90 degrees counterclockwise
     */
    PlayerKitAnimationTypeAnticlockwise,
    /**
     *  90 degrees clockwise
     */
    PlayerKitAnimationTypeClockwise,
    /**
     *  Zoom
     */
    PlayerKitAnimationTypeZoom,
};

/**
 *  Playback State
 */
typedef NS_ENUM(NSInteger, PlayerKitPlaybackState) {
    /**
     *  Player Stop
     */
    PlayerKitPlaybackStateStopped = 0,
    /**
     *  Player Playing
     */
    PlayerKitPlaybackStatePlaying,
    /**
     *  Player Pause
     */
    PlayerKitPlaybackStatePaused,
    /**
     *  Player Failed
     */
    PlayerKitPlaybackStateFailed,
};

/**
 *  Buffering State
 */
typedef NS_ENUM(NSInteger, PlayerKitBufferingState) {
    /**
     *  Buffering
     */
    PlayerKitBufferingStateBuffering = 0,
    /**
     *  Buffering keepUp
     */
    PlayerKitBufferingStateKeepUp,
    /**
     *  Delayed buffering
     */
    PlayerKitBufferingStateDelayed,
    /**
     *  Buffer Full
     */
    PlayerKitBufferingStateFull,
    /**
     *  Up to grade
     */
    PlayerKitBufferingStateUpToGrade,
};

/**
 *  Gesture State
 */
typedef NS_ENUM(NSInteger, PlayerKitGestureState) {
    /**
     *  None
     */
    PlayerKitGestureStateNone = 0,
    /**
     *  Volume
     */
    PlayerKitGestureStateVolume,
    /**
     *  Brightness
     */
    PlayerKitGestureStateBrightness,
    /**
     *  Playback Speed
     */
    PlayerKitGestureStatePlaybackSpeed,
    /**
     *  Media Progress
     */
    PlayerKitGestureStateProgress,
};

/**
 *  Gesture Direction
 */
typedef NS_ENUM(NSInteger, PlayerKitGestureDirection) {
    /**
     *  None
     */
    PlayerKitGestureDirectionNone = 0,
    /**
     *  Horizontal
     */
    PlayerKitGestureDirectionHorizontal,
    /**
     *  Vertical
     */
    PlayerKitGestureDirectionVertical,
};

/**
 *  Processing State
 */
typedef NS_ENUM(NSInteger, PlayerKitProcessingState) {
    /**
     *  None
     */
    PlayerKitProcessingStateNone = 0,
    /**
     *  Backward
     */
    PlayerKitProcessingStateBackward,
    /**
     *  Forward
     */
    PlayerKitProcessingStateForward,
};

typedef void(^PlayerKitAnimationBlock)(void);
typedef void(^PlayerKitDidTapButtonBlock)(UIButton *sender);
typedef void(^PlayerKitDidChangeTimeBlock)(float currentTimeValue);
typedef void(^PlayerKitReloadBlock)(void);
typedef void(^PlayerKitGestureChangeBlock)(PlayerKitGestureState gestureState, BOOL plus);
typedef void(^PlayerKitGestureDidEndBlock)(PlayerKitGestureState gestureState);

@class PlayerKitContainer;

// 这里分两种方法：
// 第一种是外部更新UI
// 第二种是内部用户行为通知外部
@protocol PlayerKitPlayerViewProtocol <NSObject>

@required
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@property (nonatomic, copy) NSString *videoFillMode;

@optional
@property (nonatomic, weak) PlayerKitContainer *playerContainer;
@property (nonatomic, assign) CGRect topToolsBarFrame;
@property (nonatomic, assign) CGRect bottomToolsBarFrame;
@property (nonatomic, copy) NSString *title;
/**
 *  Video view animation handle
 *
 *  @param completion Back AnimationType Block
 */
- (void)animationCompletion:(PlayerKitAnimationBlock)completion;

/**
 *  Play begin handle
 *
 *  @param completion Tap Button Block
 */
- (void)playCompletion:(PlayerKitDidTapButtonBlock)completion;
/**
 *  Pause playback handle
 *
 *  @param completion Tap Button Block
 */
- (void)pauseCompletion:(PlayerKitDidTapButtonBlock)completion;
/**
 *  Silder change value handle
 *
 *  @param completion Tap Button Block
 */
- (void)sliderCurrentTimeValueCompletion:(PlayerKitDidChangeTimeBlock)completion;
/**
 *  When show failed at the time, reload handle
 *
 *  @param comepltion Slider Chaneg Value Block
 */
- (void)handleDownloadFailedReloadCompletion:(PlayerKitReloadBlock)comepltion;

#pragma mark - ++++++++++++++++至于为什么不使用KVO呢？方便自定义的人，希望你们喜欢这么简洁的做法++++++++++++++
/**
 *  Show Indicator
 */
- (void)showIndicator;
/**
 *  Hide Indicator
 */
- (void)hideIndicator;
/**
 *  Show Failed
 */
- (void)showDownloadFailed;

- (void)animatedControlElement;

/**
 *  Update media total duration
 *
 *  @param totalTime Media Total Duration
 */
- (void)updateTotalTime:(CMTime)totalTime;
/**
 *  Update media buffering duration
 *
 *  @param bufferringTime Buffering Duration
 */
- (void)updateBufferringTime:(CMTime)bufferringTime;
/**
 *  Update Playing duration
 *
 *  @param playingTime Playing Duration
 */
- (void)updatePlayingTime:(CMTime)playingTime;
- (void)updateControlProcessing:(PlayerKitProcessingState)processingState;

/**
 *  When video view animation called
 */
- (void)animationAction:(PlayerKitAnimationType)animationType;

- (void)destroyManuallyElement;
#pragma mark - +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

@end
