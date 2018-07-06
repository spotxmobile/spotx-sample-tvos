	import SpotX

class StitchedAdViewController: AVPlayerViewController, SPXAdControllerDelegate {
  var channelId = ""
  var delay: TimeInterval = 0.0
  var adCount: Int = 0
  
  private var observer: Any?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadAndPlayAd()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if observer != nil {
      if let anObserver = observer {
        player?.removeTimeObserver(anObserver)
      }
      observer = nil
    }
  }
  
  /**
   * NOTE: This method uses adCount to play a preroll, a midroll, and a postroll advertisement.
   * In a typical integration, you would likely only use one of the three.
   * This method works in conjunction with the playerItemDidReachEnd method,
   * which continues playback after preroll and midroll, and after the postroll ad completes,
   * dismisses the adview.
   */
  func loadAndPlayAd() {
    let spotxParams = [String:String]()
    let channelId = self.channelId
    SpotX.ad(forChannel: channelId, params: spotxParams) { ad, error in
      if error != nil {
        if let anError = error {
          print("SpotX Ad Request Error: \(anError)")
        }
      } else if ad != nil {
        switch self.adCount {
        case 0:
          self.performSelector(onMainThread: #selector(StitchedAdViewController.playAdStandalone(_:)), with: ad, waitUntilDone: false)
        case 1:
          self.performSelector(onMainThread: #selector(StitchedAdViewController.playAd(_:)), with: ad, waitUntilDone: false)
        case 2:
          self.performSelector(onMainThread: #selector(StitchedAdViewController.playAdStandalone(_:)), with: ad, waitUntilDone: false)
        default:
          self.performSelector(onMainThread: #selector(StitchedAdViewController.playAdStandalone(_:)), with: ad, waitUntilDone: false)
        }
      }
    }
  }
  
  // This method is used to play a standalone placement (preroll, or postroll).
  @objc func playAdStandalone(_ ad: SPXAdController?) {
    ad?.delegate = self
    // During ad playback, we want to disable playback controls
    showsPlaybackControls = false
    requiresLinearPlayback = true
    player = ad?.standalone()
    let content: AVPlayerItem? = player?.currentItem
    player?.play()
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: content)
    view.setNeedsLayout()
    view.setNeedsDisplay()
  }
  
  // This method is used to play a midroll placement.
  func loadAndPlayContentWithMidroll() {
    // Sample video - placeholder for publisiher video content
    let videoUrl = URL(string: "https://spotxchange-a.akamaihd.net/media/videos/orig/e/f/ef70d1ba92f811e5ba6c106b23389c4d.mp4")
    player = nil
    if let anUrl = videoUrl {
      player = AVPlayer(url: anUrl)
    }
    weak var weakSelf = self
    observer = player?.addBoundaryTimeObserver(forTimes: [delay as NSValue], queue: DispatchQueue.main, using: {
      weakSelf?.player?.removeTimeObserver(self.observer!)
      self.observer = nil
      weakSelf?.loadAndPlayAd()
    })
    player?.play()
  }
  
  // This function plays an ad if one is returned.
  @objc func playAd(_ ad: SPXAdController?) {
    let content: AVPlayerItem? = player?.currentItem
    ad?.delegate = self
    // During ad playback, we want to disable playback controls
    showsPlaybackControls = false
    requiresLinearPlayback = true
    ad?.play(player) {
      if let aTime = content?.currentTime() {
        self.player?.seek(to: aTime, completionHandler: { finished in
          // When the ad completes, re-enable playback controls
          self.showsPlaybackControls = true
          self.requiresLinearPlayback = false
          self.player?.play()
        })
      }
    }
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: content)
    view.setNeedsLayout()
    view.setNeedsDisplay()
  }


  // MARK: SPXAdControllerDelegate methods
  
  func presentAdViewController(_ viewControllerToPresent: UIViewController!) {
    //
  }
  
  func adControllerPlayNextAd(_ adController: SPXAdController!) {
    //
  }
  
  func adController(_ adController: SPXAdController!, adDidFailWithError error: Error!) {
    //
  }
  
  func adControllerAdDidStart(_ adController: SPXAdController?) {
    requiresLinearPlayback = true
  }
  
  func adControllerAdDidFinish(_ adController: SPXAdController?) {
    requiresLinearPlayback = false
  }
  
  func adController(_ adController: SPXAdController?) throws {
    requiresLinearPlayback = false
  }
  
  /**
   * This function is typically only used to dismiss the ad view.
   * However, since this demo app shows preroll, midroll, and postroll placements,
   * this method has been modified to continue playback of content/ads until the postroll ad
   * has been played. Once the postroll is played, the view is finally dismissed.
   */
  @objc func playerItemDidReachEnd(_ notification: Notification?) {
    adCount += 1
    switch adCount {
    case 1:
      loadAndPlayContentWithMidroll()
    case 2:
      loadAndPlayAd()
    default:
      dismiss(animated: true)
    }
  }
}

