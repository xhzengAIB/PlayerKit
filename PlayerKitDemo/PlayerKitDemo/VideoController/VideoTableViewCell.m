//
//  VideoTableViewCell.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 543413507@QQ.COM:543413507 主页:http://www.zengxianhua.com
//

#import "VideoTableViewCell.h"
#import "VideoItem.h"

#import <PINImageView+PINRemoteImage.h>

@interface VideoTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation VideoTableViewCell

- (void)setVideo:(VideoItem *)video {
    if (_video == video) {
        return;
    }
    _video = video;
    self.titleLabel.text = video.title;
    [self.thumbnailImageView pin_setImageFromURL:[NSURL URLWithString:video.cover] placeholderImage:nil completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        
    }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
}

@end
