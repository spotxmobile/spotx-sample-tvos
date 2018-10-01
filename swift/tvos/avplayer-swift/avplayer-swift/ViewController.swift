import SpotX

class ViewController: UIViewController, SPXAdControllerDelegate {
  
  @IBOutlet private weak var channelIdTextField: UITextField!
  @IBOutlet private weak var playbackTypeSegmentedControl: UISegmentedControl!
  @IBOutlet private weak var delaySecondsTextField: UITextField!
  
  private var playerController: AVPlayerViewController?
  private var controller: SPXAdController?
  
  @IBAction private func playSplicedAdTriggered(_ sender: UIButton) {
    let items = getPlayerItems()
    var player: AVQueuePlayer? = nil
    if let anItems = items {
      player = AVQueuePlayer(items: anItems)
    }
    playerController?.player = player
    let channelId = channelIdTextField.text
    let spotxParams = ["pod[size]": "5", "pod[max_pod_dur]": "1800", "pod[max_ad_dur]": "60"]
    SpotX.ad(forChannel: channelId!, params: spotxParams) { ad, error in
      if error != nil {
        if let anError = error {
          print("error: \(anError)")
        }
      } else if ad != nil {
        self.controller = ad
        ad?.delegate = self
        switch self.playbackTypeSegmentedControl.selectedSegmentIndex {
        case 2:
          ad?.postRoll(player)
        case 1:
          ad?.midRoll(player, offset: 1)
        case 0:
          fallthrough
        default:
          ad?.preRoll(player)
        }
      }
      self.present(self.playerController!, animated: true) {
        self.playerController?.player?.play()
      }
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.items().last)
  }
  
  @IBAction func playStitchedAdTriggered(_ sender: UIButton) {
    var delay: TimeInterval = max(Double(delaySecondsTextField.text!)!, 0)
    let viewController = StitchedAdViewController()
    viewController.channelId = channelIdTextField.text!
    viewController.delay = delay
    present(viewController, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    playerController = AVPlayerViewController()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func getPlayerItems() -> [AVPlayerItem]? {
    var playerItems = [AVPlayerItem]()
    if let aString = URL(string: "https://spotxchange-a.akamaihd.net/media/videos/orig/d/3/d35ba3e292f811e5b08c1680da020d5a.mp4") {
      playerItems.append(AVPlayerItem(url: aString))
    }
    if let aString = URL(string: "https://spotxchange-a.akamaihd.net/media/videos/orig/3/0/30ccd08292f911e5bbd81680da020d5a.mp4") {
      playerItems.append(AVPlayerItem(url: aString))
    }
    return playerItems
  }
  
  func getPlayerItem() -> [AVPlayerItem]? {
    var playerItems = [AVPlayerItem]()
    if let aString = URL(string: "https://spotxchange-a.akamaihd.net/media/videos/orig/d/3/d35ba3e292f811e5b08c1680da020d5a.mp4") {
      playerItems.append(AVPlayerItem(url: aString))
    }
    return playerItems
  }
  
  // MARK: - SPXAdControllerDelegate methods
  
  func adControllerAdDidStart(_ adController: SPXAdController?) {
    if playerController != nil {
      playerController?.requiresLinearPlayback = true
    }
  }
  
  func adControllerPlayNextAd(_ adController: SPXAdController?) {
    if playerController != nil {
      playerController?.requiresLinearPlayback = true
    }
  }
  
  func adControllerAdDidFinish(_ adController: SPXAdController?) {
    if (playerController != nil) {
      playerController?.requiresLinearPlayback = false
    }
    controller = nil
  }
  
  func adController(_ adController: SPXAdController?) throws {
    if (playerController != nil) {
      playerController?.requiresLinearPlayback = false
    }
    controller = nil
  }
  
  func adController(_ adController: SPXAdController!, adDidFailWithError error: Error!) {
    if (playerController != nil) {
      playerController?.requiresLinearPlayback = false
    }
    controller = nil
  }
  
  func presentAdViewController(_ viewControllerToPresent: UIViewController?) {
    if let aPresent = viewControllerToPresent {
      playerController?.present(aPresent, animated: true)
    }
  }
  
  func dismissAdViewController(_ viewControllerToDismiss: UIViewController?) {
    if viewControllerToDismiss != nil {
      playerController?.dismiss(animated: true)
    }
  }
  
  @objc func playerItemDidReachEnd(_ notification: Notification?) {
    playerController?.dismiss(animated: true)
}
}





