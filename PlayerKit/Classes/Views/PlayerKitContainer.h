//
//  PlayerKitContainer.h
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerKitPlayerViewProtocol.h"

@class PlayerKitContainer;

@protocol PlayerKitContainerDelegate <NSObject>

@optional
- (void)playerKitContainerDidDismiss:(PlayerKitContainer *)playerContainer;
#pragma mark - Playback State
/**
 *  To start playing
 *
 *  @param playerContainer The media player
 */
- (void)playerKitContainerPlaybackWillStartBeginning:(PlayerKitContainer *)playerContainer;
/**
 *  Stop playing
 *
 *  @param playerContainer The media player
 */
- (void)playerKitContainerPlaybackDidEnd:(PlayerKitContainer *)playerContainer;
/**
 *  Play the state changes
 *
 *  @param playerContainer The media player
 */
- (void)playerKitContainerPlaybackStateDidChange:(PlayerKitContainer *)playerContainer;
/**
 *  The buffer state changes
 *
 *  @param playerContainer The media player
 */
- (void)playerKitContainerBufferringStateDidChange:(PlayerKitContainer *)playerContainer;

#pragma mark - PlayerLayer
/**
 *  PlayerLayer ready
 *
 *  @param playerContainer The media player
 */
- (void)playerKitContainerReady:(PlayerKitContainer *)playerContainer;

#pragma mark - Duration
/**
 *  Playback time change
 *
 *  @param playerContainer The media player
 *  @param readDuration    Playing time
 */
- (void)playerKitContainer:(PlayerKitContainer *)playerContainer didChangeReadDuration:(CMTime)readDuration;
/**
 *  Buffering time change
 *
 *  @param playerContainer The media player
 *  @param bufferDuration  Buffering time
 */
- (void)playerKitContainer:(PlayerKitContainer *)playerContainer didChangeBufferDuration:(CMTime)bufferDuration;
/**
 *  Did down load media header info
 *
 *  @param playerContainer The media player
 *  @param totalDuration   Media total duration
 */
- (void)playerKitContainer:(PlayerKitContainer *)playerContainer didLoadMediaTotalDuration:(CMTime)totalDuration;

#pragma mark - Animation
- (void)playerKitContainer:(PlayerKitContainer *)playerContainer willAnimationWithType:(PlayerKitAnimationType)animationType;
- (void)playerKitContainerDidAnimationElement:(PlayerKitContainer *)playerContainer;

@end

/**
 *  The media player
 */
@interface PlayerKitContainer : UIView

#pragma mark - Base Info
/**
 *  Media total time
 */
@property (nonatomic, assign, readonly) CMTime totalDuration;
/**
 *  Media playing time
 */
@property (nonatomic, assign, readonly) CMTime readDuration;
/**
 *  Media buffering time
 */
@property (nonatomic, assign, readonly) CMTime bufferDuration;
/**
 *  Media playback state
 */
@property (nonatomic, assign, readonly) PlayerKitPlaybackState playbackState;
/**
 *  Media buffering state
 */
@property (nonatomic, assign, readonly) PlayerKitBufferingState bufferingState;
/**
 *  Media view animation type
 */
@property (nonatomic, assign, readonly) PlayerKitAnimationType animationType;

#pragma mark - Multiple Stup Media Asset Property
/**
 *  Media path, eg:filePath urlPath
 */
@property (nonatomic, copy) NSString *mediaPath;
/**
 *  Media Asset, eg:local media
 */
@property (nonatomic, copy) AVAsset *mediaAsset;

#pragma mark - Some Setup
/**
 *  Delegate
 */
@property (nonatomic, weak) id <PlayerKitContainerDelegate> delegate;
/**
 *  Comply with the <PlayerKitPlayerViewProtocol> View
 */
@property (nonatomic, strong) UIView <PlayerKitPlayerViewProtocol> *playerView;
/**
 * Loops Playback at end, default is NO
 */
@property (nonatomic, assign) BOOL playbackLoops;
/**
 *  After the play roll back to the beginning，default is NO
 */
@property (nonatomic, assign) BOOL playbackRollbackAtEnd;
/**
 *  Automatically after the minimum target buffer time，default is YES
 */
@property (nonatomic, assign) BOOL autoPlaybackToMinPreloadBufferTime;
/**
 *  Allow control volume for gesture, default is YES
 */
@property (nonatomic, assign) BOOL allowControlVolumeForGesture;
/**
 *  Allow control brightness for gesture, default is YES
 */
@property (nonatomic, assign) BOOL allowControlBrightnessForGesture;
/**
 *  Allow control playback speed for gesture, default is NO
 */
@property (nonatomic, assign) BOOL allowControlPlaybackSpeedForGesture;
/**
 *  Allow control media progress for gesture, default is YES
 */
@property (nonatomic, assign) BOOL allowControlMediaProgressForGesture;
/**
 *  Allow Portrait media player leave a black border at status bar, default is YES
 */
@property (nonatomic, assign) BOOL leaveblackBorderAtStatusBar; // default is YES

/**
 *  Minimum buffer time for play，default is 10.0f，When the buffer time is greater than the total media time, automatically set to half of the total time
 */
@property (nonatomic, assign) CGFloat minPreloadBufferTimeToPlay;
/**
 *  Video fill mode，default is nil, Because the video fill mode depending PlayerView，If you set this，PlayerView video fill mode become invalid.
 */
@property (nonatomic, copy) NSString *videoFillMode;
/**
 *  Video present frame, if not use initWithFrame: Methods default is CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]) / 3.0);
 */
@property (nonatomic, assign) CGRect presentFrame;
/**
 *  Media Volume, default is 1.0
 */
@property (nonatomic, assign) CGFloat volume;

- (void)buildInterface;
- (void)prepareForReuse;

- (void)loadMediaData;

@end
