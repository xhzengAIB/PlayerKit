//
//  PlayerKitPlayerLayerView.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import "PlayerKitVideoLayerView.h"

@implementation PlayerKitVideoLayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)commit {
    self.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    self.videoFillMode = AVLayerVideoGravityResizeAspect;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commit];
    }
    return self;
}

- (void)awakeFromNib {
    [self commit];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setVideoFillMode:(NSString *)videoFillMode {
    [self playerLayer].videoGravity = videoFillMode;
}

- (NSString *)videoFillMode {
    return [self playerLayer].videoGravity;
}

@end
