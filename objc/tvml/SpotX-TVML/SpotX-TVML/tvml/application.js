//# sourceURL=application.js

/*
 application.js
 SpotX-TVML
 
 Copyright (c) 2016 SpotX. All rights reserved.
*/

/*
 * This file provides an example skeletal stub for the server-side implementation 
 * of a TVML application.
 *
 * A javascript file such as this should be provided at the tvBootURL that is 
 * configured in the AppDelegate of the TVML application. Note that  the various 
 * javascript functions here are referenced by name in the AppDelegate. This skeletal 
 * implementation shows the basic entry points that you will want to handle 
 * application lifecycle events.
 */

/**
 * @description The onLaunch callback is invoked after the application JavaScript 
 * has been parsed into a JavaScript context. The handler is passed an object 
 * that contains options passed in for launch. These options are defined in the
 * swift or objective-c client code. Options can be used to communicate to
 * your JavaScript code that data and as well as state information, like if the 
 * the app is being launched in the background.
 *
 * The location attribute is automatically added to the object and represents 
 * the URL that was used to retrieve the application JavaScript.
 */

var BASEURL = "";

App.onLaunch = function (options) {
    console.log(options);
    console.log(options.BASEURL);

    BASEURL = options.BASEURL;

    // display the Ad player setup 
    evaluateScripts([`${BASEURL}/templates/player.xml.js`], function () {
        var document = createPlayerTemplate(BASEURL);
        navigationDocument.pushDocument(document);
    });
}


App.onWillResignActive = function () {

}

App.onDidEnterBackground = function () {

}

App.onWillEnterForeground = function () {

}

App.onDidBecomeActive = function () {

}

App.onWillTerminate = function () {

}

var createAlert = function (title, description) {
    var alertString = `<?xml version="1.0" encoding="UTF-8" ?>
        <document>
        <alertTemplate>
        <title>${title}</title>
        <description>${description}</description>
        </alertTemplate>
        </document>`
    var parser = new DOMParser();
    var alertDoc = parser.parseFromString(alertString, "application/xml");
    return alertDoc;
}

function spotxPlayAd(channelId, player, playerParams, eventCallback) {
    // load the SpotX SDK TVOS script
    var url = 'https://m.spotx.tv/tvos/v2/sdk.js';
    evaluateScripts([url], function (success) {
        if (success) {
            var AD_EVENTS = [
                "AdLoaded", "AdStarted", "AdStopped", "AdSkipped", "AdImpression",
                "AdVideoStart", "AdVideoFirstQuartile", "AdVideoMidpoint",
                "AdVideoThirdQuartile", "AdVideoComplete",
                "AdUserClose", "AdPaused", "AdPlaying", "AdError"
            ];

            // specify any additional parameters to send with the SpotX Ad request
            var params = { 'secure' : '1' };

            // request the Ad from SpotX, using the channelId
            SpotX.load(channelId, params, function (err, adPlayer) {
                if (err) {
                    // an error has occurred while making the Ad request
                    var errMsg = 'Channel ID: ' + channelId + ' - ' +
                        (typeof (err) == 'string' ? err : 'Load Ad Failed');
                    var alert = createAlert("SpotX SDK Ad Load Error", errMsg);
                    navigationDocument.presentModal(alert);
                    return;
                }

                // attach listeners to Ad events
                AD_EVENTS.forEach(function (event) {
                    adPlayer.addEventListener(event, function () {
                        console.log("Ad Event = " + event);
                        if (null != eventCallback) {
                            eventCallback(event);
                        }
                    });
                });

                if (player) {
                    // video specified
                    switch (playerParams.type) {
                        case "insertnext":
                            // insert the ad after some delay
                            setTimeout(function () {
                                adPlayer.insertNext(player);
                            }, playerParams.delay_secs * 1000);
                            break;
                        case "postroll":    // postroll ad (after video)
                            adPlayer.postRoll(player);
                            break;
                        case "midroll":     // midroll ad (insert between)
                            adPlayer.midRoll(player, playerParams.offset);
                            break;
                        case "preroll":     // preroll ad (before video)
                        default:
                            adPlayer.preRoll(player);
                            break;
                    }
                }
                else {
                    // no video specified, just play the Ad as a standalone video
                    player = adPlayer.standalone();
                }

                // ignore user scrubbing requests
                player.addEventListener("requestSeekToTime", (event) => {return false;});
                player.addEventListener("shouldHandleStateChange", (event) => {return false;});
                
                // play the video(s)
                player.play();
            });
        }
        else {
            var alert = createAlert("SpotX SDK Load Error",
                "A problem occurred while attempting to load the SpotX SDK for TVOS.\n\nPlease try again later.");
            navigationDocument.presentModal(alert);
        }
    });
}

