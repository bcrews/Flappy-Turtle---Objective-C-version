//
//  MyScene.m
//  Flappy Turtle: Aquarium Adventure
//
//  Created by Bill Crews on 10/19/14.
//  Copyright (c) 2014 BC App Designs, LLC. All rights reserved.
//

#import "MyScene.h"
#import <iAd/iAd.h>
#import "AchievementsHelper.h"
#import "GameKitHelper.h"

typedef NS_ENUM(int, Layer) {
  
  LayerBackground,
  LayerObstacle,
  LayerForeground,
  LayerPlayer,
  LayerUI,
  LayerFlash
};

typedef NS_OPTIONS(int, EntityCategory) {
  
  EntityCategoryPlayer    =   1 << 0,
  EntityCategoryObstacle  =   1 << 1,
  EntityCategoryGround    =   1 << 2
};

// Gameplay - Turtle Movement
//float   kGravity            =   -800.0;
//float   kImpulse            =    250.0;
//float   kAngularVelocity    =    200;
//
//// Gameplay - Ground Speed
//float   kGroundSpeed        =    150.0f;

float   kGravity            =   -550.0;
float   kImpulse            =    250.0;
float   kAngularVelocity    =    100;

// Gameplay - Ground Speed
float   kGroundSpeed        =    150.0f;

// Gameplay - Obstacles Positioning
float   kGapMultiplier      =     1.7f;  // 1.65 seems to be a good starting value


static const float  kBottomObstacleMinFraction  =   0.13;  // 0.13 seems to be a good min
static const float  kBottomObstacleMaxFraction  =   0.62;  // 0.62 seems to be a good max
static const float  kBottomObstacleMinFractionIpad =  0.13;
static const float  kBottomObstacleMaxFractionIpad =  0.58;
static const float  kBottomObstacleMinFractionIphone6plus = 0.13;
static const float  kBottomObstacleMaxFractionIphone6plus = 0.61;

// Gameplay - Obstacle Timing
static const float  kFirstSpawnDelay    =   1.75;
float   kEverySpawnDelay                =   3.50;

// Looks
static const int    kNumForegrounds     =    2;
static const int    kNumBackgrounds     =    4;
float               kMargin             =   20;
BOOL                kMarginFlagSet      =   NO;
static const float  kAnimDelay          =  0.3;
static const int    kNumTurtleFrames    =   13;
static const int    kNumJellyFishFrames =   24;
static const float  kMinDegrees         = -100;
static const float  kMaxDegrees         =   12;
static const float  kIpadScaleFactor    =   1.5;

static NSString *const  kFontName       =   @"AmericanTypewriter-Bold";
static const float offsetX = 3.0;
static const float offsetY = -3.0;

// App ID
static const int    APP_STORE_ID        =   934492427;
static NSString *const kLeaderboardID   =   @"grp.com.BCAppDesigns.FlappyTurtleAA";

@interface  MyScene() <SKPhysicsContactDelegate>
@end

@implementation MyScene {
  // Set up layers with empty nodes
  SKNode          *_worldNode;
  
  float           _playableStart;
  float           _playableHeight;
  
  SKSpriteNode    *_player;
  SKSpriteNode    *_topObstacle;
  SKSpriteNode    *_bottomObstacle;
  
  
  CGPoint         _playerVelocity;
  float           _playerAngularVelocity;
  
  NSTimeInterval  _lastTouchTime;
  float           _lastTouchY;
  
  SKAction        *_dingAction;
  SKAction        *_flapAction;
  SKAction        *_whackAction;
  SKAction        *_fallingAction;
  SKAction        *_hitGroundAction;
  SKAction        *_popAction;
  SKAction        *_coinAction;
  
  SKAction        *_topObstacleAnimation;
  //  SKAction        *_bottomObstacleAnimation; // If we want to animate bottom
                                                 // obstacle.
  
  BOOL            _hitGround;
  BOOL            _hitObstacle;
  
  GameState       _gameState;
  SKLabelNode     *_scoreLabel;
  SKLabelNode     *_scoreLabelOutline;
  
  int             _score;
  
  NSTimeInterval  _lastUpdateTime;
  NSTimeInterval  _dt;
  
}

@synthesize sceneDelegate = _sceneDelegate;

#pragma mark initWithSize

-(id)initWithSize:(CGSize)size sceneDelegate:(id<MySceneDelegate>)sceneDelegate
            state:(GameState)state
{
  
  if (self = [super initWithSize:size]) {
    _sceneDelegate = sceneDelegate;
    
//    UIScreen *mainScreen = [UIScreen mainScreen];
//    NSLog(@"Screen bounds: %@, Screen resolution width: %.f, scale: %.f, nativeScale: %.f",
//          NSStringFromCGRect(mainScreen.bounds),mainScreen.currentMode.size.width,
//          mainScreen.scale, mainScreen.nativeScale);
//    
//    NSLog(@"Is iPhone6Plus? %d",[self iPhone6Plus]);
//    NSLog(@"Is iPhone6? %d", [self iPhone6]);
//    
//    NSLog(@"Size: %@", NSStringFromCGSize(size));
    
//    if ([self iPhone6Plus] && !kMarginFlagSet) {
//      kMargin *= 4.4;
//      kMarginFlagSet = YES;
//    }
    
    // Intialize _worldNode as empty node
    _worldNode = [SKNode node];
    
    // Display on screen
    [self addChild:_worldNode];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    
    if (state == GameStateMainMenu) {
      [self switchToMainMenu];
    } else if (state == GameStatePlay) {
      [self flapPlayer];
    } else if (state == GameStateTutorial) {
      [self switchToTutorial];
    } else if (state == GameStateGameOver) {
      [self switchToGameOver];
    } else {
      [self switchToNewGame:GameStateMainMenu];
    }
    
    
  }
  return self;
}

-(BOOL)iPhone6Plus {
  
  if ([UIScreen mainScreen].scale > 2.1) return YES;  // Scale is only 3 when not in scaled mode for iPhone 6
  return NO;
}

-(BOOL)iPhone6 {
  
  int screenWidth = (int)[UIScreen mainScreen].currentMode.size.width;
  if (screenWidth == 750) return YES;
  return NO;
}



#pragma mark - Setup Methods

-(void)setupBackground {
  
  NSString *backgroundName;
  
  for (int i = 0; i < kNumBackgrounds; i++) {
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
      if ([self iPhone6Plus]) {
        backgroundName = [NSString stringWithFormat:@"Aquarium_BG_%i-736@3x",i];
      } else if ([self iPhone6]) {
        backgroundName = [NSString stringWithFormat:@"Aquarium_BG_%i-667",i];
      } else {
        backgroundName  = [NSString stringWithFormat:@"Aquarium_BG_%i",i];
      }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
      backgroundName = [NSString stringWithFormat:@"Aquarium_BG_%i-ipad",i];
    }
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:backgroundName];
    
    background.anchorPoint = CGPointMake(0.5, 1);
    background.position = CGPointMake(i * self.size.width,self.size.height);
    
    background.name = @"Background";
    [_worldNode addChild:background];
    
    _playableStart              = self.size.height - background.size.height;
    _playableHeight             = background.size.height;
  }
  
  CGPoint lowerLeft               = CGPointMake(0, _playableStart);
  CGPoint lowerRight              = CGPointMake(self.size.width, _playableStart);
  
  self.physicsBody                = [SKPhysicsBody bodyWithEdgeFromPoint:lowerLeft toPoint:lowerRight];
  // [self skt_attachDebugLineFromPoint:lowerLeft toPoint:lowerRight color:[UIColor redColor]];
  
  self.physicsBody.categoryBitMask    =   EntityCategoryGround;
  self.physicsBody.collisionBitMask   =   0;
  self.physicsBody.contactTestBitMask =   EntityCategoryPlayer;
  
}

