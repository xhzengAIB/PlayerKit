//
//  SohuTableViewCell.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 543413507@QQ.COM:543413507 主页:http://www.zengxianhua.com
//

#import "SohuTableViewCell.h"
#import <PlayerKitContainer.h>

@interface SohuTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SohuTableViewCell

- (void)prepareForReuse {
    [self.playerContainer prepareForReuse];
}

- (void)awakeFromNib {
    // Initialization code
    [self.playerContainer buildInterface];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playVideo:(UIButton *)sender {
    self.playerContainer.mediaPath = @"http://childapp.pailixiu.com/Jack/sample_iPod.m4v";
    [self.playerContainer loadMediaData];
}

@end
