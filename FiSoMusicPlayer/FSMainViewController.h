//
//  FSMainViewController.h
//  FiSoMusicPlayer
//
//  Created by Tomoyuki Ito on 2013/08/31.
//  Copyright (c) 2013年 REVERTO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

typedef NS_ENUM(NSInteger, FSFilter) {
    FSFilterRating5,
    FSFilterLastPlayedDate1Week,
    FSFilterPlayCount20Over
};

typedef NS_ENUM(NSInteger, FSSort) {
    FSSortRatingDsec,
    FSSortLastPlayedDateDsec,
    FSSortPlayCountDsec
};

typedef NS_ENUM(NSInteger, FSLimit) {
    FSLimit10,
    FSLimit20,
    FSLimit30
};

@interface FSMainViewController : GAITrackedViewController

@property FSFilter filter;
@property FSSort sort;
@property FSLimit limit;

- (void)reloadMediaItemList;

@end