-(void)setupForeground {
  
  SKSpriteNode *foreground = nil;
  
  for (int i = 0; i < kNumForegrounds; ++i) {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
      if ([self iPhone6Plus]) {
        foreground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground-736@3x"];
      } else if ([self iPhone6]) {
        foreground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground-667"];
      } else {
        foreground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground"];
      }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      foreground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground-ipad"];
    }
    
    foreground.anchorPoint = CGPointMake(0,1);
    foreground.position = CGPointMake(i * self.size.width, _playableStart);
    foreground.zPosition = LayerForeground;
    foreground.name = @"Foreground";
    [_worldNode addChild:foreground];
  }
}

-(void)setupPlayer {
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    if ([self iPhone6Plus]) {
      _player = [SKSpriteNode spriteNodeWithImageNamed:@"Turtle00-667"];
    } else if ([self iPhone6]) {
      _player = [SKSpriteNode spriteNodeWithImageNamed:@"Turtle00-667"];
    } else {
      _player = [SKSpriteNode spriteNodeWithImageNamed:@"Turtle00"];
    }
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _player = [SKSpriteNode spriteNodeWithImageNamed:@"Turtle00-ipad"];
  }
  
  _player.position    = CGPointMake(self.size.width * 0.25,
                                    _playableHeight * 0.5 + _playableStart);
  _player.zPosition   = LayerPlayer;
  [_worldNode addChild:_player];
  
  CGFloat offsetX     = _player.frame.size.width  * _player.anchorPoint.x;
  CGFloat offsetY     = _player.frame.size.height * _player.anchorPoint.y;
  
  CGMutablePathRef path   = CGPathCreateMutable();
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
    CGPathMoveToPoint(path, NULL, 45 - offsetX, 70 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 70 - offsetY);
    CGPathAddLineToPoint(path, NULL, 73 - offsetX, 60 - offsetY);
    CGPathAddLineToPoint(path, NULL, 79 - offsetX, 59 - offsetY);
    CGPathAddLineToPoint(path, NULL, 82 - offsetX, 67 - offsetY);
    CGPathAddLineToPoint(path, NULL, 90 - offsetX, 78 - offsetY);
    CGPathAddLineToPoint(path, NULL, 107 - offsetX, 78 - offsetY);
    CGPathAddLineToPoint(path, NULL, 126 - offsetX, 70 - offsetY);
    CGPathAddLineToPoint(path, NULL, 128 - offsetX, 50 - offsetY);
    CGPathAddLineToPoint(path, NULL, 112 - offsetX, 50 - offsetY);
    CGPathAddLineToPoint(path, NULL, 105 - offsetX, 45 - offsetY);
    CGPathAddLineToPoint(path, NULL, 105 - offsetX, 45 - offsetY);
    CGPathAddLineToPoint(path, NULL, 86 - offsetX, 50 - offsetY);
    CGPathAddLineToPoint(path, NULL, 84 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 77 - offsetX, 18 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 15 - offsetY);
    CGPathAddLineToPoint(path, NULL, 46 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 23 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 5 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 11 - offsetX, 49 - offsetY);
    CGPathAddLineToPoint(path, NULL, 24 - offsetX, 51 - offsetY);
    CGPathAddLineToPoint(path, NULL, 34 - offsetX, 68 - offsetY);
    CGPathAddLineToPoint(path, NULL, 34 - offsetX, 68 - offsetY);
    CGPathCloseSubpath(path);
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
    CGPathMoveToPoint(path, NULL, 26 - offsetX, 29 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 53 - offsetY);
    CGPathAddLineToPoint(path, NULL, 12 - offsetX, 73 - offsetY);
    CGPathAddLineToPoint(path, NULL, 37 - offsetX, 77 - offsetY);
    CGPathAddLineToPoint(path, NULL, 53 - offsetX, 99 - offsetY);
    CGPathAddLineToPoint(path, NULL, 70 - offsetX, 110 - offsetY);
    CGPathAddLineToPoint(path, NULL, 91 - offsetX, 109 - offsetY);
    CGPathAddLineToPoint(path, NULL, 108 - offsetX, 99 - offsetY);
    CGPathAddLineToPoint(path, NULL, 122 - offsetX, 90 - offsetY);
    CGPathAddLineToPoint(path, NULL, 133 - offsetX, 98 - offsetY);
    CGPathAddLineToPoint(path, NULL, 131 - offsetX, 119 - offsetY);
    CGPathAddLineToPoint(path, NULL, 142 - offsetX, 128 - offsetY);
    CGPathAddLineToPoint(path, NULL, 157 - offsetX, 133 - offsetY);
    CGPathAddLineToPoint(path, NULL, 175 - offsetX, 132 - offsetY);
    CGPathAddLineToPoint(path, NULL, 188 - offsetX, 128 - offsetY);
    CGPathAddLineToPoint(path, NULL, 197 - offsetX, 116 - offsetY);
    CGPathAddLineToPoint(path, NULL, 202 - offsetX, 104 - offsetY);
    CGPathAddLineToPoint(path, NULL, 201 - offsetX, 93 - offsetY);
    CGPathAddLineToPoint(path, NULL, 187 - offsetX, 78 - offsetY);
    CGPathAddLineToPoint(path, NULL, 166 - offsetX, 76 - offsetY);
    CGPathAddLineToPoint(path, NULL, 141 - offsetX, 79 - offsetY);
    CGPathAddLineToPoint(path, NULL, 129 - offsetX, 63 - offsetY);
    CGPathAddLineToPoint(path, NULL, 133 - offsetX, 37 - offsetY);
    CGPathAddLineToPoint(path, NULL, 121 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 99 - offsetX, 14 - offsetY);
    CGPathAddLineToPoint(path, NULL, 74 - offsetX, 14 - offsetY);
    CGPathAddLineToPoint(path, NULL, 83 - offsetX, 28 - offsetY);
    CGPathAddLineToPoint(path, NULL, 63 - offsetX, 43 - offsetY);
    
    CGPathCloseSubpath(path);
    
  }
  
  _player.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [_player skt_attachDebugFrameFromPath:path color:[UIColor redColor]];
  
  _player.physicsBody.usesPreciseCollisionDetection = YES;  // Keep from falling through ground
  _player.physicsBody.categoryBitMask     = EntityCategoryPlayer;
  _player.physicsBody.collisionBitMask    = 0;
  _player.physicsBody.contactTestBitMask  = EntityCategoryObstacle |
  EntityCategoryGround;
  
  if ([self iPhone6Plus] || [self iPhone6]) {
    [_player setScale:1.10];
  } else {
    [_player setScale:0.90];
  }
  
  SKAction    *moveUp     = [SKAction moveByX:0 y:10 duration:0.4];
  moveUp.timingMode       = SKActionTimingEaseInEaseOut;
  SKAction    *moveDown   = [moveUp reversedAction];
  SKAction    *sequence   = [SKAction sequence:@[moveUp,moveDown]];
  SKAction    *repeate    = [SKAction repeatActionForever:sequence];
  [_player runAction:repeate withKey:@"Wobble"];
}

-(void)setupSounds {
  
  _dingAction         = [SKAction playSoundFileNamed:@"ding.wav"
                                   waitForCompletion:NO];
  _flapAction         = [SKAction playSoundFileNamed:@"flapping.wav"
                                   waitForCompletion:NO];
  _whackAction        = [SKAction playSoundFileNamed:@"whack.wav"
                                   waitForCompletion:NO];
  _fallingAction      = [SKAction playSoundFileNamed:@"falling.wav"
                                   waitForCompletion:NO];
  _hitGroundAction    = [SKAction playSoundFileNamed:@"hitGround.wav"
                                   waitForCompletion:NO];
  _popAction          = [SKAction playSoundFileNamed:@"pop.wav"
                                   waitForCompletion:NO];
  _coinAction         = [SKAction playSoundFileNamed:@"coin.wav"
                                   waitForCompletion:NO];
}

