//
//  FSMainViewController.m
//  FiSoMusicPlayer
//
//  Created by Tomoyuki Ito on 2013/08/31.
//  Copyright (c) 2013年 REVERTO. All rights reserved.
//

#import "FSMainViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "FSSettingViewController.h"
#import "FSMediaItemCell.h"

#define kCellId     @"FSMediaItemCell"

@interface FSMainViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property IBOutlet UITableView *tableView;
@property IBOutlet UIView *controlsView;

@property NSArray *mediaItems;
@property FSSettingViewController *settingVC;

@end

@implementation FSMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mediaItems = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigation button
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks handler:
     ^(id sender) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"music:"]];
     }];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                 handler:
     ^(id sender) {
         [self.navigationController pushViewController:self.settingVC animated:YES];
     }];
    
    // upper layer offset
    CGFloat height;
    height = self.navigationController.navigationBar.frame.size.height;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,height)];
    height = self.controlsView.frame.size.height;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,height)];
    [self.tableView registerNib:[UINib nibWithNibName:kCellId bundle:nil] forCellReuseIdentifier:kCellId];
    
    // create setting viewcontroller
    self.settingVC = [[FSSettingViewController alloc] initWithNibName:@"FSSettingViewController" bundle:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadMediaItemList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSMediaItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    
    MPMediaItem *mediaItem = [self.mediaItems objectAtIndex:indexPath.row];
    
    // labelText
    cell.songLabel.text = (NSString *)[mediaItem valueForProperty:MPMediaItemPropertyTitle];
    cell.artistLabel.text = (NSString *)[mediaItem valueForProperty:MPMediaItemPropertyArtist];
    cell.playCountLabel.text = [(NSNumber *)[mediaItem valueForProperty:MPMediaItemPropertyPlayCount] stringValue];
    NSInteger rate = [(NSNumber *)[mediaItem valueForProperty:MPMediaItemPropertyRating] integerValue];
    cell.rateLabel.text = [NSString stringWithFormat:@"★%d",rate];
    NSDate *lastPlayDate = (NSDate *)[mediaItem valueForProperty:MPMediaItemPropertyLastPlayedDate];
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:lastPlayDate];
    NSInteger day = (NSInteger)(diff / (60 * 60 * 24));
    cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%d d、っmays ago",day];
    
    // image
    MPMediaItemArtwork *artwork = (MPMediaItemArtwork *)[mediaItem valueForProperty:MPMediaItemPropertyArtwork];
    cell.artwork.image = [artwork imageWithSize:CGSizeMake(tableView.rowHeight, tableView.rowHeight)];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPMediaItem *mediaItem = [self.mediaItems objectAtIndex:indexPath.row];
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:@[mediaItem]];
    MPMusicPlayerController *playerC = [MPMusicPlayerController iPodMusicPlayer];
    [playerC setQueueWithItemCollection:collection];
    [playerC play];
}

#pragma mark - Action event

#pragma mark - Public method

- (void)reloadMediaItemList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
        
        // pick rate 5 item
        NSMutableArray *pickedItems = [NSMutableArray array];
        for (MPMediaItem *item in [mediaQuery items]) {
            NSNumber *rating = (NSNumber *)[item valueForProperty:MPMediaItemPropertyRating];
            if (rating.integerValue == 5) {
                [pickedItems addObject:item];
            }
        }
        
        // sort play count bigger
        [pickedItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *obj1Count = [(MPMediaItem *)obj1 valueForProperty:MPMediaItemPropertyPlayCount];
            NSNumber *obj2Count = [(MPMediaItem *)obj2 valueForProperty:MPMediaItemPropertyPlayCount];
            //            return [obj1Count compare:obj2Count];
            return [obj2Count compare:obj1Count];
        }];
        
        self.mediaItems = [NSArray arrayWithArray:pickedItems];
        [self.tableView reloadData];
    });
}

#pragma mark - Private method

@end
