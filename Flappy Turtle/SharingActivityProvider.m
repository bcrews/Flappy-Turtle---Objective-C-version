//
//  SharingActivityProvider.m
//  Flappy Turtle - Aquarium Adventure
//
//  Created by Bill Crews on 11/12/14.
//  Copyright (c) 2014 Bill Crews. All rights reserved.
//

#import "SharingActivityProvider.h"
#import <UIKit/UIKit.h>


@implementation SharingActivityProvider

static const int    APP_STORE_ID        =   934492427;

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    // Log out the activity type that we are sharing with
    NSLog(@"%@", activityType);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSInteger score = [prefs integerForKey:@"currentScore"];

    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%d?mt=8",APP_STORE_ID];
  
  NSURL *url  = [NSURL URLWithString:urlString];

    // Create the default sharing string
    NSString *shareString =
      [NSString stringWithFormat:@"I scored %d points in Flappy Turtle: "
       "Aquarium Adventure!! \n\nI challenge you to beat my score!! \n \n"
       "Download the app from the link below:\n", (int)score];
    
    // customize the sharing string for facebook, twitter, weibo, and google+
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        shareString =
          [NSString stringWithFormat:@"@Flappy Turtle: Aquarium Adventure \n"
           "I scored %d points in Flappy Turtle: Aquarium Adventure!!\n",
           (int)score];
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        shareString =
          [NSString stringWithFormat:@"@BCAppDesigns\nI scored %d in Flappy "
                          "Turtle: Aquarium Adventure.\n%@",(int)score, url];
    } else if ([activityType isEqualToString:UIActivityTypeMail]) {
        shareString =
          [NSString stringWithFormat:@"I scored %d points in Flappy Turtle: "
           "Aquarium Adventure!! \n\nI challenge you to beat my score!! \n \n"
           "Download the app from the link below:", (int)score];
    }
    else if ([activityType isEqualToString:UIActivityTypePostToWeibo]) {
        shareString = [NSString stringWithFormat:@"%@", shareString];
    }
    
    return shareString;
}


- (id)activityViewControllerPlaceholderItem:
        (UIActivityViewController *)activityViewController
{
    return @"";
}

@end