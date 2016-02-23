//
//  PlayerKitTimeTools.h
//  PlayerKit
//
//  Created by Jack MacBook on 15/12/31.
//  Copyright © 2015年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://www.zengxianhua.com
//

#import "PlayerKitTimeTools.h"

@implementation PlayerKitTimeTools

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
    return formatter;
}

+ (NSString *)convertSecond:(Float64)second {
    NSDate *convertDate = [NSDate dateWithTimeIntervalSince1970:second];
    NSString *showTimeNew = [[self defaultDateFormatter] stringFromDate:convertDate];
    return showTimeNew;
}

+ (NSString *)converTime:(CMTime)time {
    return [self convertSecond:CMTimeGetSeconds(time)];
}

+ (NSMutableAttributedString *)processingTimeAttributedString:(NSString *)processingTimeString
                                            playingTimeString:(NSString *)playingTimeString
                                              totalTimeString:(NSString *)totalTimeString {
    NSMutableAttributedString *attribuedString = [[NSMutableAttributedString alloc] initWithString:processingTimeString];
    
    [attribuedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[processingTimeString rangeOfString:playingTimeString]];
    [attribuedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.820 alpha:0.500] range:[processingTimeString rangeOfString:totalTimeString]];
    return attribuedString;
}

@end
