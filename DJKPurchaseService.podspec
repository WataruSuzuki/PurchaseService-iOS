Pod::Spec.new do |s|

  s.name         = "DJKPurchaseService"
  s.version      = "0.0.23"
  s.summary      = "A short description of DJKPurchaseService."

  s.description  = <<-DESC
                   A longer description of DJKPurchaseService in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/WataruSuzuki"
  s.license      = "MIT License"
  s.author       = { "WataruSuzuki" => "wataru0406@gmail.com" }
  s.source       = { :git => "https://github.com/WataruSuzuki/PurchaseService-iOS.git", :tag => "#{s.version}" }

  s.dependency 'PersonalizedAdConsent'
  s.dependency 'SwiftyStoreKit'
  s.dependency 'PureLayout'
  s.dependency 'TinyConstraints'

  # s.dependency 'Google-Mobile-Ads-SDK'
  s.pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '-framework "GoogleMobileAds"',
      'FRAMEWORK_SEARCH_PATHS' => "$(PODS_ROOT)/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework-Current"
  }
  s.ios.vendored_frameworks = 'Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework-Current/GoogleMobileAds.framework'

  s.platform     = :ios, "9.0"
  s.swift_version = '4.0'
  s.source_files = 'PurchaseService/**/*.{swift}'
  # s.subspec 'ObjC' do |objc|
  #     objc.source_files = 'ObjC/*.{h,m}'
  #     objc.platform     = :ios, "7.0"
  #   end
  # s.subspec 'Swift' do |swift|
  #     swift.source_files = 'Swift/*.{swift}'
  #     swift.platform     = :ios, "8.0"
  #   end
end
