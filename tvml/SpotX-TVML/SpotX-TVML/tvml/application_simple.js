
App.onLaunch = function (options) {
  // load the SpotX SDK
  var url = 'https://m.spotx.tv/tvos/v2/sdk.js';
  evaluateScripts([url], function (success) {
    if (success) {
      // load and play the ad
      loadAndPlay();
    }
    else {
      console.log("Error loading SpotX TVML SDK");
    }
  });
}

function loadAndPlay() {
  // specify any additional parameters to send with the SpotX Ad request
  var params = { 'secure' : '1' };
  // request the Ad from SpotX, using the channelId 
  SpotX.load("85394", params, function (err, adPlayer) {
    if (err) {
      // an error occurred
      console.log("Failed to load ad");
    }
    else {
      // play the ad without an existing player (standalone player mode)
      var player = adPlayer.standalone();
      player.play();
    }
  });
}

