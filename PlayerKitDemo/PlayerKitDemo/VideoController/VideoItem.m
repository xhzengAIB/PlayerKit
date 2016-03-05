//
//  VideoItem.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 543413507@QQ.COM:543413507 主页:http://www.zengxianhua.com
//

#import "VideoItem.h"

@implementation VideoItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cover" : @"cover",
             @"descriptionDe" : @"descriptionDe",
             @"length" : @"length",
             @"m3u8URL" : @"m3u8_url",
             @"m3u8HdURL" : @"m3u8_hd_url",
             @"mp4URL" : @"mp4_url",
             @"mp4HDURL" : @"mp4_hd_url",
             @"playCount" : @"playCount",
             @"playersize" : @"playersize",
             @"ptime" : @"ptime",
             @"replyBoard" : @"replyBoard",
             @"replyCount" : @"replyCount",
             @"replyid" : @"replyid",
             @"title" : @"title",
             @"vid" : @"vid",
             @"videosource" : @"videosource",
             };
}

@end
