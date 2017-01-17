//
//  EHViewController.m
//  EHSlideView
//
//  Created by Eric Huang on 01/17/2017.
//  Copyright (c) 2017 Eric Huang. All rights reserved.
//
#import "EHViewController.h"
#import <Masonry/Masonry.h>

static NSString * const kDefaultCellIdentifier = @"DefaultCell";

@interface EHViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation EHViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self configureForNavigationBar];
    [self configureForViews];
    
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row+1, self.items[indexPath.row][@"title"]];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *controller = [[NSClassFromString(self.items[indexPath.row][@"class"]) alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - event response

#pragma mark - private methods

- (void)configureForNavigationBar {
    self.navigationItem.title = @"Home";
}

- (void)configureForViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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

- (NSArray *)items {
    if (!_items) {
        _items = @[
                   @{@"title" : @"EHSlideView Demo 1", @"class" : @"EHDemo1ViewController"},
                   @{@"title" : @"EHSlideView Demo 2", @"class" : @"EHDemo2ViewController"},
                   ];
    }
    
    return _items;
}

@end