-(void)setupScoreLabel {
  
  _scoreLabel             = [[SKLabelNode alloc] initWithFontNamed:kFontName];
  _scoreLabel.fontColor   = [SKColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _scoreLabel.fontSize = 50;
  }
  
  _scoreLabel.position    = CGPointMake(self.size.width/2,self.size.height - 20);
  _scoreLabel.text        = @"0";
  _scoreLabel.verticalAlignmentMode   = SKLabelVerticalAlignmentModeTop;
  _scoreLabel.zPosition   = LayerUI + 1;
  
  [_worldNode addChild:_scoreLabel];
  
  
  _scoreLabelOutline = [[SKLabelNode alloc] initWithFontNamed:kFontName];
  _scoreLabelOutline.fontColor = [SKColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1.0];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _scoreLabelOutline.fontSize = 50;
  }
  
  _scoreLabelOutline.position = CGPointMake(self.size.width/2 + offsetX, self.size.height - 20 + offsetY);
  _scoreLabelOutline.text = _scoreLabel.text;
  _scoreLabelOutline.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreLabelOutline.zPosition = _scoreLabel.zPosition - 1;
  
  [_worldNode addChild:_scoreLabelOutline];
  
}

-(void)setupScoreCard {
  
  if (_score > [self bestScore]) {
    [self setBestScore:_score];
  }
  
  SKSpriteNode *scorecard = nil;
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
    scorecard = [SKSpriteNode spriteNodeWithImageNamed:@"Scorecard"];
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    scorecard = [SKSpriteNode spriteNodeWithImageNamed:@"Scorecard-ipad"];
  }
  
  scorecard.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
  scorecard.name = @"Tutorial";
  scorecard.zPosition = LayerUI;
  [_worldNode addChild:scorecard];
  
  
  SKLabelNode *lastScore = [[SKLabelNode alloc]
                            initWithFontNamed:kFontName];
  lastScore.fontColor = [SKColor colorWithRed:255.0/255 green:248.0/255 blue:121.0/255 alpha:1.0];
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    lastScore.fontSize = 50;
  }
  
  lastScore.position = CGPointMake(-scorecard.size.width * 0.175, -scorecard.size.height * 0.275);
  lastScore.text = [NSString stringWithFormat:@"%d",_score];
  lastScore.zPosition = LayerUI + 1;
  [scorecard addChild:lastScore];
  
  SKLabelNode *lastScoreOutline = [[SKLabelNode alloc] initWithFontNamed:kFontName];
  lastScoreOutline.fontColor = [SKColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1.0];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    lastScoreOutline.fontSize = 50;
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    lastScoreOutline.fontSize = lastScore.fontSize;
  }
  lastScoreOutline.position = CGPointMake(lastScore.position.x + offsetX, lastScore.position.y + offsetY);
  lastScoreOutline.text = lastScore.text;
  lastScoreOutline.zPosition = lastScore.zPosition - 1;
  
  [scorecard addChild:lastScoreOutline];
  
  SKLabelNode *bestScore = [[SKLabelNode alloc]
                            initWithFontNamed:kFontName];
  bestScore.fontColor = [SKColor colorWithRed:255.0/255 green:248.0/255 blue:121.0/255 alpha:1.0];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    bestScore.fontSize = 50;
  }
  
  bestScore.position = CGPointMake(scorecard.size.width * 0.185, -scorecard.size.height * 0.275);
  
  bestScore.text = [NSString stringWithFormat:@"%d",[self bestScore]];
  bestScore.zPosition = LayerUI + 1;
  [scorecard addChild:bestScore];
  
  SKLabelNode *bestScoreOutline = [[SKLabelNode alloc] initWithFontNamed:kFontName];
  bestScoreOutline.fontColor = [SKColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1.0];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    bestScoreOutline.fontSize = 50;
  }
  
  bestScoreOutline.position = CGPointMake(bestScore.position.x + offsetX, bestScore.position.y + offsetY);
  bestScoreOutline.text = bestScore.text;
  bestScoreOutline.zPosition = bestScore.zPosition - 1;
  [scorecard addChild:bestScoreOutline];
  
  SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithImageNamed:@"GameOver"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [gameOver setScale:kIpadScaleFactor];
    gameOver.position = CGPointMake(self.size.width/2,
                                    self.size.height/2
                                    + scorecard.size.height/2
                                    + kMargin * 2.5
                                    + gameOver.size.height/2);
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    [gameOver setScale:1.0];
    
    if ([self iPhone6]) {
      gameOver.position = CGPointMake(self.size.width/2,
                                      self.size.height/2 + scorecard.size.height/2
                                      + kMargin * 2
                                      + gameOver.size.height/2);
    } else if ([self iPhone6Plus]) {
      gameOver.position = CGPointMake(self.size.width/2, self.size.height/2 + scorecard.size.height/2 + kMargin + gameOver.size.height/2);
    } else {
      gameOver.position = CGPointMake(self.size.width/2, self.size.height/2 + scorecard.size.height/2 + kMargin + gameOver.size.height/2);
    }
  }
  
  gameOver.zPosition = LayerUI;
  
  [_worldNode addChild:gameOver];
  
  SKSpriteNode *okButton = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [okButton setScale:kIpadScaleFactor];
  }
  
  if ([self iPhone6]) {
    okButton.position = CGPointMake(self.size.width * 0.25,
                                    self.size.height/2 - scorecard.size.height/2
                                    - okButton.size.height/2
                                    - kMargin);
  } else if ([self iPhone6Plus]) {
    okButton.position = CGPointMake(self.size.width * 0.25,
                                    self.size.height/2 - scorecard.size.height/2
                                    -okButton.size.height/2
                                    - kMargin/2);
  } else {
    okButton.position = CGPointMake(self.size.width * 0.25,
                                    self.size.height/2 - scorecard.size.height/2
                                    -okButton.size.height/2);
  }
  
  okButton.zPosition = LayerUI;
  
  [_worldNode addChild:okButton];
  
  SKSpriteNode *ok = [SKSpriteNode spriteNodeWithImageNamed:@"OK"];
  ok.position = CGPointZero;
  ok.zPosition = LayerUI;
  [okButton addChild:ok];
  
  SKSpriteNode *shareButton = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [shareButton setScale:kIpadScaleFactor];
  }
  
  if ([self iPhone6]) {
    shareButton.position = CGPointMake(self.size.width * 0.75,
                                       self.size.height/2 - scorecard.size.height/2
                                       -shareButton.size.height/2
                                       - kMargin);
    
  } else if ([self iPhone6Plus]) {
    shareButton.position = CGPointMake(self.size.width * 0.75,
                                       self.size.height/2 - scorecard.size.height/2
                                       -shareButton.size.height/2
                                       - kMargin/2);
  } else {
    shareButton.position = CGPointMake(self.size.width * 0.75,
                                       self.size.height/2 - scorecard.size.height/2
                                       -shareButton.size.height/2);
  }
  
  shareButton.zPosition = LayerUI;
  
  [_worldNode addChild:shareButton];
  
  SKSpriteNode *share = [SKSpriteNode spriteNodeWithImageNamed:@"Share"];
  share.position = CGPointZero;
  share.zPosition = LayerUI;
  
  [shareButton addChild:share];
  
  SKSpriteNode *achievementsButton = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [achievementsButton setScale:kIpadScaleFactor];
  }
  
  if ([self iPhone6]) {
    achievementsButton.position = CGPointMake(self.size.width * 0.25,
                                              self.size.height/2 - scorecard.size.height/2
                                              - kMargin/6 - shareButton.size.height
                                              - kMargin/3.5 - achievementsButton.size.height/2
                                              - kMargin);
  } else if ([self iPhone6Plus]) {
    achievementsButton.position = CGPointMake(self.size.width * 0.25,
                                              self.size.height/2 - scorecard.size.height/2
                                              - kMargin/6 - shareButton.size.height
                                              - kMargin/3.5 - achievementsButton.size.height/2
                                              - kMargin/3.5);
  } else {
    achievementsButton.position = CGPointMake(self.size.width * 0.25,
                                              self.size.height/2 - scorecard.size.height/2
                                              - kMargin/6 - shareButton.size.height
                                              - kMargin/3.5 - achievementsButton.size.height/2);
  }
  
  achievementsButton.zPosition = LayerUI;
  
  [_worldNode addChild:achievementsButton];
  
  SKSpriteNode *achievements = [SKSpriteNode spriteNodeWithImageNamed:@"Achievements"];
  achievements.position = CGPointZero;
  achievements.zPosition = LayerUI;
  [achievementsButton addChild:achievements];
  
  
  SKSpriteNode *leaderboardButton = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [leaderboardButton setScale:kIpadScaleFactor];
  }
  
  if ([self iPhone6]) {
    leaderboardButton.position = CGPointMake(self.size.width * 0.75,
                                             self.size.height/2 - scorecard.size.height/2
                                             - kMargin/6 - shareButton.size.height
                                             - kMargin/3.5 - leaderboardButton.size.height/2
                                             - kMargin);
  } else if ([self iPhone6Plus]) {
    leaderboardButton.position = CGPointMake(self.size.width * 0.75,
                                             self.size.height/2 - scorecard.size.height/2
                                             - kMargin/6 - shareButton.size.height
                                             - kMargin/3.5 - leaderboardButton.size.height/2
                                             - kMargin/3.5);
  } else {
    leaderboardButton.position = CGPointMake(self.size.width * 0.75,
                                             self.size.height/2 - scorecard.size.height/2
                                             - kMargin/6 - shareButton.size.height
                                             - kMargin/3.5 - leaderboardButton.size.height/2);
  }
  
  leaderboardButton.zPosition = LayerUI;
  
  
  [_worldNode addChild:leaderboardButton];
  
  SKSpriteNode *leaderboard = [SKSpriteNode spriteNodeWithImageNamed:@"Leaderboard"];
  leaderboard.position = CGPointZero;
  leaderboard.zPosition = LayerUI;
  [leaderboardButton addChild:leaderboard];
  
  
  _scoreLabel.alpha   = 0;
  _scoreLabelOutline.alpha = 0;
  
  gameOver.scale = 0.001;
  gameOver.alpha = 0;
  
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    SKAction *group = [SKAction group:@[
                                        [SKAction fadeInWithDuration:kAnimDelay],
                                        [SKAction scaleTo:1.0 duration:kAnimDelay
                                         ]]];
    
    group.timingMode = SKActionTimingEaseInEaseOut;
    [gameOver runAction:[SKAction sequence:@[
                                             [SKAction waitForDuration:kAnimDelay],
                                             group]
                         ]];
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
    SKAction *group = [SKAction group:@[
                                        [SKAction fadeInWithDuration:kAnimDelay],
                                        [SKAction scaleTo:kIpadScaleFactor duration:kAnimDelay
                                         ]]];
    group.timingMode = SKActionTimingEaseInEaseOut;
    [gameOver runAction:[SKAction sequence:@[
                                             [SKAction waitForDuration:kAnimDelay],
                                             group]
                         ]];
    
  }
  
  
  scorecard.position = CGPointMake(self.size.width * 0.5, -scorecard.size.height/2);
  SKAction *moveTo = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height * 0.54) duration:kAnimDelay];
  moveTo.timingMode = SKActionTimingEaseInEaseOut;
  [scorecard runAction:[SKAction sequence:@[
                                            [SKAction waitForDuration:kAnimDelay*2],
                                            moveTo
                                            ]]];
  
  okButton.alpha = 0;
  shareButton.alpha = 0;
  achievementsButton.alpha = 0;
  leaderboardButton.alpha = 0;
  
  SKAction *fadeIn = [SKAction sequence:@[
                                          [SKAction waitForDuration:kAnimDelay*3],
                                          [SKAction fadeInWithDuration:kAnimDelay]
                                          ]];
  [okButton runAction:fadeIn];
  [shareButton runAction:fadeIn];
  [achievementsButton runAction:fadeIn];
  [leaderboardButton runAction:fadeIn];
  
  // Sound Effects
  SKAction *pops = [SKAction sequence:@[
                                        [SKAction waitForDuration:kAnimDelay],
                                        _popAction,
                                        [SKAction waitForDuration:kAnimDelay],
                                        _popAction,
                                        [SKAction runBlock:^{
    [self switchToGameOver];
  }]
                                        ]];
  [self runAction:pops];
  
}

