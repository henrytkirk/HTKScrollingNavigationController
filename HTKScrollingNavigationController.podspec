Pod::Spec.new do |s|
  s.name         = "HTKScrollingNavigationController"
  s.version      = "0.0.1"
  s.summary      = "Scrolling navigation controller with slide-up transitions for iOS 7.x"
  s.description  = <<-DESC
                   Scrolling navigation controller for iOS 7.x with slide-up transitions. It uses UICollectionView under the hood and currently supports vertical sliding.
                   DESC
  s.homepage     = "http://www.github.com/henrytkirk/HTKScrollingNavigationController"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Henry T Kirk" => "henrytkirk@gmail.com" }
  s.social_media_url   = "http://twitter.com/henrytkirk"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/henrytkirk/HTKScrollingNavigationController.git", :commit => "fb2efae9236505df0758c81553568ec2791ced5c" }
  s.source_files  = "HTKScrollingNavigationController/*.{h,m}"
  s.requires_arc = true
end
