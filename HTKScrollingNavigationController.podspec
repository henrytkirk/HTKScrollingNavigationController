Pod::Spec.new do |s|
  s.name         = "HTKScrollingNavigationController"
  s.version      = "0.0.3"
  s.summary      = "Scrolling navigation controller with slide-up transitions for iOS 7.x"
  s.description  = <<-DESC
                   Scrolling navigation controller for iOS 7.x with slide-up transitions. It uses UICollectionView under the hood and currently supports vertical sliding.
                   DESC
  s.homepage     = "http://www.github.com/henrytkirk/HTKScrollingNavigationController"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Henry T Kirk" => "henrytkirk@gmail.com" }
  s.social_media_url   = "http://twitter.com/henrytkirk"
  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/henrytkirk/HTKScrollingNavigationController.git", :tag => "v0.0.2" }
  s.source_files  = "HTKScrollingNavigationController/*.{h,m}"
  s.requires_arc = true
end
