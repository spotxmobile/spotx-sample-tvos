//
//  Copyright © 2016 SpotX, Inc. All rights reserved.
//
@import Foundation;
@import AVKit;


@protocol SPXAdControllerDelegate;


/**
 * SPXAdController manages inserting an ad and tracks its status during playback.
 * For convenience, a number of placements are supported directly. For more complicated
 * ad placements, the underlying AVPlayerItem is available.
 *
 * NOTE: If you choose to place the AVPlayerItem in a player manually, you must pass
 * that player to -attachToPlayer:.
 */
@interface SPXAdController : NSObject

/**
 * Delegate to be notified of ad controller events.
 */
@property (nonatomic, weak) id<SPXAdControllerDelegate> delegate;

/**
 * Underlying AVPlayerItem for the ad content.
 */
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;


#pragma mark - Placements

/**
 *  Places the ad as the first item in the given player.
 *
 *  @param player AVPlayer to update
 */
- (void)preRoll:(AVQueuePlayer *)player;

/**
 *  Places the ad as the last item in the given player.
 *
 *  @param player AVPlayer to update
 */
- (void)postRoll:(AVQueuePlayer *)player;

/**
 *  Places the ad at the specified offset in the given player.
 *
 *  @param player AVPlayer to be updated
 *  @param offset Zero-based index at which to insert the ad
 */
- (void)midRoll:(AVQueuePlayer *)player offset:(NSInteger)offset;

/**
 *  Inserts the ad as the next item in the given player.
 *
 *  @param player AVPlayer to update
 */
- (void)insertNext:(AVQueuePlayer *)player;

/**
 *  Plays the ad immediately in the given player. When the ad is complete 
 *  the original playerItem is restored.
 *
 *  @param player     AVPlayer to update
 *  @param completion Block to be invoked when the ad is complete and the 
 *                    original content restored.
 */
- (void)play:(AVPlayer *)player completion:(void (^)())completion;

/**
 *  Creates a new AVPlayer that plays only this ad.
 *
 *  @return AVPlayer
 */
- (AVPlayer *)standalone;

/**
 *  Registers event listeners necessary for playback tracking on the given player.
 *
 *  @param player AVPlayer to observe
 */
- (void)attachToPlayer:(AVPlayer *)player;


@property (nonatomic, readonly) BOOL isInteractive;

@end


/**
 *  Delegate protocol for ad controller events.
 */
@protocol SPXAdControllerDelegate <NSObject>

@required

- (void)presentAdViewController:(UIViewController *)viewControllerToPresent;

/**
 *  Sent after the ad has started playback.
 *
 *  @param adController SPXAdController whose content is playing
 */
- (void)adControllerAdDidStart:(SPXAdController *)adController;

/**
 *  Sent after the ad has finished playback.
 *
 *  @param adController SPXAdController whose content is playing
 */
- (void)adControllerAdDidFinish:(SPXAdController *)adController;

/**
 *  Sent after the ad has finished playback as the result of an error.
 *
 *  @param adController SPXAdController whose content is playing
 */
- (void)adController:(SPXAdController *)adController adDidFailWithError:(NSError *)error;

@end