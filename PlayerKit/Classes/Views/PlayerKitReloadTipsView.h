//
//  PlayerKitReloadTipsView.h
//  Pods
//
//  Created by Jack_iMac on 16/1/18.
//
//

#import <UIKit/UIKit.h>

@interface PlayerKitReloadTipsView : UIView

@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, strong) UILabel *tipsLabel;

- (void)show;
- (void)dismiss;

@end
