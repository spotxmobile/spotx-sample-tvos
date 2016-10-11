//
//  Copyright © 2015 SpotX, Inc. All rights reserved.
//
var createPlayerTemplate = function (BASEURL) {
  var template = `<?xml version="1.0" encoding="UTF-8" ?>
    <document>
     <head>
        <style>
          .settingsValues {
            tv-highlight-color: rgba((0, 0, 0, 0.6);
          }
          .subtitle {
            font-size: 10px;
          }
        </style>
      </head>
      <listTemplate>
        <banner>
          <row>
            <text style="font-size: 72px;">SpotX TVML Code Sample</text>
          </row>
        </banner>    
        <list>
          <section>
            <header>
              <title>Player Configuration</title>
            </header>
            <listItemLockup action="selectChannel">
              <title>Select Channel</title>
              <decorationLabel id="selectedChannel" class="settingsValues">85394</decorationLabel>
              <relatedContent>
                <lockup>
                  <img src="${BASEURL}images/SPOTX_logo.png" width="757" height="482" />
                </lockup>
              </relatedContent>
            </listItemLockup>
            <listItemLockup action="selectVideoBefore">
              <title>Video Before Ad</title>
              <decorationLabel id="selectedVideoBefore" class="settingsValues"></decorationLabel>
              <relatedContent>
                <lockup>
                  <img src="${BASEURL}images/SPOTX_logo.png" width="757" height="482" />
                </lockup>
              </relatedContent>
            </listItemLockup>
            <listItemLockup id="itemAdNext" action="selectAdNext" style="height:0">
              <title>Insert Next Ad</title>
              <decorationLabel id="selectedAdNext" class="settingsValues"></decorationLabel>
              <relatedContent>
                <lockup>
                  <img src="${BASEURL}images/SPOTX_logo.png" width="757" height="482" />
                </lockup>
              </relatedContent>
            </listItemLockup>
            <listItemLockup action="selectVideoAfter" style="display: none;">
              <title>Video After Ad</title>
              <decorationLabel id="selectedVideoAfter" class="settingsValues"></decorationLabel>
              <relatedContent>
                <lockup>
                  <img src="${BASEURL}images/SPOTX_logo.png" width="757" height="482" />
                </lockup>
              </relatedContent>
            </listItemLockup>
          </section>
          <section>
            <header>
               <title>Run With these Settings</title>
            </header>
            <listItemLockup action="playNow">
              <title>Play Now!</title>
              <subtitle id="playType" class="subtitle" style="font-size: 8pt; tv-text-style: subtitle2;">* Ad Only</subtitle>
              <relatedContent>
                <lockup>
                  <img src="${BASEURL}images/SPOTX_logo.png" width="757" height="482" />
                </lockup>
              </relatedContent>
            </listItemLockup>
          </section>
        </list>
      </listTemplate>
    </document>`;


  var parser = new DOMParser();
  var document = parser.parseFromString(template, "application/xml");

  Loaded.call(this, document);

  document.addEventListener("select", ActionHandler.bind(this));
  //document.addEventListener("highlight", ActionHandler.bind(this));

  return document;
}

var Loaded = function (document) {
  document.channel = { index: 0, list: ["85394", "129737", "131660", "131664", "131665"] };
  document.video = {
    before: 0, after: 0, list: [
      { title: "NONE", url: "" },
      { title: "Big Buck Bunny", url: "https://spotxchange-a.akamaihd.net/media/videos/orig/d/3/d35ba3e292f811e5b08c1680da020d5a.mp4" },
      { title: "Cosmos Laundromat", url: "https://spotxchange-a.akamaihd.net/media/videos/orig/e/f/ef70d1ba92f811e5ba6c106b23389c4d.mp4" },
      { title: "Elephant's Dream", url: "https://spotxchange-a.akamaihd.net/media/videos/orig/e/b/eb2d7f5e92f811e59ea0106b23389c4d.mp4" },
      { title: "Monkaa", url: "https://spotxchange-a.akamaihd.net/media/videos/orig/3/0/30ccd08292f911e5bbd81680da020d5a.mp4" },
      { title: "Sintel Test MP4", url: "https://spotxchange-a.akamaihd.net/media/videos/orig/9/a/9a5e4c9c92d411e59ef119e233f970be.mp4" }
    ]
  };
  document.next = {
    index: 0, disabled: "N/A", list: [
      { title: "Immediately", sec: 0 },
      { title: "After 5 Secs", sec: 5 }
    ]
  };

  document.setText = function (id, text) {
    var element = this.getElementById(id);
    if (null != element) {
      element.innerHTML = text;
    }
  }

  document.setText("selectedChannel", document.channel.list[document.channel.index]);
  document.setText("selectedVideoBefore", document.video.list[document.video.before].title);
  document.setText("selectedVideoAfter", document.video.list[document.video.after].title);
  document.setText("selectedAdNext", document.next.disabled);

  setTimeout(function () {
    var itemAdNext = document.getElementById("itemAdNext");
    itemAdNext.setAttribute("disabled", true);
  }, 500);
}

