//
//  Copyright © 2016 SpotX. All rights reserved.
//

#import "MainViewController.h"
#import "StitchedAdViewController.h"

@import SpotX;

@interface MainViewController () <SPXAdControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *channelIdTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *playbackTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *delaySecondsTextField;

- (IBAction)playSplicedAdTriggered:(UIButton *)sender;
- (IBAction)playStitchedAdTriggered:(UIButton *)sender;

@end

@implementation MainViewController {
  AVPlayerViewController * _playerController;
  SPXAdController * _controller;
}

@synthesize channelIdTextField;
@synthesize playbackTypeSegmentedControl;
@synthesize delaySecondsTextField;

- (void)viewDidLoad {
  [super viewDidLoad];

  _playerController = [[AVPlayerViewController alloc] init];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSArray<AVPlayerItem *> *)getPlayerItems {
  NSMutableArray<AVPlayerItem *> * playerItems = [[NSMutableArray<AVPlayerItem *> alloc] init];
  [playerItems addObject:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://spotxchange-a.akamaihd.net/media/videos/orig/d/3/d35ba3e292f811e5b08c1680da020d5a.mp4"]]];
  [playerItems addObject:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://spotxchange-a.akamaihd.net/media/videos/orig/3/0/30ccd08292f911e5bbd81680da020d5a.mp4"]]];
  return playerItems;
}

- (NSArray<AVPlayerItem *> *)getPlayerItem {
  NSMutableArray<AVPlayerItem *> * playerItems = [[NSMutableArray<AVPlayerItem *> alloc] init];
  [playerItems addObject:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://spotxchange-a.akamaihd.net/media/videos/orig/d/3/d35ba3e292f811e5b08c1680da020d5a.mp4"]]];
  return playerItems;
}

/**
 Handle playing an Ad "spliced" (preroll, midroll, or postroll) into existing video segments
 **/
- (IBAction)playSplicedAdTriggered:(UIButton *)sender {
  // create the avplayer used to display the video and video ad
  NSArray<AVPlayerItem *> * items = [self getPlayerItems];
  AVQueuePlayer * player = [[AVQueuePlayer alloc] initWithItems:items];
  _playerController.player = player;

  NSString * channelId = self.channelIdTextField.text;

  /**
   *  specify any parameters you might want to pass on in the request to SpotX
   *  i.e. for podding:
   *  SpotXParams * spotxParams = @{@"pod[size]":@"3", @"pod[max_pod_dur]":@"900", @"pod[max_ad_dur]":@"300"};
   */
  SpotXParams * spotxParams = @{};

  // request the ad from SpotX using the channel id
  [SpotX adForChannel:channelId params:spotxParams completion:^(SPXAdController *ad, NSError *error) {
    // we have an ad response
    if (error) {
      // an error occurred
      NSLog(@"SpotX Ad Request Error: %@", error);
    }
    else if (ad) {

      // !!NOTE: You *MUST* retain a reference to the SPXAdController instance,
      // otherwise it will be immediately deallocated and the delegate events
      // will not fire.
      _controller = ad;

      // set the delegate on the controller to listen to ad events
      ad.delegate = self;

      // place the ad into the playlist (preroll, midroll, or postroll)
      switch (playbackTypeSegmentedControl.selectedSegmentIndex) {
        case 2: // postroll ad
          [ad postRoll:player];
          break;
        case 1: // midroll ad
          // inserting the ad between the first and second video
          [ad midRoll:player offset:1];
          break;
        case 0: // preroll ad
        default:
          [ad preRoll:player];
          break;
      }
    }
    // present the player view controller
    // !!NOTE: even if there are no ads, we still want to play the publisher's videos
    [self presentViewController:_playerController animated:YES completion:^{
      // player view controller has been presented, play it
      [_playerController.player play];
    }];
    
    // !!NOTE: This observer provides a mechanism to dismiss the AVPlayer when all videos are complete
    // This is not required for the SDK, and is included for demo purposes.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player.items lastObject]];
  }];
}

/**
 Handle playing an Ad "stitched" into existing long form video
 **/
- (IBAction)playStitchedAdTriggered:(UIButton *)sender {
  // create the StitchedAdViewController, which will handle the presentation of the Ad stitched into a video

  int delay = MAX([delaySecondsTextField.text intValue], 0);

  StitchedAdViewController * viewController = [[StitchedAdViewController alloc] init];
  viewController.channelId = channelIdTextField.text;
  viewController.delay = delay;

  [self presentViewController:viewController animated:YES completion:nil];
}

// MARK: - SPXAdControllerDelegate methods

- (void)adControllerAdDidStart:(SPXAdController *)adController {
  // Ad has started playback - prevent scrubbing
  if (_playerController) {
    _playerController.requiresLinearPlayback = YES;
  }
}

- (void)adControllerPlayNextAd:(SPXAdController *)adController {
  if (_playerController) {
    _playerController.requiresLinearPlayback = YES;
  }
}

- (void)adControllerAdDidFinish:(SPXAdController *)adController {
  // Ad has completed playback - allow scrubbing
  if (_playerController) {
    _playerController.requiresLinearPlayback = NO;
  }
  _controller = nil;
}

- (void)adController:(SPXAdController *)adController adDidFailWithError:(NSError *)error {
  // Ad has completed playback (with an error) - allow scrubbing
  if (_playerController) {
    _playerController.requiresLinearPlayback = NO;
  }
  _controller = nil;
}

/*
 Present Ad View Controller (Interactive Ad ONLY)
 */
- (void)presentAdViewController:(UIViewController *)viewControllerToPresent {
  // Present the Interactive Ad

  [_playerController presentViewController:viewControllerToPresent animated:YES completion:nil];
}

/*
 Dismiss Ad View Controller (Interactive Ad ONLY)
 */
- (void)dismissAdViewController:(UIViewController *)viewControllerToDismiss {
  // Dismiss the Interactive Ad

  // check to see if the view controller has already been dismissed
  if (viewControllerToDismiss) {
    // dismiss the current view controller
    [_playerController dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
  [_playerController dismissViewControllerAnimated:YES completion:nil];
}
@end
