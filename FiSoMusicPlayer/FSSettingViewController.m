//
//  FSSettingViewController.m
//  FiSoMusicPlayer
//
//  Created by Tomoyuki Ito on 2013/08/31.
//  Copyright (c) 2013年 REVERTO. All rights reserved.
//

#import "FSSettingViewController.h"
#import "MMPickerView.h"
#import "FSMainViewController.h"

@interface FSSettingViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property IBOutlet UITableView *tableView;

@property NSArray *settingItems;
@property NSMutableArray *settingData;
@property NSInteger selectedItemIndex;

@end

@implementation FSSettingViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.settingItems =
        @[ @{@"name":@"Filter",@"properties":@[
                     @"Rating-5",@"LastPlayedDate-1week",@"PlayCount-20"
                     ]},
           @{@"name":@"Sort",@"properties":@[
                     @"Rating-Desc",@"LastPlayedDate-Desc",@"PlayCount-Desc"
                     ]},
           @{@"name":@"Limit",@"properties":@[
                     @"10",@"20",@"30"
                     ]}];
        self.settingData = [NSMutableArray array];
        FSFilter filter = [[NSUserDefaults standardUserDefaults] integerForKey:@"Filter"];
        [self.settingData addObject:self.settingItems[0][@"properties"][filter]];
        FSSort sort = [[NSUserDefaults standardUserDefaults] integerForKey:@"Sort"];
        [self.settingData addObject:self.settingItems[1][@"properties"][sort]];
        FSLimit limit = [[NSUserDefaults standardUserDefaults] integerForKey:@"Limit"];
        [self.settingData addObject:self.settingItems[2][@"properties"][limit]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = NSStringFromClass([self class]);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _settingItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _settingItems[section][@"name"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellId = @"settingitem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
    }
    
    cell.textLabel.text = self.settingData[indexPath.section];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedItemIndex = indexPath.section;
    NSArray *strings = self.settingItems[indexPath.section][@"properties"];

    [MMPickerView showPickerViewInView:self.view
                           withStrings:self.settingItems[indexPath.section][@"properties"]
                           withOptions:@{MMselectedObject:self.settingData[self.selectedItemIndex]}
                            completion:
     ^(NSString *selectedString) {
         // change setting data
         [self.settingData replaceObjectAtIndex:self.selectedItemIndex
                                     withObject:selectedString];
         [[NSUserDefaults standardUserDefaults] setInteger:[strings indexOfObject:selectedString]
                                                    forKey:self.settingItems[indexPath.section][@"name"]];
         [self.tableView reloadData];
     }];
}

@end
