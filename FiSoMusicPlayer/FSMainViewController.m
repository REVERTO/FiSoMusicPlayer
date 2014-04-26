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
#import <iAd/iAd.h>
#import "FSSettingViewController.h"
#import "FSMediaItemCell.h"

#define kCellId     @"FSMediaItemCell"
const double kSecond = 1;
const double kMinute = kSecond * 60;
const double kHour = kMinute * 60;
const double kDay = kHour * 24;
const double kMonth = kDay * 30;
const double kYear = kDay * 365;

@interface FSMainViewController ()
<UITableViewDataSource,UITableViewDelegate,ADBannerViewDelegate>
{
    BOOL _bannerIsVisible;
}

@property IBOutlet UITableView *tableView;
@property IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView;

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@property NSArray *mediaItems;
@property FSSettingViewController *settingVC;

@property NSArray *limitParams;

@end

@implementation FSMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mediaItems = @[];
        self.limitParams = @[@10,@20,@30];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bannerIsVisible = YES;
    
    self.title = NSLocalizedString(@"header title", nil);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // navigation button
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"music"] style:UIBarButtonItemStylePlain handler:
     ^(id sender) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"music:"]];
     }];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain handler:
     ^(id sender) {
         [self.navigationController pushViewController:self.settingVC animated:YES];
     }];
    
    self.navigationController.navigationBar.tintColor = RGBA(255,100,0,1.0);
    
    // regist original cell
    [self.tableView registerNib:[UINib nibWithNibName:kCellId bundle:nil] forCellReuseIdentifier:kCellId];
    
    self.controlsView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
    self.volumeView.tintColor = [UIColor blackColor];
    
    // create setting viewcontroller
    self.settingVC = [[FSSettingViewController alloc] initWithNibName:@"FSSettingViewController" bundle:nil];
    self.settingVC.mainVC = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    
    [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = NSStringFromClass([self class]);
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s",__FUNCTION__);
    self.filter = [[NSUserDefaults standardUserDefaults] integerForKey:@"Filter"];
    self.sort = [[NSUserDefaults standardUserDefaults] integerForKey:@"Sort"];
    self.limit = [[NSUserDefaults standardUserDefaults] integerForKey:@"Limit"];
    
    [self reloadMediaItemList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaItems.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.mediaItems.count) {
        UITableViewCell *spaceCell = [tableView dequeueReusableCellWithIdentifier:@"SpaceCell"];
        if (!spaceCell) {
            spaceCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SpaceCell"];
        }
        return spaceCell;
    }
    
    FSMediaItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    
    MPMediaItem *mediaItem = [self.mediaItems objectAtIndex:indexPath.row];
    
    // labelText
    cell.songLabel.text = (NSString *)[mediaItem valueForProperty:MPMediaItemPropertyTitle];
    cell.artistLabel.text = (NSString *)[mediaItem valueForProperty:MPMediaItemPropertyArtist];
    cell.playCountLabel.text = [(NSNumber *)[mediaItem valueForProperty:MPMediaItemPropertyPlayCount] stringValue];
    NSInteger rate = [(NSNumber *)[mediaItem valueForProperty:MPMediaItemPropertyRating] integerValue];
    cell.rateLabel.text = [NSString stringWithFormat:@"★%ld",rate];
    NSDate *lastPlayDate = (NSDate *)[mediaItem valueForProperty:MPMediaItemPropertyLastPlayedDate];
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:lastPlayDate];
    if (diff >= kYear)
        cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%ld %@",(NSInteger)(diff / kYear), NSLocalizedString(@"year ago", nil)];
    else if (diff >= kMonth)
        cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%ld %@",(NSInteger)(diff / kMonth), NSLocalizedString(@"month ago", nil)];
    else if (diff >= kDay)
        cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%ld %@",(NSInteger)(diff / kDay), NSLocalizedString(@"day ago", nil)];
    else if (diff >= kHour)
        cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%ld %@",(NSInteger)(diff / kHour), NSLocalizedString(@"hour ago", nil)];
    else if (diff >= kMinute)
        cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%ld %@",(NSInteger)(diff / kMinute), NSLocalizedString(@"minute ago", nil)];
    else
        cell.lastPlayDateLabel.text = [NSString stringWithFormat:@"%ld %@",(NSInteger)(diff / kSecond), NSLocalizedString(@"second ago", nil)];
    
    // image
    MPMediaItemArtwork *artwork = (MPMediaItemArtwork *)[mediaItem valueForProperty:MPMediaItemPropertyArtwork];
    cell.artwork.image = [artwork imageWithSize:CGSizeMake(tableView.rowHeight, tableView.rowHeight)];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.mediaItems.count) {
        return _controlsView.frame.size.height;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *playItems = [NSMutableArray array];
    for (NSInteger loop = indexPath.row; loop < self.mediaItems.count; loop++) {
        MPMediaItem *item = [self.mediaItems objectAtIndex:loop];
        [playItems addObject:item];
    }
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:playItems];
    MPMusicPlayerController *playerC = [MPMusicPlayerController iPodMusicPlayer];
    [playerC setQueueWithItemCollection:collection];
    [playerC play];
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // iPhoneの場合
            [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
            CGRect rect = _tableView.frame;
            rect.size.height -= _bannerView.frame.size.height;
            _tableView.frame = rect;
            _controlsView.frame = CGRectOffset(_controlsView.frame, 0, -(_bannerView.frame.size.height));
            _bannerView.frame = CGRectOffset(_bannerView.frame, 0, -(_bannerView.frame.size.height));
            [UIView commitAnimations];
            _bannerIsVisible = YES;
        }
        else {
            // iPadの場合
            [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
            _bannerView.frame = CGRectOffset(_bannerView.frame, 0, -(_bannerView.frame.size.height));
            [UIView commitAnimations];
            _bannerIsVisible = YES;
        }
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_bannerIsVisible)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // iPhoneの場合
            [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
            CGRect rect = _tableView.frame;
            rect.size.height  += _bannerView.frame.size.height;
            _tableView.frame = rect;
            _controlsView.frame = CGRectOffset(_controlsView.frame, 0, _bannerView.frame.size.height);
            _bannerView.frame = CGRectOffset(_bannerView.frame, 0, _bannerView.frame.size.height);
            [UIView commitAnimations];
            _bannerIsVisible = NO;
        }
        else {
            // iPadの場合
            [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
            _bannerView.frame = CGRectOffset(_bannerView.frame, 0, _bannerView.frame.size.height);
            [UIView commitAnimations];
            _bannerIsVisible = NO;
        }
    }
}

