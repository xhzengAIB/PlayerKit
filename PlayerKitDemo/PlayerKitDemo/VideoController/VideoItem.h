//
//  VideoItem.h
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface VideoItem : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *descriptionDe;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, copy) NSString *m3u8URL;
@property (nonatomic, copy) NSString *m3u8HdURL;
@property (nonatomic, copy) NSString *mp4URL;
@property (nonatomic, copy) NSString *mp4HDURL;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger playersize;
@property (nonatomic, copy) NSString *ptime;
@property (nonatomic, copy) NSString *replyBoard;
@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, copy) NSString *replyid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *videosource;

@end
