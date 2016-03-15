//
//  UIViewController+PlayerKitAdditions.m
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "UIViewController+PlayerKitAdditions.h"
#import "PlayerKitContainer.h"
#import "PlayerKitViewController.h"
#import <objc/runtime.h>

static NSString * const ZXHPlayerKitContainerKey = @"ZXHPlayerKitContainerKey";
static NSString * const ZXHPlayerKitViewControllerKey = @"ZXHPlayerKitViewControllerKey";

@implementation UIViewController (PlayerKitAdditions)

- (void)showPlayerInWindowWithMediaPath:(NSString *)mediaPath {
    [self showCustomPlayerView:nil inWindowWithMediaPath:mediaPath];
}

- (void)showPlayerInWindowWithMediaPath:(NSString *)mediaPath title:(NSString *)title {
    [self showCustomPlayerView:nil inWindowWithMediaPath:mediaPath title:title];
}

- (void)showCustomPlayerView:(UIView <PlayerKitPlayerViewProtocol> *)playerView inWindowWithMediaPath:(NSString *)mediaPath {
    [self showCustomPlayerView:playerView inWindowWithMediaPath:mediaPath title:nil];
}

- (void)showCustomPlayerView:(UIView <PlayerKitPlayerViewProtocol> *)playerView inWindowWithMediaPath:(NSString *)mediaPath title:(NSString *)title {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    
    PlayerKitContainer *playerContainer = [self playerContainer];
    if (!playerContainer) {
        playerContainer = [self setupPlayerContainer];
    }
    playerContainer.delegate = (id <PlayerKitContainerDelegate>)self;
    playerContainer.playbackLoops = YES;
    playerContainer.mediaPath = mediaPath;
    [playerContainer buildInterface];
    if (playerView) {
        playerContainer.playerView = playerView;
    }
    if ([playerContainer.playerView respondsToSelector:@selector(title)]) {
        playerContainer.playerView.title = title;
    }
    
    UIView *containerView = playerContainer;
    [keyWindow addSubview:containerView];
    containerView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        containerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showPlayerInViewController:(UIViewController *)viewController mediaPath:(NSString *)mediaPath {
    [self showPlayerInViewController:viewController mediaPath:mediaPath title:nil];
}
- (void)showPlayerInViewController:(UIViewController *)viewController mediaPath:(NSString *)mediaPath title:(NSString *)title {
    PlayerKitViewController *playerViewController = [self playerViewController];
    if (!playerViewController) {
        playerViewController = [self setupPlayerViewController];
    }
    playerViewController.container.delegate = (id <PlayerKitContainerDelegate>)self;
    playerViewController.container.playbackLoops = YES;
    playerViewController.container.mediaPath = mediaPath;
    if ([playerViewController.container.playerView respondsToSelector:@selector(title)]) {
        playerViewController.container.playerView.title = title;
    }
    
    [viewController didMoveToParentViewController:playerViewController];
    UIView *playerView = playerViewController.view;
    [viewController.view addSubview:playerView];
    playerView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        playerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissPlayer {
    PlayerKitViewController *playerViewController = [self playerViewController];
    BOOL viewControllerPresented = (playerViewController != nil);
    
    UIView *playerView = [self playerContainer];
    if (viewControllerPresented) {
        playerView = playerViewController.view;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        playerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (viewControllerPresented) {
            [playerViewController didMoveToParentViewController:nil];
            [self setPlayerViewController:nil];
        } else {
            [self setPlayerContainer:nil];
        }
        [playerView removeFromSuperview];
    }];
}

#pragma mark - Propertys

- (PlayerKitContainer *)initilzerPlayerContainer {
    PlayerKitContainer *playerContainer = [[PlayerKitContainer alloc] init];
    return playerContainer;
}

- (PlayerKitContainer *)setupPlayerContainer {
    PlayerKitContainer *playerContainer = [self initilzerPlayerContainer];
    [self setPlayerContainer:playerContainer];
    return playerContainer;
}

- (PlayerKitViewController *)initilzerPlayerViewController {
    PlayerKitViewController *viewController = [[PlayerKitViewController alloc] init];
    return viewController;
}

- (PlayerKitViewController *)setupPlayerViewController {
    PlayerKitViewController *playerViewController = [self initilzerPlayerViewController];
    [self setPlayerViewController:playerViewController];
    return playerViewController;
}

- (PlayerKitContainer *)playerContainer {
    PlayerKitContainer *playerContainer = objc_getAssociatedObject(self, &ZXHPlayerKitContainerKey);
    return playerContainer;
}

- (void)setPlayerContainer:(PlayerKitContainer *)playerContainer {
    objc_setAssociatedObject(self, &ZXHPlayerKitContainerKey, playerContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PlayerKitViewController *)playerViewController {
    PlayerKitViewController *playerViewController = objc_getAssociatedObject(self, &ZXHPlayerKitViewControllerKey);
    return playerViewController;
}

- (void)setPlayerViewController:(PlayerKitViewController *)playerViewController {
    objc_setAssociatedObject(self, &ZXHPlayerKitViewControllerKey, playerViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
