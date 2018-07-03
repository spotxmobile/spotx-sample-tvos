//
//  Copyright © 2017 SpotX. All rights reserved.
//

#import "StitchedAdViewController.h"

@import SpotX;

@interface StitchedAdViewController () <SPXAdControllerDelegate>

@end

@implementation StitchedAdViewController {
  id _observer;
}

@synthesize channelId;
@synthesize delay;
@synthesize adCount;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.adCount = 0;
  self.player = [[AVPlayer alloc] init];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self loadAndPlayAd];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  // clean up the observer, if any
  if (_observer) {
    [self.player removeTimeObserver:_observer];
    _observer = nil;
  }
}

- (void)loadAndPlayAd {
  /**
   *  specify any parameters you might want to pass on in the request to SpotX
   *  i.e. for podding:
   *  SpotXParams * spotxParams = @{@"pod[size]":@"3", @"pod[max_pod_dur]":@"900", @"pod[max_ad_dur]":@"300"};
   */
  SpotXParams * spotxParams = @{};
  
  // request the ad from SpotX using the channel id
  [SpotX adForChannel:self.channelId params:spotxParams completion:^(SPXAdController * ad, NSError * error) {
    
    // we have an ad response
    if (error) {
      // an error occurred
      NSLog(@"SpotX Ad Request Error: %@", error);
    }
    else if (ad) {
      // ad is present, play it
      switch(self.adCount) {
        case 0:
          // play preroll as standalone
          [self performSelectorOnMainThread:@selector(playAdStandalone:) withObject:ad waitUntilDone:NO];
          break;
        case 1:
          // play midroll
          [self performSelectorOnMainThread:@selector(playAd:) withObject:ad waitUntilDone:NO];
          break;
        case 2:
          // play postroll as standalone
          [self performSelectorOnMainThread:@selector(playAdStandalone:) withObject:ad waitUntilDone:NO];
          break;
        default:
          [self performSelectorOnMainThread:@selector(playAdStandalone:) withObject:ad waitUntilDone:NO];
          break;
      }
    }
  }];
}

- (void)playAdStandalone:(SPXAdController *)ad {
  
  ad.delegate = self;
  // Disable scrubbing during ad playback
  self.showsPlaybackControls = NO;
  self.requiresLinearPlayback = YES;
  self.player = [ad standalone];
  AVPlayerItem *content = self.player.currentItem;
  [self.player play];
  
  // STANDALONE COMPLETION HANDLER
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:content];
  
  [self.view setNeedsLayout];
  [self.view setNeedsDisplay];
}

- (void)loadAndPlayContentWithMidroll {
  
  NSURL * videoUrl = [NSURL URLWithString:@"https://spotxchange-a.akamaihd.net/media/videos/orig/e/f/ef70d1ba92f811e5ba6c106b23389c4d.mp4"];
  
  self.player = nil;
  self.player = [[AVPlayer alloc] initWithURL:videoUrl];
  
  // observe the video playback and present the ad after the specified delay
  __weak id weakSelf = self;
  _observer = [self.player addBoundaryTimeObserverForTimes:@[@(self.delay)] queue:dispatch_get_main_queue() usingBlock:^{
    // delay timeout completed
    [[weakSelf player] removeTimeObserver:_observer];
    _observer = nil;
    
    // load and present the ad
    [weakSelf loadAndPlayAd];
  }];
  
  [self.player play];
}

- (void)playAd:(SPXAdController *)ad {
  
  // get the current item being played
  AVPlayerItem *content = self.player.currentItem;
  
  // play the Ad immediately
  ad.delegate = self;
  // Disable scrubbing during ad playback
  self.showsPlaybackControls = NO;
  self.requiresLinearPlayback = YES;
  [ad play:self.player completion:^{
    // Ad playback complete, reset the player position back to where we left off before the Ad
    [self.player seekToTime:content.currentTime completionHandler:^(BOOL finished) {
      // Enable scrubbing after ad playback complete
      self.showsPlaybackControls = YES;
      self.requiresLinearPlayback = NO;
      // restart the player
      [self.player play];
    }];
  }];
  
  // MIDROLL COMPLETION HANDLER
  // 1. The publisher video started
  // 2. The midroll ad has been played at the specified duration
  // 3. The publisher video played to completion
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidReachEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:content];
  
  [self.view setNeedsLayout];
  [self.view setNeedsDisplay];
}

// MARK: - SPXAdControllerDelegate methods

- (void)adControllerAdDidStart:(SPXAdController *)adController {
  // Ad has started playback - prevent scrubbing
  self.requiresLinearPlayback = YES;
}

- (void)adControllerAdDidFinish:(SPXAdController *)adController {
  // Ad has completed playback - allow scrubbing
  self.requiresLinearPlayback = NO;
}

- (void)adController:(SPXAdController *)adController adDidFailWithError:(NSError *)error {
  // Ad has completed playback (with an error) - allow scrubbing
  self.requiresLinearPlayback = NO;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
  self.adCount++;
  switch(self.adCount) {
    case 1:
      // MIDROLL
      [self loadAndPlayContentWithMidroll];
      break;
    case 2:
      // POSTROLL
      [self loadAndPlayAd];
      break;
    default:
      // Everything complete, dismiss ViewController
      [self dismissViewControllerAnimated:YES completion:nil];
      break;
  }
}

@end

