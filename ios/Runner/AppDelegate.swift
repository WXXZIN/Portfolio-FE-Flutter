import UIKit
import Flutter
import NaverThirdPartyLogin

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        NaverThirdPartyLoginConnection.getSharedInstance()?.isNaverAppOauthEnable = true
        NaverThirdPartyLoginConnection.getSharedInstance()?.isInAppOauthEnable = true
        
        let thirdConn = NaverThirdPartyLoginConnection.getSharedInstance()
        
        // 네이버 앱으로 인증하는 방식 활성화
        thirdConn?.isNaverAppOauthEnable = true
        
        // SafariViewController에서 인증하는 방식 활성화
        thirdConn?.isInAppOauthEnable = true
        
        // 서비스 파라미터 설정
        thirdConn?.isOnlyPortraitSupportedInIphone()
        
        thirdConn?.serviceUrlScheme = kServiceAppUrlScheme
        thirdConn?.consumerKey = kConsumerKey
        thirdConn?.consumerSecret = kConsumerSecret
        thirdConn?.appName = kServiceAppName
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var applicationResult = false
        if (!applicationResult) {
           applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
        }
        // if you use other application url process, please add code here.
        
        if (!applicationResult) {
           applicationResult = super.application(app, open: url, options: options)
        }
        return applicationResult
    }
}
