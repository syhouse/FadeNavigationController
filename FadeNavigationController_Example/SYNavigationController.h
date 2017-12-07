//
//  SYNavigationController.h
//  FadeNavigationController_Example
//
//  Created by macmini on 2017/12/5.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SYNavigationControllerNavigationBarVisibility){
    SYNavigationControllerNavigationBarVisibilityHidden = 0, // Use custom navigation bar and hide it
    SYNavigationControllerNavigationBarVisibilityVisible = 1 // Use custom navigation bar and show it
};

@interface SYNavigationController : UINavigationController
- (void)setSYNavigationControllerNavigationBarVisibility:(SYNavigationControllerNavigationBarVisibility)navigationBarVisibility;
@end
