//
//  GameKitHelper.m
//  Flappy Turtle - Aquarium Adventure
//
//  Created by Bill Crews on 2/5/15.
//  Copyright (c) 2015 Bill Crews. All rights reserved.
//

#import "GameKitHelper.h"

@interface GameKitHelper()<GKGameCenterControllerDelegate>
@end

@implementation GameKitHelper : NSObject

BOOL _enableGameCenter;

NSString *const PresentAuthenticationViewController =
    @"present_authentication_view_controller";

+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

#pragma mark - Game Center Authentication

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler =
        ^(UIViewController *viewController, NSError *error) {
        
            [self setLastError:error];
        
        if (viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            _enableGameCenter = YES;
        } else {
            _enableGameCenter = NO;
        }
    };
}

- (void)setAuthenticationViewController:
    (UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PresentAuthenticationViewController object:self];
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@",
              [[_lastError userInfo] description]);
    }
}


#pragma mark - Game Center Report Achievements

- (void)reportAchievements:(NSArray *)achievements
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    [GKAchievement reportAchievements:achievements
                withCompletionHandler:^(NSError *error){
                    [self setLastError:error];
                }];
}

#pragma mark - Game Center Report Scores to Leaderboard

- (void)reportScore:(int64_t)score
    forLeaderboardID:(NSString *)leaderboardID
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    
    GKScore *scoreReporter =
    [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
    }];
}

#pragma mark - Game Center ViewController

- (void)showGKGameCenterViewController:(UIViewController *)viewController
                          forViewState:(GKGameCenterViewControllerState)viewState

{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    
    GKGameCenterViewController *gameCenterViewController =
    [[GKGameCenterViewController alloc] init];
    
    gameCenterViewController.gameCenterDelegate = self;
    
    gameCenterViewController.viewState = viewState;
    
    [viewController presentViewController:gameCenterViewController
                                 animated:YES
                                 completion:nil];
    
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES
                                                 completion:nil];

}


@end