-(void)setupTutorial {
  
  SKSpriteNode *tutorial      = [SKSpriteNode spriteNodeWithImageNamed:@"Tutorial"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [tutorial setScale:kIpadScaleFactor];
  }
  
  tutorial.position           = CGPointMake((int)self.size.width * 0.5, (int)_playableHeight * 0.35 + _playableStart);
  tutorial.name               = @"Tutorial";
  tutorial.zPosition          = LayerUI;
  
  [_worldNode addChild:tutorial];
  
  SKSpriteNode *ready         = [SKSpriteNode spriteNodeWithImageNamed:@"Ready"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [ready setScale:kIpadScaleFactor];
  }
  
  ready.position              = CGPointMake(self.size.width * 0.5, _playableHeight * 0.8 + _playableStart);
  ready.name                  = @"Tutorial";
  ready.zPosition             = LayerUI;
  
  [_worldNode addChild:ready];
  
}

-(void)setupMainMenu {
  
  
  SKSpriteNode *logo  = [SKSpriteNode spriteNodeWithImageNamed:@"Logo"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [logo setScale:kIpadScaleFactor];
  }
  
  logo.position       = CGPointMake(self.size.width/2, self.size.height * 0.83);
  logo.zPosition      = LayerUI;
  
  [_worldNode addChild:logo];
  
  // Play Button
  SKSpriteNode *playButton    = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [playButton setScale:kIpadScaleFactor];
  }
  
  playButton.position         = CGPointMake(self.size.width * 0.25, self.size.height * 0.15);
  playButton.zPosition        = LayerUI;
  
  [_worldNode addChild:playButton];
  
  SKSpriteNode *play          = [SKSpriteNode spriteNodeWithImageNamed:@"Play"];
  play.position               = CGPointZero;
  
  [playButton addChild:play];
  
  // Rate Button
  SKSpriteNode *rateButton    = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [rateButton setScale:kIpadScaleFactor];
  }
  
  rateButton.position         = CGPointMake(self.size.width * 0.75, self.size.height * 0.15);
  rateButton.zPosition        = LayerUI;
  
  
  [_worldNode addChild:rateButton];
  
  SKSpriteNode *rate          = [SKSpriteNode spriteNodeWithImageNamed:@"Rate"];
  rate.position               = CGPointZero;
  rate.zPosition              = LayerUI;
  
  [rateButton addChild:rate];
}

