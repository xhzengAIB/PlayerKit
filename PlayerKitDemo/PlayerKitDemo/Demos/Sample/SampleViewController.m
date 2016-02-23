//
//  SampleViewController.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import "SampleViewController.h"
#import <PlayerKit.h>
#import "CustomPlayerView.h"

static NSString * const RemoteVideoM3U8URLString = @"http://devstreaming.apple.com/videos/wwdc/2015/304ywrr62d/304/hls_vod_mvp.m3u8";

static NSString * const RemoteVideoURLString = @"http://childapp.pailixiu.com/Jack/sample_iPod.m4v";
static NSString * const RemoteAudioURLString = @"http://childapp.pailixiu.com/Jack/backgroundsound.mp3";

static NSString * const LocalVideoFilePath = @"nba.mp4";

@interface SampleViewController () <PlayerKitContainerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bufferingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *playbackStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bufferStateLabel;

@property (weak, nonatomic) IBOutlet UIButton *videoPlayControlButton;
@property (weak, nonatomic) IBOutlet UIButton *audioPlayControButton;
@property (weak, nonatomic) IBOutlet UIButton *localPlayControlButton;
@property (weak, nonatomic) IBOutlet UIButton *customPlayerButton;
@property (weak, nonatomic) IBOutlet UISwitch *m3u8Switch;

- (IBAction)playVideo:(UIButton *)sender;
- (IBAction)playAudio:(UIButton *)sender;
- (IBAction)playLocalVideo:(UIButton *)sender;
- (IBAction)showCustomPlayerView:(UIButton *)sender;

@end

@implementation SampleViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *statusBarBackgrounView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 20)];
    statusBarBackgrounView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarBackgrounView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)showRemoteVideoPlayer {
    [self showPlayerInWindowWithMediaPath:(self.m3u8Switch.on ? RemoteVideoM3U8URLString : RemoteVideoURLString) title:@"拍立秀 上海站"];
}

- (void)showRemoteAudioPlayer {
    [self showPlayerInWindowWithMediaPath:RemoteAudioURLString];
}

- (void)showLocalVideoPlayer {
    [self showPlayerInWindowWithMediaPath:[[NSBundle mainBundle] pathForResource:LocalVideoFilePath ofType:nil]];
}

- (void)showCustomPlayer {
    [self showCustomPlayerView:[CustomPlayerView new] inWindowWithMediaPath:(self.m3u8Switch.on ? RemoteVideoM3U8URLString : RemoteVideoURLString)];
}

- (IBAction)playVideo:(UIButton *)sender {
    if (sender.selected) {
        [sender setTitle:@"Show Remote Video" forState:UIControlStateNormal];
        [self dismissPlayer];
    } else {
        [sender setTitle:@"Dismiss Player" forState:UIControlStateNormal];
        [self showRemoteVideoPlayer];
    }
    sender.selected = !sender.selected;
    [self updateButtonEnable:sender];
}

- (IBAction)playAudio:(UIButton *)sender {
    if (sender.selected) {
        [sender setTitle:@"Show Remote Audio" forState:UIControlStateNormal];
        [self dismissPlayer];
    } else {
        [sender setTitle:@"Dismiss Player" forState:UIControlStateNormal];
        [self showRemoteAudioPlayer];
    }
    sender.selected = !sender.selected;
    [self updateButtonEnable:sender];
}

- (IBAction)playLocalVideo:(UIButton *)sender {
    if (sender.selected) {
        [sender setTitle:@"Show Local Video" forState:UIControlStateNormal];
        [self dismissPlayer];
    } else {
        [sender setTitle:@"Dismiss Player" forState:UIControlStateNormal];
        [self showLocalVideoPlayer];
    }
    sender.selected = !sender.selected;
    [self updateButtonEnable:sender];
}

- (IBAction)showCustomPlayerView:(UIButton *)sender {
    if (sender.selected) {
        [sender setTitle:@"Show Custom Player" forState:UIControlStateNormal];
        [self dismissPlayer];
    } else {
        [sender setTitle:@"Dismiss Player" forState:UIControlStateNormal];
        [self showCustomPlayer];
    }
    sender.selected = !sender.selected;
    [self updateButtonEnable:sender];
}

