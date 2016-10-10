//
//  Copyright © 2016 SpotX. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface StitchedAdViewController : AVPlayerViewController

@property (nonatomic, strong) NSString * channelId;
@property (nonatomic, assign) NSTimeInterval delay;

@end