-(void)setupPlayerAnimation {
  
  NSMutableArray *textures = [NSMutableArray array];
  
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    if ([self iPhone6Plus]) {
      
      for (int  i = 0; i < kNumTurtleFrames; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Turtle%02d-667",i];
        [textures addObject:[atlas textureNamed:textureName]];
      }
      
      for (int i = kNumTurtleFrames - 2; i > 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Turtle%02d-667",i];
        [textures addObject:[atlas textureNamed:textureName]];
      }
      
    } else if ([self iPhone6]) {
      
      for (int  i = 0; i < kNumTurtleFrames; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Turtle%02d-667",i];
        [textures addObject:[atlas textureNamed:textureName]];
      }
      
      for (int i = kNumTurtleFrames - 2; i > 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Turtle%02d-667",i];
        [textures addObject:[atlas textureNamed:textureName]];
      }
      
    } else {
      
      
      for (int  i = 0; i < kNumTurtleFrames; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Turtle%02d",i];
        [textures addObject:[atlas textureNamed:textureName]];
      }
      
      for (int i = kNumTurtleFrames - 2; i > 0; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Turtle%02d",i];
        [textures addObject:[atlas textureNamed:textureName]];
      }
      
    }
  } else {
    for (int  i = 0; i < kNumTurtleFrames; i++) {
      NSString *textureName = [NSString stringWithFormat:@"Turtle%02d",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
    
    for (int i = kNumTurtleFrames - 2; i > 0; i--) {
      NSString *textureName = [NSString stringWithFormat:@"Turtle%02d",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
  }
  
  SKAction *playerAnimation = [SKAction animateWithTextures:textures
                                               timePerFrame:0.04];
  [_player runAction:[SKAction repeatActionForever:playerAnimation]];
  
}

-(void)setupTopObstacleAnimation {
  
  NSMutableArray *textures = [NSMutableArray array];
  
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    for (int i = 0; i < kNumJellyFishFrames; i++) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
    
    for (int i = kNumJellyFishFrames - 1; i > 0; i--) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    for (int i = 0; i < kNumJellyFishFrames; i++) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d-ipad",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
    
    for (int i = kNumJellyFishFrames - 1; i > 0; i--) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d-ipad",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
  }
  
  SKAction *topObstacleAnimation = [SKAction animateWithTextures:textures
                                                    timePerFrame:0.04];
  [_topObstacle runAction:[SKAction repeatActionForever:topObstacleAnimation]
                  withKey:@"topObstacleAnimation"];
  
}

#pragma mark - Gameplay

-(SKSpriteNode *)createBottomObstacle {
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    _bottomObstacle  = [SKSpriteNode spriteNodeWithImageNamed:@"SeaPlants"];
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _bottomObstacle = [SKSpriteNode spriteNodeWithImageNamed:@"SeaPlants-ipad"];
  }
  
  _bottomObstacle.userData         = [NSMutableDictionary dictionary];
  _bottomObstacle.zPosition        = LayerObstacle;
  
  CGFloat offsetX         = _bottomObstacle.frame.size.width * _bottomObstacle.anchorPoint.x;
  CGFloat offsetY         = _bottomObstacle.frame.size.height * _bottomObstacle.anchorPoint.y;
  
  CGMutablePathRef path   = CGPathCreateMutable();
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
    CGPathMoveToPoint(path, NULL, -4 - offsetX, 9 - offsetY);
    CGPathAddLineToPoint(path, NULL, 26 - offsetX, -2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 54 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 52 - offsetX, 21 - offsetY);
    CGPathAddLineToPoint(path, NULL, 56 - offsetX, 70 - offsetY);
    CGPathAddLineToPoint(path, NULL, 52 - offsetX, 153 - offsetY);
    CGPathAddLineToPoint(path, NULL, 67 - offsetX, 215 - offsetY);
    CGPathAddLineToPoint(path, NULL, 49 - offsetX, 312 - offsetY);
    CGPathAddLineToPoint(path, NULL, 30 - offsetX, 303 - offsetY);
    CGPathAddLineToPoint(path, NULL, 15 - offsetX, 288 - offsetY);
    CGPathAddLineToPoint(path, NULL, 14 - offsetX, 195 - offsetY);
    CGPathAddLineToPoint(path, NULL, 2 - offsetX, 152 - offsetY);
    CGPathAddLineToPoint(path, NULL, 9 - offsetX, 82 - offsetY);
    CGPathAddLineToPoint(path, NULL, 9 - offsetX, 34 - offsetY);
    
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, -1 - offsetX, 18 - offsetY);
    CGPathAddLineToPoint(path, NULL, 12 - offsetX, 35 - offsetY);
    CGPathAddLineToPoint(path, NULL, 9 - offsetX, 54 - offsetY);
    CGPathAddLineToPoint(path, NULL, 21 - offsetX, 84 - offsetY);
    CGPathAddLineToPoint(path, NULL, 10 - offsetX, 169 - offsetY);
    CGPathAddLineToPoint(path, NULL, -5 - offsetX, 228 - offsetY);
    CGPathAddLineToPoint(path, NULL, 22 - offsetX, 271 - offsetY);
    CGPathAddLineToPoint(path, NULL, 22 - offsetX, 397 - offsetY);
    CGPathAddLineToPoint(path, NULL, 26 - offsetX, 443 - offsetY);
    CGPathAddLineToPoint(path, NULL, 53 - offsetX, 464 - offsetY);
    CGPathAddLineToPoint(path, NULL, 77 - offsetX, 470 - offsetY);
    CGPathAddLineToPoint(path, NULL, 82 - offsetX, 343 - offsetY);
    CGPathAddLineToPoint(path, NULL, 103 - offsetX, 327 - offsetY);
    CGPathAddLineToPoint(path, NULL, 99 - offsetX, 315 - offsetY);
    CGPathAddLineToPoint(path, NULL, 80 - offsetX, 306 - offsetY);
    CGPathAddLineToPoint(path, NULL, 71 - offsetX, 243 - offsetY);
    CGPathAddLineToPoint(path, NULL, 78 - offsetX, 227 - offsetY);
    CGPathAddLineToPoint(path, NULL, 69 - offsetX, 212 - offsetY);
    CGPathAddLineToPoint(path, NULL, 70 - offsetX, 181 - offsetY);
    CGPathAddLineToPoint(path, NULL, 83 - offsetX, 134 - offsetY);
    CGPathAddLineToPoint(path, NULL, 81 - offsetX, 74 - offsetY);
    CGPathAddLineToPoint(path, NULL, 72 - offsetX, 41 - offsetY);
    CGPathAddLineToPoint(path, NULL, 87 - offsetX, 13 - offsetY);
    CGPathAddLineToPoint(path, NULL, 69 - offsetX, 1 - offsetY);
  }
  
  CGPathCloseSubpath(path);
  
  _bottomObstacle.physicsBody.usesPreciseCollisionDetection = YES;
  _bottomObstacle.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [_bottomObstacle skt_attachDebugFrameFromPath:path color:[UIColor redColor]];
  
  _bottomObstacle.physicsBody.categoryBitMask      = EntityCategoryObstacle;
  _bottomObstacle.physicsBody.collisionBitMask     = 0;
  _bottomObstacle.physicsBody.contactTestBitMask   = EntityCategoryPlayer;
  
  return _bottomObstacle;
}

