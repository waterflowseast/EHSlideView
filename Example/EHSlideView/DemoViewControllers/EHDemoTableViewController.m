//
//  EHDemoTableViewController.m
//  EHSlideView
//
//  Created by Eric Huang on 17/1/16.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import "EHDemoTableViewController.h"
#import <Masonry/Masonry.h>

static NSString * const kDefaultCellIdentifier = @"DefaultCell";

@interface EHDemoTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EHDemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)dealloc {
    NSLog(@"==> controller %ld dealloc", (long)self.controllerIndex);
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCellIdentifier];
    }
    
    NSString *text = [NSString stringWithFormat:@"controller %ld, row %ld", (long)self.controllerIndex, (long)indexPath.row];
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - getters & setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

@end
