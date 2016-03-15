//
//  YoukuViewController.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//
#import "YoukuViewController.h"
#import "YoukuDetailViewController.h"

@implementation YoukuViewController

- (BOOL)navigationBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self navigationBarHidden] != self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:[self navigationBarHidden] animated:animated];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Youku";
}

- (void)didSelectedRowAtItem:(VideoItem *)videoItem {
    YoukuDetailViewController *detailViewController = [[YoukuDetailViewController alloc] init];
    detailViewController.videoItem = videoItem;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