- (void)updateLabels {
    self.videoPlayControlButton.selected = NO;
    [self.videoPlayControlButton setTitle:@"Show Remote Video" forState:UIControlStateNormal];
    self.audioPlayControButton.selected = NO;
    [self.audioPlayControButton setTitle:@"Show Remote Audio" forState:UIControlStateNormal];
    self.localPlayControlButton.selected = NO;
    [self.localPlayControlButton setTitle:@"Show Local Video" forState:UIControlStateNormal];
    self.customPlayerButton.selected = NO;
    [self.customPlayerButton setTitle:@"Show Custom Player" forState:UIControlStateNormal];
    
    self.statusLabel.text = nil;
    self.playingTimeLabel.text = nil;
    self.playbackStateLabel.text = nil;
    self.bufferingTimeLabel.text = nil;
    self.bufferStateLabel.text = nil;
    self.totalTimeLabel.text = nil;
}

- (void)updateButtonEnable:(UIButton *)sender {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *currentButton = (UIButton *)view;
            if (currentButton != sender && sender.selected) {
                currentButton.userInteractionEnabled = NO;
            } else {
                currentButton.userInteractionEnabled = YES;
            }
        }
    }
}

#pragma mark - PlayerKitContainerDelegate

- (void)playerKitContainer:(PlayerKitContainer *)playerContainer didChangeBufferDuration:(CMTime)bufferDuration {
    NSString *bufferingTime = [NSString stringWithFormat:@"Buffering Time : %.0f", CMTimeGetSeconds(bufferDuration)];
    self.bufferingTimeLabel.text = bufferingTime;
}

- (void)playerKitContainer:(PlayerKitContainer *)playerContainer didChangeReadDuration:(CMTime)readDuration {
    NSString *playingTime = [NSString stringWithFormat:@"Playing Time : %.0f", CMTimeGetSeconds(readDuration)];
    self.playingTimeLabel.text = playingTime;
}

- (void)playerKitContainerReady:(PlayerKitContainer *)playerContainer {
    self.statusLabel.text = @"Player Ready";
}

- (void)playerKitContainerPlaybackWillStartBeginning:(PlayerKitContainer *)playerContainer {
    self.statusLabel.text = @"Playback Will Start Beginning";
}

- (void)playerKitContainerPlaybackDidEnd:(PlayerKitContainer *)playerContainer {
    self.statusLabel.text = @"Playback Did End";
}

- (void)playerKitContainerBufferringStateDidChange:(PlayerKitContainer *)playerContainer {
    NSString *stateString = nil;
    switch (playerContainer.bufferingState) {
        case PlayerKitBufferingStateKeepUp:
            stateString = @"KeepUp";
            break;
        case PlayerKitBufferingStateDelayed:
            stateString = @"Delayed";
            break;
        case PlayerKitBufferingStateFull:
            stateString = @"Buffer Full";
            break;
        case PlayerKitBufferingStateUpToGrade:
            stateString = @"up To grade";
            break;
        case PlayerKitBufferingStateBuffering:
        default:
            stateString = @"Buffering";
            break;
    }
    self.bufferStateLabel.text = [NSString stringWithFormat:@"Bufferring : %@", stateString];
}

- (void)playerKitContainerPlaybackStateDidChange:(PlayerKitContainer *)playerContainer {
    NSString *stateString = nil;
    switch (playerContainer.playbackState) {
        case PlayerKitPlaybackStatePlaying:
            stateString = @"Playing";
            break;
        case PlayerKitPlaybackStatePaused:
            stateString = @"Paused";
            break;
        case PlayerKitPlaybackStateStopped:
            stateString = @"Stopped";
            break;
        case PlayerKitPlaybackStateFailed:
        default:
            stateString = @"Failed";
            break;
    }
    self.playbackStateLabel.text = [NSString stringWithFormat:@"Playback : %@", stateString];
}

- (void)playerKitContainer:(PlayerKitContainer *)playerContainer didLoadMediaTotalDuration:(CMTime)totalDuration {
    self.totalTimeLabel.text = [NSString stringWithFormat:@"Media Total Time : %.0f", CMTimeGetSeconds(totalDuration)];
}

- (void)playerKitContainerDidDismiss:(PlayerKitContainer *)playerContainer {
    [self updateLabels];
}

- (void)playerKitContainer:(PlayerKitContainer *)playerContainer willAnimationWithType:(PlayerKitAnimationType)animationType {
    
}

@end
