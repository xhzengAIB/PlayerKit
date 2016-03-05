//
//  RootViewController.m
//  PlayerKitDemo
//
//  Created by Jack_iMac on 16/1/18.
//  Copyright © 2016年 All rights reserved.
//  嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，现任广州华秀软件技术有限公司的CEO，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 543413507@QQ.COM:543413507 主页:http://www.zengxianhua.com
//

#import "RootViewController.h"

typedef NS_ENUM(NSInteger, PlayerKitInitMetohdType) {
    PlayerKitInitMetohdTypeInitCode = 0,
    PlayerKitInitMetohdTypeStoryboard,
};

@interface ClassModeItem : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *functionName;

// May be nil
@property (nonatomic, copy) NSString *storyboardID;

@property (nonatomic, assign) PlayerKitInitMetohdType initMetohdType;

+ (NSMutableArray *)loadPlayerKitItems;

@end

@implementation ClassModeItem

+ (NSMutableArray *)loadPlayerKitItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    ClassModeItem *item = nil;
    item = [[ClassModeItem alloc] init];
    item.className = @"YoutobeViewController";
    item.functionName = @"Youtobe Demo";
    item.initMetohdType = PlayerKitInitMetohdTypeInitCode;
    [items addObject:item];
    
    item = [[ClassModeItem alloc] init];
    item.className = @"YoukuViewController";
    item.functionName = @"Youku Demo";
    item.initMetohdType = PlayerKitInitMetohdTypeInitCode;
    [items addObject:item];
    
    item = [[ClassModeItem alloc] init];
    item.className = @"KuaibaoViewController";
    item.functionName = @"天天快报 Demo";
    item.initMetohdType = PlayerKitInitMetohdTypeInitCode;
    [items addObject:item];
    
    item = [[ClassModeItem alloc] init];
    item.className = @"SohuViewController";
    item.functionName = @"搜狐 Demo";
    item.initMetohdType = PlayerKitInitMetohdTypeInitCode;
    [items addObject:item];
    
    item = [[ClassModeItem alloc] init];
    item.storyboardID = @"PlayerKit";
    item.functionName = @"PlayerKit Demo";
    item.initMetohdType = PlayerKitInitMetohdTypeStoryboard;
    [items addObject:item];
    
    return items;
}

@end

static NSString * const RootTableViewCellIdentifier = @"RootTableViewCellIdentifier";

@interface RootTableViewCell : UITableViewCell

@property (nonatomic, strong) ClassModeItem *item;

@end

@implementation RootTableViewCell

- (void)setItem:(ClassModeItem *)item {
    if (_item == item) {
        return;
    }
    _item = item;
    self.textLabel.text = item.functionName;
}

@end


@interface RootViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [ClassModeItem loadPlayerKitItems];
    }
    return _items;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RootTableViewCellIdentifier forIndexPath:indexPath];
    cell.item = self.items[indexPath.item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self preferClassModeItem:self.items[indexPath.item]];
}

- (void)preferClassModeItem:(ClassModeItem *)item {
    UIViewController *viewController = nil;
    switch (item.initMetohdType) {
        case PlayerKitInitMetohdTypeInitCode: {
            Class currentClass = NSClassFromString(item.className);
            viewController = [[currentClass alloc] init];
            break;
        }
        case PlayerKitInitMetohdTypeStoryboard: {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:item.storyboardID];
            break;
        }
        default:
            break;
    }
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