-(SKSpriteNode *)CreateTopObstacle {
  
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    _topObstacle = [SKSpriteNode spriteNodeWithImageNamed:@"JellyFish00"];
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _topObstacle = [SKSpriteNode spriteNodeWithImageNamed:@"JellyFish00-ipad"];
  }
  
  _topObstacle.userData         = [NSMutableDictionary dictionary];
  _topObstacle.zPosition        = LayerObstacle;
  
  CGFloat offsetX         = _topObstacle.frame.size.width * _topObstacle.anchorPoint.x;
  CGFloat offsetY         = _topObstacle.frame.size.height * _topObstacle.anchorPoint.y;
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
    CGPathMoveToPoint(path, NULL, 5 - offsetX, 7 - offsetY);
    CGPathAddLineToPoint(path, NULL, 3 - offsetX, 60 - offsetY);
    CGPathAddLineToPoint(path, NULL, 12 - offsetX, 94 - offsetY);
    CGPathAddLineToPoint(path, NULL, 3 - offsetX, 140 - offsetY);
    CGPathAddLineToPoint(path, NULL, 10 - offsetX, 200 - offsetY);
    CGPathAddLineToPoint(path, NULL, 20 - offsetX, 200 - offsetY);
    CGPathAddLineToPoint(path, NULL, 26 - offsetX, 200 - offsetY);
    CGPathAddLineToPoint(path, NULL, 26 - offsetX, 200 - offsetY);
    CGPathAddLineToPoint(path, NULL, 65 - offsetX, 132 - offsetY);
    CGPathAddLineToPoint(path, NULL, 62 - offsetX, 109 - offsetY);
    CGPathAddLineToPoint(path, NULL, 64 - offsetX, 91 - offsetY);
    CGPathAddLineToPoint(path, NULL, 62 - offsetX, 91 - offsetY);
    CGPathAddLineToPoint(path, NULL, 60 - offsetX, 50 - offsetY);
    CGPathAddLineToPoint(path, NULL, 30 - offsetX, 50 - offsetY);
    CGPathAddLineToPoint(path, NULL, 37 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 29 - offsetX, 3 - offsetY);
    CGPathAddLineToPoint(path, NULL, 17 - offsetX, 3 - offsetY);
    
    
    
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
    CGPathMoveToPoint(path, NULL, 4 - offsetX, 328 - offsetY);
    CGPathAddLineToPoint(path, NULL, 21 - offsetX, 353 - offsetY);
    CGPathAddLineToPoint(path, NULL, 39 - offsetX, 356 - offsetY);
    CGPathAddLineToPoint(path, NULL, 61 - offsetX, 348 - offsetY);
    CGPathAddLineToPoint(path, NULL, 74 - offsetX, 327 - offsetY);
    CGPathAddLineToPoint(path, NULL, 75 - offsetX, 312 - offsetY);
    CGPathAddLineToPoint(path, NULL, 65 - offsetX, 287 - offsetY);
    CGPathAddLineToPoint(path, NULL, 95 - offsetX, 257 - offsetY);
    CGPathAddLineToPoint(path, NULL, 115 - offsetX, 240 - offsetY);
    CGPathAddLineToPoint(path, NULL, 121 - offsetX, 219 - offsetY);
    CGPathAddLineToPoint(path, NULL, 118 - offsetX, 189 - offsetY);
    CGPathAddLineToPoint(path, NULL, 114 - offsetX, 148 - offsetY);
    CGPathAddLineToPoint(path, NULL, 121 - offsetX, 115 - offsetY);
    CGPathAddLineToPoint(path, NULL, 119 - offsetX, 103 - offsetY);
    CGPathAddLineToPoint(path, NULL, 105 - offsetX, 87 - offsetY);
    CGPathAddLineToPoint(path, NULL, 80 - offsetX, 87 - offsetY);
    CGPathAddLineToPoint(path, NULL, 66 - offsetX, 28 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 8 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 7 - offsetY);
    CGPathAddLineToPoint(path, NULL, 10 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 3 - offsetX, 146 - offsetY);
    CGPathAddLineToPoint(path, NULL, 6 - offsetX, 166 - offsetY);
    CGPathAddLineToPoint(path, NULL, 21 - offsetX, 174 - offsetY);
    
    
    
  }
  
  CGPathCloseSubpath(path);
  
  _topObstacle.physicsBody  = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [_topObstacle skt_attachDebugFrameFromPath:path color:[UIColor redColor]];
  
  _topObstacle.physicsBody.usesPreciseCollisionDetection = YES;
  _topObstacle.physicsBody.categoryBitMask      = EntityCategoryObstacle;
  _topObstacle.physicsBody.collisionBitMask     = 0;
  _topObstacle.physicsBody.contactTestBitMask   = EntityCategoryPlayer;
  
  NSMutableArray *textures = [NSMutableArray array];
  
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    for (int i = 0; i < kNumJellyFishFrames; i++) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
    
    for (int i = kNumJellyFishFrames - 2; i > 0; i--) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    for (int i = 0; i < kNumJellyFishFrames; i++) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d-ipad",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }
    
    for (int i = kNumJellyFishFrames - 2; i > 0; i--) {
      NSString *textureName = [NSString stringWithFormat:@"JellyFish%02d-ipad",i];
      [textures addObject:[atlas textureNamed:textureName]];
    }    }
  
  SKAction *topObstacleAnimation = [SKAction animateWithTextures:textures
                                                    timePerFrame:0.04];
  [_topObstacle runAction:[SKAction repeatActionForever:topObstacleAnimation]];
  
  
  return _topObstacle;
  
}

-(void)spawnObstacle {
  
  float bottomObstacleMin = 0;
  float bottomObstacleMax = 0;
  
  SKSpriteNode *bottomObstacle    = [self createBottomObstacle];
  bottomObstacle.name             = @"BottomObstacle";
  
  // Off screen and half the width of the obstacle
  float startX                    = self.size.width + bottomObstacle.size.width/2;
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
    if ([self iPhone6Plus] || [self iPhone6]) {
      bottomObstacleMin         = (_playableStart - bottomObstacle.size.height/2) +
      _playableHeight * kBottomObstacleMinFractionIphone6plus;
      bottomObstacleMax         = (_playableStart - bottomObstacle.size.height/2) +
      _playableHeight * kBottomObstacleMaxFractionIphone6plus;
      
      [bottomObstacle setScale:1.10];
      
    }else {
      
      bottomObstacleMin         = (_playableStart - bottomObstacle.size.height/2) +
      _playableHeight * kBottomObstacleMinFraction;
      bottomObstacleMax         = (_playableStart - bottomObstacle.size.height/2) +
      _playableHeight * kBottomObstacleMaxFraction;
    }
    
    
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
    bottomObstacleMin      = (_playableStart - bottomObstacle.size.height/2) +
    _playableHeight * kBottomObstacleMinFractionIpad;
    bottomObstacleMax      = (_playableStart - bottomObstacle.size.height/2) +
    _playableHeight * kBottomObstacleMaxFractionIpad;
    
  }
  
  bottomObstacle.position         = CGPointMake(startX,
                                                RandomFloatRange(bottomObstacleMin,
                                                                 bottomObstacleMax));
  
  [_worldNode addChild:bottomObstacle];
  
  
  SKSpriteNode *topObstacle       = [self CreateTopObstacle];
  topObstacle.name                = @"TopObstacle";
  topObstacle.position            = CGPointMake(startX, bottomObstacle.position.y +
                                                bottomObstacle.size.height/2 +
                                                topObstacle.size.height/2 +
                                                _player.size.height * kGapMultiplier);
  
  if ([self iPhone6Plus] || [self iPhone6]) {
    [topObstacle setScale:1.10];
  }
  
  [_worldNode addChild:topObstacle];
  
  // Let's Make the Obstacle Move
  float moveX             = self.size.width + topObstacle.size.width;
  float moveDuration      = moveX / kGroundSpeed;
  SKAction *sequence      = [SKAction sequence:@[
                                                 [SKAction moveByX:-moveX y:0 duration:moveDuration],
                                                 [SKAction removeFromParent]
                                                 ]];
  [topObstacle runAction:sequence];
  [bottomObstacle runAction:sequence];
}