var ActionHandler = function (event) {
  var document = event.target.ownerDocument,
      element = event.target,
      action = element.getAttribute("action"),
      data = element.getAttribute("data");

  function _next(index, length) {
    return ((index + 1) >= length) ? 0 : (index + 1);
  }

  function _updatePlayType() {
    var itemAdNext = document.getElementById("itemAdNext");
    var disabled = ((0 == document.video.before) || (0 != document.video.after));
    itemAdNext.setAttribute("disabled", disabled);
    var type = "* ";
    if (document.video.before > 0 && document.video.after > 0) {
      type += "Midroll Ad";
    }
    else if (document.video.before > 0) {
      var delay = document.next.list[document.next.index].sec;
      if (0 == delay) {
        type += "Postroll Ad";
      }
      else {
        var insertType = document.next.list[document.next.index].title;
        type += "Insert Ad Next (" + insertType + ")";
      }
    }
    else if (document.video.after > 0) {
      type += "Preroll Ad";
    }
    else {
      type += "Ad Only";
    }

    document.setText("playType", type);

    if (disabled) {
      document.setText("selectedAdNext", document.next.disabled);
    }
    else {
      document.setText("selectedAdNext", document.next.list[document.next.index].title);
    }
  }

  switch (action) {
    case "selectChannel":
      document.channel.index = _next(document.channel.index, document.channel.list.length);
      document.setText("selectedChannel", document.channel.list[document.channel.index]);
      return true;

    case "selectVideoBefore":
      document.video.before = _next(document.video.before, document.video.list.length);
      document.setText("selectedVideoBefore", document.video.list[document.video.before].title);
      _updatePlayType();
      return true;

    case "selectAdNext":
      document.next.index = _next(document.next.index, document.next.list.length);
      document.setText("selectedAdNext", document.next.list[document.next.index].title);
      _updatePlayType();
      return true;

    case "selectVideoAfter":
      document.video.after = _next(document.video.after, document.video.list.length);
      document.setText("selectedVideoAfter", document.video.list[document.video.after].title);
      _updatePlayType();
      return true;

    case "playNow":
      var channel = document.channel.list[document.channel.index];
      var playlist = new Playlist();
      var beforeVideo = null;
      if (document.video.before > 0) {
        beforeVideo = new MediaItem("video", document.video.list[document.video.before].url);
        playlist.push(beforeVideo);
      }
      var afterVideo = null;
      if (document.video.after > 0) {
        afterVideo = new MediaItem("video", document.video.list[document.video.after].url);
        playlist.push(afterVideo);
      }

      var player = null;
      var playParams = { type: "normal", offset: 0, delay_secs: 0 };
      if (beforeVideo && afterVideo) {
        playParams.type = "midroll";
        playParams.offset = 1;
      }
      else if (beforeVideo) {
        playParams.type = "postroll";
        var delay = document.next.list[document.next.index].sec;
        if (delay > 0) {
          playParams.type = "insertnext";
          playParams.delay_secs = delay;
        }
      }
      else if (afterVideo) {
        playParams.type = "preroll";
      }

      if (playlist.length > 0) {
        player = new Player();
        player.playlist = playlist;
      }

      spotxPlayAd(channel, player, playParams);

      return true;
  }

  return false;
}

