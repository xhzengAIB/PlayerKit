//
//  VideoController.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 543413507@QQ.COM:543413507 主页:http://www.zengxianhua.com
//

#import "VideoController.h"
#import "VideoTableViewCell.h"
#import "VideoItem.h"

#import <AFNetworking/AFNetworking.h>
#import <Mantle/Mantle.h>

static NSString * const VideoDataSourceURLPath = @"http://c.m.163.com/nc/video/home/%ld-%ld.html";


@interface VideoController () <UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *videos;

@property (nonatomic, strong) UITableViewCell *loadingTableViewCell;
@property (nonatomic, strong) UIView *acticatorView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) NSInteger dataSourceStart;

@end

@implementation VideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.tableView];
    
    [self loadDataSource];
}

- (UITableViewCell *)loadingTableViewCell {
    if (!_loadingTableViewCell) {
        _loadingTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [_loadingTableViewCell.contentView addSubview:self.acticatorView];
    }
    return _loadingTableViewCell;
}

- (UIView *)acticatorView {
    if (!_acticatorView) {
        _acticatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 60)];
        [_acticatorView addSubview:self.indicatorView];
    }
    return _acticatorView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(CGRectGetMidX(_acticatorView.bounds), CGRectGetMidY(_acticatorView.bounds));
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}

- (void)loadDataSource {
    [[AFHTTPSessionManager manager] GET:[NSString stringWithFormat:VideoDataSourceURLPath, (long)self.dataSourceStart, self.dataSourceStart + 10] parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *videoList = responseObject[@"videoList"];
        
        NSArray *videoSidList = responseObject[@"videoSidList"];
        
        NSError *error = nil;
        NSArray *videoItems = [MTLJSONAdapter modelsOfClass:[VideoItem class] fromJSONArray:videoList error:&error];
        
        [self.videos addObjectsFromArray:videoItems];
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (NSMutableArray *)videos {
    if (!_videos) {
        _videos = [[NSMutableArray alloc] init];
    }
    return _videos;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 44.0;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:VideoTableViewCellIdentifier];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videos.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (self.videos.count > 0 && indexPath.row < self.videos.count) {
        VideoTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:VideoTableViewCellIdentifier forIndexPath:indexPath];
        videoCell.video = self.videos[indexPath.item];
        
        cell = videoCell;
    } else {
        cell = self.loadingTableViewCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.videos.count > 0 && indexPath.row < self.videos.count) {
        return 268;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoItem *videoItem = self.videos[indexPath.item];
    [self didSelectedRowAtItem:videoItem];
}

- (void)didSelectedRowAtItem:(VideoItem *)videoItem {
    
}

@end