-(void)startSpawning {
  
  SKAction *firstDelay        = [SKAction waitForDuration:kFirstSpawnDelay];
  SKAction *spawn             = [SKAction performSelector:@selector(spawnObstacle) onTarget:self];
  SKAction *everyDelay        = [SKAction waitForDuration:kEverySpawnDelay];
  SKAction *spawnSequence     = [SKAction sequence:@[spawn,everyDelay]];
  SKAction *foreverSpawn      = [SKAction repeatActionForever:spawnSequence];
  SKAction *overallSequence   = [SKAction sequence:@[firstDelay,foreverSpawn]];
  
  [self runAction:overallSequence withKey:@"Spawn"];
}

-(void)stopSpawning {
  
  [self removeActionForKey:@"Spawn"];
  [_worldNode enumerateChildNodesWithName:@"TopObstacle"
                               usingBlock:^(SKNode *node, BOOL *stop) {
                                 [node removeAllActions];
                               }];
  [_worldNode enumerateChildNodesWithName:@"BottomObstacle"
                               usingBlock:^(SKNode *node, BOOL *stop) {
                                 [node removeAllActions];
                               }];
}



-(void)flapPlayer {
  
  // Play Sound
  [self runAction:_flapAction];
  
  // Apply impulse
  _playerVelocity         = CGPointMake(0, kImpulse);
  _playerAngularVelocity  = DegreesToRadians(kAngularVelocity);
  _lastTouchTime          = _lastUpdateTime;
  _lastTouchY             = _player.position.y;
  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self];
  
  switch (_gameState) {
    case GameStateMainMenu:
      if (touchLocation.x > self.size.width * 0.56 && touchLocation.y < self.size.height * 0.20) {
        [self rateApp];
      } else if(touchLocation.x < self.size.width * 0.48 && touchLocation.y < self.size.height * 0.20){
        [self switchToNewGame:GameStateTutorial];
      }
      break;
    case GameStateTutorial:
      [self switchToPlay];
      break;
    case GameStatePlay:
      [self flapPlayer];
      break;
    case GameStateFalling:
      break;
    case GameStateShowingScore:
      break;
    case GameStateGameOver:
      if (touchLocation.x > self.size.width * 0.068  &&
          touchLocation.x < self.size.width * 0.45  &&
          touchLocation.y > self.size.height * 0.19 &&
          touchLocation.y < self.size.height * 0.28) {
        [self switchToNewGame:GameStateMainMenu];
        
      } else if(touchLocation.x > self.size.width * 0.569  &&
                touchLocation.x < self.size.width * 0.947  &&
                touchLocation.y > self.size.height * 0.19 &&
                touchLocation.y < self.size.height * 0.28){
        [self shareScore];
        
      } else if (touchLocation.x > self.size.width * 0.068  &&
                 touchLocation.x < self.size.width * 0.45   &&
                 touchLocation.y > self.size.height * 0.01 &&
                 touchLocation.y < self.size.height * 0.17){
        [[GameKitHelper sharedGameKitHelper]
         showGKGameCenterViewController:self.view.window.rootViewController
         forViewState:GKGameCenterViewControllerStateAchievements];
        
      } else if (touchLocation.x > self.size.width * 0.569   &&
                 touchLocation.x < self.size.width * 0.947   &&
                 touchLocation.y > self.size.height * 0.01 &&
                 touchLocation.y < self.size.height * 0.17){
        [[GameKitHelper sharedGameKitHelper]
         showGKGameCenterViewController:self.view.window.rootViewController
         forViewState:GKGameCenterViewControllerStateLeaderboards];
        
      }
      break;
  }
  
}

#pragma mark - Switch State

-(void)switchToMainMenu {
  
  _gameState = GameStateMainMenu;
  [self setupBackground];
  [self setupForeground];
  [self setupPlayer];
  [self setupPlayerAnimation];
  [self setupSounds];
  [self setupMainMenu];
  
  // Turn iAd banners on.
  [self.sceneDelegate displayBannerAds:YES];
  
  // [_player removeAllActions];  //DONLY
}

-(void)switchToShowScore {
  
  _gameState = GameStateShowingScore;
  
  [_player removeAllActions];
  [self stopSpawning];
  
  [self setupScoreCard];
  
}

-(void)switchToFalling {
  
  _gameState = GameStateFalling;
  
  // Screen shake
  
  SKAction *shake = [SKAction skt_screenShakeWithNode:_worldNode amount:CGPointMake(0, 7.0) oscillations:10 duration:1.0];
  [_worldNode runAction:shake];
  
  // Flash
  SKSpriteNode *whiteNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:self.size];
  whiteNode.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
  whiteNode.zPosition = LayerFlash;
  [_worldNode addChild:whiteNode];
  [whiteNode runAction:[SKAction sequence:@[
                                            [SKAction waitForDuration:0.01],
                                            [SKAction removeFromParent]
                                            ]]];
  
  // Transition code...
  [self runAction:[SKAction sequence:@[
                                       _whackAction,
                                       [SKAction waitForDuration:0.1],
                                       _fallingAction
                                       ]]];
  
  [_player removeAllActions];
  [self stopSpawning];
  
}

-(void)switchToNewGame:(GameState)state {
  
  [self runAction:_popAction];
  
  SKScene *newScene          = [[MyScene alloc] initWithSize:self.size
                                               sceneDelegate:self.sceneDelegate
                                                       state:state];
  
  SKTransition *transition    = [SKTransition fadeWithColor:[SKColor blackColor] duration:0.5];
  
  [self.view presentScene:newScene transition:transition];
  
  // Restart iAd's
  [self.sceneDelegate displayBannerAds:YES];
  
}

-(void)switchToGameOver {
  _gameState = GameStateGameOver;
  
  // Start iAd's
  [self.sceneDelegate displayBannerAds:YES];
  
}

-(void)switchToTutorial {
  
  _gameState  = GameStateTutorial;
  
  [self setupBackground];
  [self setupForeground];
  [self setupPlayer];
  [self setupPlayerAnimation];
  [self setupSounds];
  [self setupScoreLabel];
  [self setupTutorial];
}

-(void)switchToPlay {
  
  _gameState  = GameStatePlay;
  
  // Remove iAds during Game Play
  [self.sceneDelegate displayBannerAds:NO];
  
  // Remove Tutorial
  [_worldNode enumerateChildNodesWithName:@"Tutorial" usingBlock:^(SKNode *node, BOOL *stop) {
    [node runAction:[SKAction sequence:@[
                                         [SKAction fadeOutWithDuration:0.5],
                                         [SKAction removeFromParent]
                                         ]]];
  }];
  
  // Remove wobble
  [_player removeActionForKey:@"Wobble"];
  
  // Start Spawing
  [self startSpawning];
  
  // Stop wobble
  [_player removeActionForKey:@"Wobble"];
  
  // Move Player
  [self flapPlayer];
  
  
}

#pragma mark - Special

-(void)shareScore {
  
  // iAD off - for screen capture and sharing
  [self.sceneDelegate displayBannerAds:NO];
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  // Save Score
  [prefs setInteger:_score forKey:@"currentScore"];
  [prefs setInteger:APP_STORE_ID forKey:@"AppId"];
  
  // This is suggested to synch prefs
  [prefs synchronize];
  
  [SKAction waitForDuration:2.0];
  
  NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%d?mt=8",APP_STORE_ID];
  
  NSURL *url  = [NSURL URLWithString:urlString];
  
  UIImage *screenshot = [self.sceneDelegate screenshot];
  
  NSString *initialTextString = [NSString stringWithFormat:@"I scored %d points in Flappy Turtle: "
                                 "Aquarium Adventure!! \n\nI challenge you to beat my score!! \n \n"
                                 "Download the app from the link below: \n", _score];
  
  [self.sceneDelegate shareString:initialTextString score:_score url:url image:screenshot];
  
  // iAD On
  [self.sceneDelegate displayBannerAds:YES];
}