#pragma mark - Action event

- (IBAction)musicControlButtonTouched:(id)sender
{
    if (sender == self.playButton) {
        [[MPMusicPlayerController iPodMusicPlayer] play];
    }
    else if (sender == self.stopButton) {
        [[MPMusicPlayerController iPodMusicPlayer] stop];
    }
    else if (sender == self.nextButton) {
        [[MPMusicPlayerController iPodMusicPlayer] skipToNextItem];
    }
    else if (sender == self.previousButton) {
        [[MPMusicPlayerController iPodMusicPlayer] skipToPreviousItem];
    }
}

- (void)playbackStateDidChange:(NSNotification *)notif
{
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
        self.playButton.hidden = NO;
        self.stopButton.hidden = YES;
    }
    else {
        self.playButton.hidden = YES;
        self.stopButton.hidden = NO;
    }
}

#pragma mark - Public method

- (void)reloadMediaItemList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
        
        // pick rate 5 item
        NSMutableArray *pickedItems = [NSMutableArray array];
        
        NSNumber *rating;
        NSDate *lastPlayDate;
        NSTimeInterval diff;
        NSInteger day;
        NSNumber *playCount;
        
        switch (self.filter) {
            case FSFilterRating5:
                for (MPMediaItem *item in [mediaQuery items]) {
                    rating = (NSNumber *)[item valueForProperty:MPMediaItemPropertyRating];
                    if (rating.integerValue == 5) {
                        [pickedItems addObject:item];
                    }
                }
                break;
            case FSFilterLastPlayedDate1Week:
                for (MPMediaItem *item in [mediaQuery items]) {
                    lastPlayDate = (NSDate *)[item valueForProperty:MPMediaItemPropertyLastPlayedDate];
                    diff = [[NSDate date] timeIntervalSinceDate:lastPlayDate];
                    day = (NSInteger)(diff / (60 * 60 * 24));
                    if (day < 7) {
                        [pickedItems addObject:item];
                    }
                }
                break;
            case FSFilterPlayCount20Over:
                for (MPMediaItem *item in [mediaQuery items]) {
                    playCount = (NSNumber *)[item valueForProperty:MPMediaItemPropertyPlayCount];
                    if (playCount.integerValue > 20) {
                        [pickedItems addObject:item];
                    }
                }
                break;
        }
        
        // sort play count bigger
        [pickedItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            id obj1Value;
            id obj2Value;
            
            NSDate *lastPlayDate;
            NSTimeInterval diff;
            
            switch (self.sort) {
                case FSSortRatingDsec:
                    obj1Value = [(MPMediaItem *)obj1 valueForProperty:MPMediaItemPropertyRating];
                    obj2Value = [(MPMediaItem *)obj2 valueForProperty:MPMediaItemPropertyRating];
                    return [obj2Value compare:obj1Value];
                    
                case FSSortLastPlayedDateDsec:
                    lastPlayDate = (NSDate *)[(MPMediaItem *)obj1 valueForProperty:MPMediaItemPropertyLastPlayedDate];
                    diff = [[NSDate date] timeIntervalSinceDate:lastPlayDate];
                    obj1Value = [NSNumber numberWithDouble:diff];
                    lastPlayDate = (NSDate *)[(MPMediaItem *)obj2 valueForProperty:MPMediaItemPropertyLastPlayedDate];
                    diff = [[NSDate date] timeIntervalSinceDate:lastPlayDate];
                    obj2Value = [NSNumber numberWithDouble:diff];
                    return [obj1Value compare:obj2Value];
                    
                case FSSortPlayCountDsec:
                    obj1Value = [(MPMediaItem *)obj1 valueForProperty:MPMediaItemPropertyPlayCount];
                    obj2Value = [(MPMediaItem *)obj2 valueForProperty:MPMediaItemPropertyPlayCount];
                    return [obj2Value compare:obj1Value];
            }
        }];
        
        // limit items.
        NSMutableArray *limitItems = [NSMutableArray array];
        NSInteger addedCount = 0;
        NSInteger limitCount = [self.limitParams[self.limit] integerValue];
        for (MPMediaItem *item in pickedItems) {
            [limitItems addObject:item];
            addedCount++;
            if (addedCount >= limitCount) {
                break;
            }
        }
        
        self.mediaItems = [NSArray arrayWithArray:limitItems];
        [self.tableView reloadData];
    });
}

#pragma mark - Private method

@end
