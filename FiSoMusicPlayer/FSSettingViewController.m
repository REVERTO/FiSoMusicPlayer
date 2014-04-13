//
//  FSSettingViewController.m
//  FiSoMusicPlayer
//
//  Created by Tomoyuki Ito on 2013/08/31.
//  Copyright (c) 2013年 REVERTO. All rights reserved.
//

#import "FSSettingViewController.h"

@interface FSSettingViewController ()
<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property IBOutlet UITableView *tableView;
@property IBOutlet UIPickerView *pickerView;

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
        [self.settingData addObject:self.settingItems[0][@"properties"][0]];
        [self.settingData addObject:self.settingItems[1][@"properties"][0]];
        [self.settingData addObject:self.settingItems[2][@"properties"][0]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView reloadData];
    
    // upper layer offset
    CGFloat height;
    height = self.navigationController.navigationBar.frame.size.height;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,height)];
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
    [self.pickerView reloadAllComponents];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_settingItems[self.selectedItemIndex][@"properties"] count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _settingItems[self.selectedItemIndex][@"properties"][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // change setting data
    [self.settingData replaceObjectAtIndex:self.selectedItemIndex
                                withObject:self.settingItems[self.selectedItemIndex][@"properties"][row]];
    [self.tableView reloadData];
}

@end
