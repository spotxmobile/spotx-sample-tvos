//
//  Copyright © 2016 SpotX, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import TVMLKit;

/**
 *  Project version number for SpotX.
 */
FOUNDATION_EXPORT double SpotXVersionNumber;

/**
 *  Project version string for SpotX.
 */
FOUNDATION_EXPORT const unsigned char SpotXVersionString[];

#import <SpotX/SPXAdController.h>


/**
 *  Dictionary of key-value strings to record additional information.
 */
typedef NSDictionary<NSString*,NSString*> SpotXParams;


/**
 *  Callback block to receive the result of an ad request.
 *
 *  NOTE: If both parameters are nil, no ad was available.
 *
 *  @param adController SPXAdController instance for managing ad placement
 *  @param error NSError object with information regarding the underlying error
 */
typedef void(^SpotXLoadCompletion)(SPXAdController *_Nullable adController, NSError *_Nullable error);


/**
 *  SpotX is the entry point for the SpotX SDK.
 */
@interface SpotX : NSObject


/**
 *  @return Current marketing version
 */
+(nonnull NSString *)version;


/**
 *  Requests an ad for the given channel.
 *
 *  @param channel    Your SpotX channel id
 *  @param params     Dictionary of key-value strings that are recorded along with the ad request.
 *  @param completion Block to be invoked with the result of the ad request.
 */
+ (void)adForChannel:(nonnull NSString *)channel params:(nullable SpotXParams *)params completion:(nonnull SpotXLoadCompletion)completion;


/**
 *  Requests an ad for the given channel.
 *
 *  @param channel    Your SpotX channel id
 *  @param params     Dictionary of key-value strings that are recorded along with the ad request.
 *  @param completion Block to be invoked with the result of the ad request.
 */
+ (void)interactiveAdFromURL:(nonnull NSURL *)adServerURL completion:(nonnull SpotXLoadCompletion)completion;


/**
 *  Creates an ad with the given URL and type.
 *
 *  @param url        URL of the creative
 *  @param type       MIME type of the creative
 *  @param completion Block to be invoked with the created ad
 */
+ (void)createAdWithURL:(nonnull NSURL *)url type:(nonnull NSString *)type completion:(nonnull SpotXLoadCompletion)completion;


/**
 *  Helper method for registering and enabling SpotX interactive ad extensions.
 *
 *  @return The extended interface creator for advanced use cases
 */
+ (nonnull id<TVInterfaceCreating>)setupInteractiveAdExtensions;


/**
 *  @return YES if the interactive ad extensions have been enabled.
 */
+ (BOOL)enableInteractiveAdExtensions;


/**
 *  Indicates that the SpotX interactive ad extensions have been registered.
 *
 *  @param value YES/NO
 */
+ (void)setEnableInteractiveAdExtensions:(BOOL)value;


/**
 *  [[TVInterfaceFactory sharedInterfaceFactory] setExtendedInterfaceCreator:self];
 *
 *  @return 
 */
+ (nonnull id<TVInterfaceCreating>)extendedInterfaceCreator;

@end