//
//  Copyright © 2017 SpotX. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface StitchedAdViewController : AVPlayerViewController

@property (nonatomic, strong) NSString * channelId;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSInteger adCount;

@end
