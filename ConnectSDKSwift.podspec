Pod::Spec.new do |s|
  s.name         = "ConnectSDKSwift"
  s.version      = "1.0.1"
  s.summary      = "Connect SDK is an open source framework connecting apps with multiple TV platforms."
  s.description  = <<-DESC
Connect SDK is an open source framework that connects your mobile apps with multiple TV platforms. 
It integrates discovery and connectivity for all supported protocols and platforms.
DESC

  s.homepage     = "http://www.connectsdk.com/"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author       = { "Connect SDK" => "support@connectsdk.com" }
  s.platform     = :ios, "11.0"
  s.ios.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/Farhan-Maqsood/ConnectSDKSwift.git", :tag => s.version }

  s.xcconfig = { "OTHER_LDFLAGS" => "$(inherited) -ObjC" }
  s.requires_arc = true
  s.libraries = "z", "icucore"
  s.prefix_header_contents = <<-PREFIX
#define CONNECT_SDK_VERSION @"#{s.version}"
#ifdef CONNECT_SDK_ENABLE_LOG
  #ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
  #else
    #define DLog(...)
  #endif
#else
  #define DLog(...)
#endif
  PREFIX

  non_arc_files = [
    "core/Frameworks/asi-http-request/External/Reachability/*.{h,m}",
    "core/Frameworks/asi-http-request/Classes/*.{h,m}"
  ]

  # Core + FireTV
  s.subspec 'Core' do |sp|
    sp.source_files  = "ConnectSDKDefaultPlatforms.h", "core/**/*.{h,m}", "modules/firetv/**/*.{h,m}"
    sp.exclude_files = (non_arc_files + ["core/ConnectSDK*Tests/**/*", "core/Frameworks/LGCast/**/*.h"])
    sp.private_header_files = "core/**/*_Private.h"
    sp.requires_arc = true

    sp.dependency 'ConnectSDKSwift/no-arc'
    sp.ios.vendored_frameworks = [
  'core/Frameworks/LGCast/LGCast.xcframework',
  'core/Frameworks/LGCast/GStreamerForLGCast.xcframework'
]
sp.preserve_paths = [
  'core/Frameworks/LGCast/LGCast.xcframework',
  'core/Frameworks/LGCast/GStreamerForLGCast.xcframework'
]

  end

  # No ARC
  s.subspec 'no-arc' do |sp|
    sp.source_files = non_arc_files
    sp.requires_arc = false
    sp.compiler_flags = '-w'
  end

  # GoogleCast (official CocoaPod)
  s.subspec 'GoogleCast' do |sp|
    cast_dir = "modules/google-cast"
    sp.dependency 'ConnectSDKSwift/Core'
    sp.source_files = "#{cast_dir}/**/*.{h,m}"
    sp.exclude_files = "#{cast_dir}/*Tests/**/*"
    sp.private_header_files = "#{cast_dir}/**/*_Private.h"
    sp.dependency "google-cast-sdk", "2.7.1"
    sp.framework = "GoogleCast"
    sp.xcconfig = {
      "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/google-cast-sdk/GoogleCastSDK-2.7.1-Release",
    }
  end
end