-(void)rateApp {
  
  NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%d?mt=8",APP_STORE_ID];
  NSURL *url          = [NSURL URLWithString:urlString];
  
  [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Updates

-(void)checkHitGround {
  
  if (_hitGround) {
    _hitGround = NO;
    
    _playerVelocity     = CGPointZero;
    _player.zRotation   = DegreesToRadians(-110);
    _player.position    = CGPointMake(_player.position.x,_playableStart + _player.size.width/2);
    
    [self runAction:_hitGroundAction];
    [self switchToShowScore];
  }
}

-(void)checkHitObstacle {
  
  if (_hitObstacle) {
    _hitObstacle = NO;
    [self switchToFalling];
  }
}

-(void)updatePlayer {
  
  // Apply gravity
  CGPoint gravity = CGPointMake(0, kGravity);
  CGPoint gravityStep = CGPointMultiplyScalar(gravity,_dt);
  _playerVelocity = CGPointAdd(_playerVelocity, gravityStep);
  
  // Apply velocity
  CGPoint velocityStep = CGPointMultiplyScalar(_playerVelocity, _dt);
  _player.position = CGPointAdd(_player.position, velocityStep);
  _player.position = CGPointMake(_player.position.x, MIN(_player.position.y, self.size.height));
  
  if (_player.position.y < _lastTouchY) {
    _playerAngularVelocity = -DegreesToRadians(kAngularVelocity);
  }
  
  // Rotate player
  float angularStep = _playerAngularVelocity * _dt;
  _player.zRotation += angularStep;
  _player.zRotation = MIN(MAX(_player.zRotation, DegreesToRadians(kMinDegrees)),
                          DegreesToRadians(kMaxDegrees));
}

-(void)updateScore {
  
  [_worldNode enumerateChildNodesWithName:@"BottomObstacle" usingBlock:^(SKNode *node, BOOL *stop) {
    SKSpriteNode *obstacle  = (SKSpriteNode *)node;
    
    NSNumber *passed        = obstacle.userData[@"Passed"];
    
    // If already passed obstacle before just return
    if (passed && passed.boolValue) {
      return;
    }
    
    // If obstacle is passed and hasn't been passed before
    if (_player.position.x > obstacle.position.x + obstacle.size.width/2) {
      _score++;
      _scoreLabel.text = [NSString stringWithFormat:@"%d",_score];
      _scoreLabelOutline.text = _scoreLabel.text;
      
      // Play sound effect
      [self runAction:_coinAction];
      obstacle.userData[@"Passed"] = @YES;
      
    }
  }];
  
}

-(void)updateDifficultyLevel {
  
  if (_score < 10) {
    kGapMultiplier      =     1.80;
    kGravity            =   -550.0;
    kImpulse            =    250.0;
    kAngularVelocity    =    100;
    kEverySpawnDelay    =     3.50;
  } else if (_score < 20) {
    kGroundSpeed        =   175.0f;
    kEverySpawnDelay    =     1.75;
  } else if (_score < 30) {
    kGroundSpeed        =   120.0f;
    kEverySpawnDelay    =     2.75;
    kGravity            =  -550.0;
    kImpulse            =   250.0;
  } else if (_score < 40) {
    kImpulse            =   250.0;
    kAngularVelocity    =   200;
    kGroundSpeed        =   140.0f;
    kGapMultiplier      =     1.80;
  } else if (_score < 50) {
    kImpulse            =   300.0;
    kGravity            =   -800.0;
    kAngularVelocity    =   120;
    kGroundSpeed        =   150.0f;
    kEverySpawnDelay    =   1.65;
    
  }else if (_score < 60) {
    kGroundSpeed        =   200.0f;
    kEverySpawnDelay    =     1.50;
    kImpulse            =   300.0;
    kGravity            =  -550.0;
    kAngularVelocity    =   110;
  }
}

-(void)updateForeground {
  
  [_worldNode enumerateChildNodesWithName:@"Foreground" usingBlock:^(SKNode *node, BOOL *stop) {
    SKSpriteNode *foreground    = (SKSpriteNode *)node;
    CGPoint moveAmt             = CGPointMake(-kGroundSpeed * _dt, 0);
    foreground.position         = CGPointAdd(foreground.position, moveAmt);
    
    if (foreground.position.x < -foreground.size.width) {
      foreground.position     = CGPointAdd(foreground.position,
                                           CGPointMake(foreground.size.width * kNumForegrounds, 0));
    }
  }];
}

-(void)updateBackground {
  
  [_worldNode enumerateChildNodesWithName:@"Background" usingBlock:^(SKNode *node, BOOL *stop) {
    SKSpriteNode *bg            = (SKSpriteNode *)node;
    CGPoint bgVelocity          = CGPointMake(-kGroundSpeed * 0.15, 0);
    CGPoint moveAmt             = CGPointMultiplyScalar(bgVelocity, _dt);
    bg.anchorPoint              = CGPointMake(0.5, 1);
    bg.position                 = CGPointAdd(bg.position, moveAmt);
    
    if (bg.position.x < -bg.size.width * 0.5) {
      bg.position             = CGPointAdd(bg.position,
                                           CGPointMake(bg.size.width * kNumBackgrounds, 0));
    }
  }];
}


#pragma mark - Update Loop

-(void)update:(CFTimeInterval)currentTime {
  // return;  // DONLY
  
  if (self.paused) {
    _dt = 0;
    _lastUpdateTime = currentTime;
    return;
  }
  
  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
    _lastUpdateTime = currentTime;
    
    if (_dt > 1) {
      _dt = 1.0 / 60.0;    // 0.016 = approx. 1/60 of a second
      _lastUpdateTime = currentTime;
    }
  }else {
    _dt = 0;
  }
  
  
  switch (_gameState) {
    case GameStateMainMenu:
      break;
    case GameStateTutorial:
      break;
    case GameStatePlay:
      [self updateForeground];
      [self updateBackground];
      [self checkHitGround];
      [self updatePlayer];
      [self checkHitObstacle];
      [self updateScore];
      [self updateDifficultyLevel];
      [self reportAchievementsForGameState];
      break;
    case GameStateFalling:
      [self updatePlayer];
      [self checkHitGround];
      break;
    case GameStateShowingScore:
      break;
    case GameStateGameOver:
      [AchievementsHelper resetAchievementPointsCounter];
      [self reportScoreToGameCenter];
      break;
    default:
      break;
  }
  
}

#pragma mark - Score

-(int)bestScore {
  
  return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
}

-(void)setBestScore:(int)bestScore {
  
  [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:@"BestScore"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Collision Detection

-(void)didBeginContact:(SKPhysicsContact *)contact {
  SKPhysicsBody *other    = (contact.bodyA.categoryBitMask == EntityCategoryPlayer ? contact.bodyB : contact.bodyA);
  
  if (other.categoryBitMask == EntityCategoryGround) {
    _hitGround = YES;
    return;
  }
  if (other.categoryBitMask == EntityCategoryObstacle) {
    _hitObstacle = YES;
    return;
  }
}

#pragma mark - Game Center

-(void)reportAchievementsForGameState
{
  NSMutableArray *achievements = [NSMutableArray array];
  
  [achievements addObject:[AchievementsHelper achievementEarned:_score]];
  
  [[GameKitHelper sharedGameKitHelper]
   reportAchievements:achievements];
  
}

- (void)reportScoreToGameCenter
{
  int64_t reportBestScore = (int64_t)[self bestScore];
  [[GameKitHelper sharedGameKitHelper]
   reportScore:reportBestScore
   forLeaderboardID:kLeaderboardID];
}

@end
