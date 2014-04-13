//
//  FSMediaItemCell.h
//  FiSoMusicPlayer
//
//  Created by Tomoyuki Ito on 2013/09/08.
//  Copyright (c) 2013年 REVERTO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSMediaItemCell : UITableViewCell

@property IBOutlet UIImageView *artwork;
@property IBOutlet UILabel *songLabel;
@property IBOutlet UILabel *artistLabel;
@property IBOutlet UILabel *playCountLabel;
@property IBOutlet UILabel *rateLabel;
@property IBOutlet UILabel *lastPlayDateLabel;

@end
