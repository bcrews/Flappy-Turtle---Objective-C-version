//
//  GameKitHelper.h
//  Flappy Turtle - Aquarium Adventure
//
//  Created by Bill Crews on 2/5/15.
//  Copyright (c) 2015 Bill Crews. All rights reserved.
//

@import GameKit;

extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject

@property (nonatomic, readonly)
  UIViewController *authenticationViewController;

@property (nonatomic, readonly) NSError *lastError;

+ (instancetype)sharedGameKitHelper;

- (void)authenticateLocalPlayer;

- (void)reportAchievements:(NSArray *)achievements;

- (void)showGKGameCenterViewController:(UIViewController *)viewController
                          forViewState:(GKGameCenterViewControllerState)viewState;

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString *)leaderboardID;

@end
