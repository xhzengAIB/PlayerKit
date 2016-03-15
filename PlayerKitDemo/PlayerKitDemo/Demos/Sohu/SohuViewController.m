//
//  SohuViewController.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//
#import "SohuViewController.h"
#import "SohuTableViewCell.h"
#import <PlayerKitContainer.h>

@interface SohuViewController () <PlayerKitContainerDelegate>

@property (nonatomic, weak) UIView *playerContainerSuperView;

@end

@implementation SohuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜狐";
    [self.tableView registerNib:[UINib nibWithNibName:@"SohuTableViewCell" bundle:nil] forCellReuseIdentifier:SohuTableViewCellIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SohuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SohuTableViewCellIdentifier forIndexPath:indexPath];
    cell.playerContainer.delegate = self;
    
    return cell;
}

- (void)didSelectedRowAtItem:(VideoItem *)videoItem {
    
}

#pragma mark - 

- (void)playerKitContainer:(PlayerKitContainer *)playerContainer willAnimationWithType:(PlayerKitAnimationType)animationType {
    if (animationType == PlayerKitAnimationTypeNone) {
        // Cell Add playerContainer
        [self.playerContainerSuperView addSubview:playerContainer];
    } else {
        self.playerContainerSuperView = playerContainer.superview;
        [[[UIApplication sharedApplication] keyWindow] addSubview:playerContainer];
    }
}

@end
