//
//  NativeAdViewController.swift
//  Practice-GoogleAdMob
//
//  Created by 河村大介 on 2021/03/24.
//

import UIKit
import GoogleMobileAds

class NativeAdViewController: UIViewController,GADAdLoaderDelegate, GADUnifiedNativeAdDelegate, GADVideoControllerDelegate {
    
    var adLoader: GADAdLoader!
    var nativeAdView: GADUnifiedNativeAdView!
    let adUnitID = "ca-app-pub-3940256099942544/3986624511"
    var heightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var nativeAdPlaceholder: UIView!
    @IBOutlet weak var startMutedSwitch: UISwitch!
    @IBOutlet weak var refreshAdButton: UIButton!
    @IBOutlet weak var videoStatusLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        
        let adLoader = GADAdLoader.init(adUnitID: adUnitID, rootViewController: self, adTypes: [ GADAdLoaderAdType.unifiedNative ], options: [multipleAdsOptions])
        adLoader.delegate = self
        let request = GADRequest()
        adLoader.load(request)
    }
    
    
    // 以下のコードはネイティブアプリの実装に関するもの
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADUnifiedNativeAd) {
        // A unified native ad has loaded, and can be displayed.
        print("Received unified native ad: \(nativeAd)")
        
        let nibView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? GADUnifiedNativeAdView else {
            return
          }
        setAdView(nativeAdView)
        
        
        refreshAdButton.isEnabled = true

        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self

        // Deactivate the height constraint that was set when the previous video ad loaded.
        heightConstraint?.isActive = false

        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        // Some native ads will include a video asset, while others do not. Apps can use the
        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
        // UI accordingly.
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
          // By acting as the delegate to the GADVideoController, this ViewController receives messages
          // about events in the video lifecycle.
          mediaContent.videoController.delegate = self
          videoStatusLabel.text = "Ad contains a video asset."
        } else {
          videoStatusLabel.text = "Ad does not contain a video."
        }

        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
          heightConstraint = NSLayoutConstraint(
            item: mediaView,
            attribute: .height,
            relatedBy: .equal,
            toItem: mediaView,
            attribute: .width,
            multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
            constant: 0)
          heightConstraint?.isActive = true
        }

        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false

        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd

      
        
    }
    
    func setAdView(_ view: GADUnifiedNativeAdView) {
      // Remove the previous ad view.
        nativeAdView = view
        nativeAdPlaceholder.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false

      // Layout constraints for positioning the native ad view to stretch the entire width and height
      // of the nativeAdPlaceholder.
      let viewDictionary = ["_nativeAdView": view]
      self.view.addConstraints(
        NSLayoutConstraint.constraints(
          withVisualFormat: "H:|[_nativeAdView]|",
          options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
      )
      self.view.addConstraints(
        NSLayoutConstraint.constraints(
          withVisualFormat: "V:|[_nativeAdView]|",
          options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
      )
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        refreshAdButton.isEnabled = true
    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad was shown.
    }

    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad was clicked on.
    }

    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad will present a full screen view.
    }

    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad will dismiss a full screen view.
    }

    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad did dismiss a full screen view.
    }

    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad will cause the application to become inactive and
      // open a new application.
    }
    
    @IBAction func refreshAd(_ sender: Any) {
        refreshAdButton.isEnabled = false
        videoStatusLabel.text = ""
        adLoader = GADAdLoader(
          adUnitID: adUnitID, rootViewController: self,
          adTypes: [.unifiedNative], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }

    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
      videoStatusLabel.text = "Video playback has ended."
    }
    
    
}





// MARK: - GADUnifiedNativeAdDelegate implementation
extension ViewController: GADUnifiedNativeAdDelegate {

  func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }
}



