//
//  YoukuDetailViewController.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 543413507@QQ.COM:543413507 主页:http://www.zengxianhua.com
//

#import "YoukuDetailViewController.h"
#import <PlayerKitContainer.h>

#import "VideoItem.h"

@interface YoukuDetailViewController () <UITableViewDataSource, PlayerKitContainerDelegate>

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) PlayerKitContainer *playerontainer;
@property (nonatomic, strong) UITableView *commentTableView;

@end

@implementation YoukuDetailViewController

- (BOOL)navigationBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self navigationBarHidden] != self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:[self navigationBarHidden] animated:animated];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    [self setup];
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playerontainer];
    [self.view addSubview:self.commentTableView];
    [self.view sendSubviewToBack:self.commentTableView];
    [self.view addSubview:self.backButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Propertys

- (PlayerKitContainer *)playerontainer {
    if (!_playerontainer) {
        _playerontainer = [[PlayerKitContainer alloc] init];
        _playerontainer.delegate = self;
        _playerontainer.playbackLoops = YES;
        _playerontainer.mediaPath = @"http://childapp.pailixiu.com/Jack/sample_iPod.m4v";
        [_playerontainer buildInterface];
    }
    return _playerontainer;
}

- (UITableView *)commentTableView {
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.playerontainer.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.playerontainer.bounds) - 20) style:UITableViewStylePlain];
        [_commentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _commentTableView.dataSource = self;
    }
    return _commentTableView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _backButton.frame = CGRectMake(0, 20, 50, 44);
    }
    return _backButton;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Comment : %ld", (long)indexPath.item];
    
    return cell;
}

#pragma mark - 

- (void)playerKitContainer:(PlayerKitContainer *)playerContainer willAnimationWithType:(PlayerKitAnimationType)animationType {
    self.backButton.hidden = (animationType != PlayerKitAnimationTypeNone);
}

@end
