//
//  SYNavigationController.m
//  FadeNavigationController_Example
//
//  Created by macmini on 2017/12/5.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "SYNavigationController.h"

#define kViewControllerKey @"viewController"
#define kVisibilityStatesKey @"visibilityStates"

@interface VisibilityStatesModel :NSObject
@property(nonatomic,strong)NSMutableArray *visibilityStates;
// 保存控制器和它的导航栏状态
- (void)saveVisibilityState:(SYNavigationControllerNavigationBarVisibility)navigationBarVisibility withController:(UIViewController *)controller ;

// 获取制定控制器的导航栏状态
- (SYNavigationControllerNavigationBarVisibility)getVisibilityState:(UIViewController *)controller;

//移除被释放的控制器（只保留当前导航栏控制器的数据）
- (void)arrangeModelWithControllers:(NSArray *)viewControllers;
@end

@implementation VisibilityStatesModel
- (NSMutableArray *)visibilityStates{
    if(!_visibilityStates){
        _visibilityStates = [NSMutableArray array];
    }
    return _visibilityStates;
}

- (void)saveVisibilityState:(SYNavigationControllerNavigationBarVisibility)navigationBarVisibility withController:(UIViewController *)controller{
    BOOL exit = NO;
    NSDictionary *exitDict = nil;
    for(NSDictionary *d in self.visibilityStates){
        if([d[kViewControllerKey] isEqual: controller]){
            exit = YES;
            exitDict = d;
            break;
        }
    }
    
    
    if(exit){
        NSInteger index = [self.visibilityStates indexOfObject:exitDict];
        self.visibilityStates[index][kVisibilityStatesKey] = @(navigationBarVisibility);
    }
    else{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[kViewControllerKey] = controller;
        dictionary[kVisibilityStatesKey] = @(navigationBarVisibility);
        [self.visibilityStates addObject:dictionary];
    }
}

- (SYNavigationControllerNavigationBarVisibility)getVisibilityState:(UIViewController *)controller{
    for(NSDictionary *d in self.visibilityStates){
        if([d[kViewControllerKey] isEqual: controller]){
            return [d[kVisibilityStatesKey] integerValue];;
        }
    }
    return SYNavigationControllerNavigationBarVisibilityHidden;
}

- (void)arrangeModelWithControllers:(NSArray *)viewControllers{
    NSMutableArray *newVisibilityStates = [NSMutableArray array];
    for(NSDictionary *d in self.visibilityStates){
        if([viewControllers containsObject:d[kViewControllerKey]]){
            [newVisibilityStates addObject:d];
        }
    }
    self.visibilityStates = newVisibilityStates;
}

@end

@interface SYNavigationController ()<UINavigationControllerDelegate>
@property(nonatomic,assign)SYNavigationControllerNavigationBarVisibility navigationBarVisibility;
@property (nonatomic, strong) UIColor *originalTintColor;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property(nonatomic,readonly)VisibilityStatesModel *visibilityStatesModel;

@property(nonatomic,strong)NSMutableDictionary *navigationBarVisibilityStates;
@end

@implementation SYNavigationController

@synthesize visibilityStatesModel = _visibilityStatesModel;

- (UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        // Create a the fake navigation bar background
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        
        CGFloat navigationBarHeight = CGRectGetHeight(self.navigationBar.frame);
        CGFloat statusBarHeight = [self statusBarHeight];
        
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = CGRectMake(0, -statusBarHeight, self.view.frame.size.width, navigationBarHeight+statusBarHeight);
        _visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _visualEffectView.userInteractionEnabled = NO;
        
        // Shadow line
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarHeight+statusBarHeight-0.5, self.view.frame.size.width, 0.5f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [_visualEffectView.contentView addSubview:shadowView];
    }
    
    return _visualEffectView;
}

- (VisibilityStatesModel *)visibilityStatesModel{
    if(!_visibilityStatesModel){
        _visibilityStatesModel = [[VisibilityStatesModel alloc] init];
    }
    return _visibilityStatesModel;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _navigationBarVisibilityStates = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.originalTintColor = self.navigationBar.tintColor;
    
    self.delegate = self;
    
    [self setupCustomNavigationBar];
}

- (void)setupCustomNavigationBar {
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.shadowImage = [UIImage new];
    
    [self.navigationBar addSubview:self.visualEffectView];
    [self.navigationBar sendSubviewToBack:self.visualEffectView];
}

- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    //Check for the MIN dimention is the easiest way to get the correct height for the current orientation
    return MIN(statusBarSize.width, statusBarSize.height);
}


- (void)setSYNavigationControllerNavigationBarVisibility:(SYNavigationControllerNavigationBarVisibility)navigationBarVisibility{
    _navigationBarVisibility = navigationBarVisibility;
    
    [self.visibilityStatesModel  saveVisibilityState:_navigationBarVisibility withController:self.visibleViewController ];
    
    [self updateNavigationBarVisibility:navigationBarVisibility];
}

- (void)updateNavigationBarVisibility:(SYNavigationControllerNavigationBarVisibility)navigationBarVisibility{
    switch (navigationBarVisibility) {
        case SYNavigationControllerNavigationBarVisibilityHidden:
            [self showCustomNavigationBar:NO withFadeAnimation:NO];
            break;
            
        case SYNavigationControllerNavigationBarVisibilityVisible:
            [self showCustomNavigationBar:YES withFadeAnimation:YES];
            break;
    }
}

- (void)showCustomNavigationBar:(BOOL)show withFadeAnimation:(BOOL)animated {
    [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
        if (show) {
            self.visualEffectView.alpha = 1;
            self.navigationBar.tintColor = [self originalTintColor];
            self.navigationBar.titleTextAttributes = [[UINavigationBar appearance] titleTextAttributes];
        } else {
            self.visualEffectView.alpha = 0;
            self.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor clearColor]};
        }
    }];
}

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //这里使用会有问题
//    [self updateNavigationBarVisibility:[self.visibilityStatesModel getVisibilityState:viewController]];
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    [transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ([context isCancelled]) {
            UIViewController *sourceViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
            [self updateNavigationBarVisibility:[self.visibilityStatesModel getVisibilityState:sourceViewController]];
        }
        
    }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self updateNavigationBarVisibility:[self.visibilityStatesModel getVisibilityState:viewController]];
    
    [self.visibilityStatesModel arrangeModelWithControllers:self.viewControllers];
    
    NSLog(@"%@",self.visibilityStatesModel.visibilityStates);
}


@end
