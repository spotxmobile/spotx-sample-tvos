//
//  Copyright © 2016 SpotX. All rights reserved.
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

- (void)viewDidLoad {
  [super viewDidLoad];

  NSURL * videoUrl = [NSURL URLWithString:@"https://spotxchange-a.akamaihd.net/media/videos/orig/d/3/d35ba3e292f811e5b08c1680da020d5a.mp4"];

  self.player = [[AVPlayer alloc] initWithURL:videoUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

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

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  // clean up the observer, if any
  if (_observer) {
    [self.player removeTimeObserver:_observer];
    _observer = nil;
  }
}

- (void)loadAndPlayAd {
  // specify any parameters you might want to pass on in the request to SpotX
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
      [self performSelectorOnMainThread:@selector(playAd:) withObject:ad waitUntilDone:NO];
    }
  }];
}

- (void)playAd:(SPXAdController *)ad {

  // get the current item being played
  AVPlayerItem *content = self.player.currentItem;

  // play the Ad immediately
  ad.delegate = self;
  [ad play:self.player completion:^{
    // Ad playback complete, reset the player position back to where we left off before the Ad
    [self.player seekToTime:content.currentTime completionHandler:^(BOOL finished) {
      // restart the player
      [self.player play];
    }];
  }];

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

/*
 Present Ad View Controller (Interactive Ad ONLY)
 */
- (void)presentAdViewController:(UIViewController *)viewControllerToPresent {
  // Present the Interactive Ad

  [self presentViewController:viewControllerToPresent animated:YES completion:nil];
}

/*
 Dismiss Ad View Controller (Interactive Ad ONLY)
 */
- (void)dismissAdViewController:(UIViewController *)viewControllerToDismiss {
  // Dismiss the Interactive Ad

  // check to see if the view controller has already been dismissed
  if (viewControllerToDismiss) {
    // dismiss the current view controller
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end