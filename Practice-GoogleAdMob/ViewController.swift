//
//  ViewController.swift
//  Practice-GoogleAdMob
//
//  Created by 河村大介 on 2021/03/22.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        interstitial = loadInterstitialAd()
        interstitial.delegate = self
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
      }
        
        
    
    @IBAction func showAd(_ sender: Any) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    
    @IBAction func showNativeAd(_ sender: Any) {
        
    }
    
    // 広告オブジェクトの生成とロード
    fileprivate func loadInterstitialAd() -> GADInterstitial {
        let interstitial = GADInterstitial.init(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }


    // 広告を表示
    fileprivate func showInterstitialAd(){
        guard let _ad = interstitial, _ad.isReady else {
            debugPrint("Interstitial Ad Does NOT Available")
            return
        }
        _ad.present(fromRootViewController: self)
    }

    // 広告を見せた後のスキームの再開
    fileprivate func resumeSuspendedUserScheme(){
        debugPrint("Resume suspended user scheme")
    }

    //MARK: GADInterstitialDelegate
    // 広告リクエストが成功したことをデリゲート(代表者)に通知します。
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      debugPrint("interstitial Did ReceiveAd")
    }

    // 広告リクエストが失敗したことをデリゲート(代表者)に通知します。
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      debugPrint("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    // インタースティシャルが提示されることをデリゲート(代表者)に伝えます。
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      debugPrint("interstitial Will PresentScreen")
    }

    // Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      debugPrint("interstitial Will Dismiss Screen")
    }

    // インタースティシャルを閉じられたことをデリゲート(代理人)に指示します。
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        debugPrint("interstitial Did Dismiss Screen")
        interstitial = loadInterstitialAd()
        resumeSuspendedUserScheme()
    }

    // ユーザーがクリックすると別のアプリが開くことをデリゲート(代理人)に通知します
    //（App Storeなど）、現在のアプリをバックグラウンドで表示します。
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      debugPrint("User Click Ad")
      debugPrint("interstitial Will Leave Application")
    }

}
