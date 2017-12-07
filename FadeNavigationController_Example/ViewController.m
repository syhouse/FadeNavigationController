//
//  ViewController.m
//  FadeNavigationController_Example
//
//  Created by macmini on 2017/12/5.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "ViewController.h"

#import "SYNavigationController.h"

#define kGKHeaderHeight 150.f
#define kGKHeaderVisibleThreshold 44.f
#define kGKNavbarHeight 64.f

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@end

@implementation ViewController

- (void)loadView{
    [super loadView];
    
    self.title = @"test";
    
    [self setNavigationBarVisibility:SYNavigationControllerNavigationBarVisibilityHidden];
    
    self.tableView.backgroundColor = [UIColor redColor];
 }

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"测试";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewController *c = [[ViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}


#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffsetY = kGKHeaderHeight-scrollView.contentOffset.y;
    if (scrollOffsetY-kGKNavbarHeight < kGKHeaderVisibleThreshold) {
        [self setNavigationBarVisibility:SYNavigationControllerNavigationBarVisibilityVisible];
    } else {
        [self setNavigationBarVisibility:SYNavigationControllerNavigationBarVisibilityHidden];
    }
}

- (void)setNavigationBarVisibility:(SYNavigationControllerNavigationBarVisibility)navigationBarVisibility{
    SYNavigationController *nav = (SYNavigationController *)self.navigationController;
    [nav setSYNavigationControllerNavigationBarVisibility:navigationBarVisibility];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
