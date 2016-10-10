SpotX SDK for AvPlayer
=========================

The *SpotX SDK for AVPlayer* provides seamless integration with Apple's AVKit framework.

* Ad Preloading
* Flexible Placement Options (pre-/post-/mid-roll, standalone)
* Client-side Ad Stitching
* Access to underlying AVPlayerItem for advanced ad placements

## Prerequisites

  * Xcode 7
  * Add SpotX.framework to your Xcode project
  * A SpotX publisher account
  	* [Apply to become a SpotX Publisher](http://www.spotxchange.com/publishers/apply-to-become-a-spotx-publisher/)


## Requesting an Ad

```swift
import SpotX

static let CHANNEL_ID = "85394"

SpotX.adForChannel(CHANNEL_ID, params:nil completion:{
	(ad:SPXAdController?, error:NSError?) -> void in
  	
	  if let _ = ad {
	    // do something with the ad -- show it now, or save for later
	  }
	  else if let _ = error {
	    // underlying transmission error
	  }
	  else {
	    // no ad was available
	  }
})

```


## Presenting an Ad in a TVML App

  1. Load the SpotX SDK. Don't worry, there are no additional dependencies.
  2. Load up a SpotX Ad with your publisher channel ID.
  3. Add any additional parameters you wish to collect (see below).
  4. Pass a callback to receive the SpotXAdPlayer.
  5. Add event listeners to the player, if you are interested in Ad lifecycle events.
  6. Present the Ad by calling `player.standalone().play()`.


```swift
import SpotX

var player : AVQueuePlayer;
var ad : SPXAdController;

...

// Inserts the ad at the front of the play queue
ad.preRoll(player)

// Appends the ad to end end of the play queue 
ad.postRoll(player)

// Inserts the ad at the third position in the play queue
ad.midRoll(player, 2)

// Client-side Ad Stitching: Plays an ad immediately using the given player.
ad.play(player, completion:{
	// callback invoked when the ad has finished 
	// and the original video content is restored
})
```

## Customizing the Ad Request

You may specify additional parameters to refine your Ad request query with SpotX. The values for the following parameters should adhere to the [OpenRTB API Specification 2.2](http://www.iab.com/wp-content/uploads/2015/06/OpenRTBAPISpecificationVersion2_2.pdf).


|Parameter                    | Description |
|-----------------------------|-------------|
|app[name]                    | Application name (may be masked at publisher’s request). |
|app[domain]                  | Domain of the application (e.g.,“mygame.foo.com”). |
|app[cat]                     | Array of IAB content categories for the overall application. |
|app[ver]                     | Application version. |
|app[privacypolicy]           | Specifies whether the app has a privacy policy. “1” means there is a policy and “0” means there is not. |
|app[storeurl]                | For QAG 1.5 compliance, an app store URL for an installed app should be passed in the bid request. |
|app[content][language]       | Language of the content. Use alpha-2/ISO 639-1 codes. |
|app[content][contentrating]  | Content rating (e.g., MPAA) |
|device[dnt]                  | If “0”, then do not track Is set to false, if “1”, then do no track is set to true in browser. |
|device[geo][lon]             | Longitude from -180 to 180. West is negative. This should only be passed if known to be accurate. |
|device[geo][lat]             | Latitude from -90 to 90. South is negative. This should only be passed if known to be accurate |

**NOTE:** Additional parameters (sometimes referred to as custom taxonomy) may be provided and will be stored along with your ad request.

#### Example

```swift
let params = [
  "app[ver]": "1.0",
  "my_custom_param": "my_custom_value"
]

SpotX adForChannel(CHANNEL_ID, params:params completion:{
	(ad:SPXAdController?, error:NSError?) -> void in
	  //...
})
```