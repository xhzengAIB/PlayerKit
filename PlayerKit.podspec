Pod::Spec.new do |s|
  s.name         = "PlayerKit"
  s.version      = "1.0.0"
  s.summary      = ""
  s.homepage     = "https://github.com/xhzengAIB/MessageDisplayKit"
  s.license      = "MIT"
  s.authors      = { "Jack" => "xhzengAIB@gmail.com" }
  s.source       = { :git => "https://github.com/xhzengAIB/PlayerKit.git", :tag => s.version.to_s }
  s.frameworks   = 'AVFoundation'
  s.platform     = :ios, '7.0'
  s.source_files = 'PlayerKit/Classes/**/*.{h,m}'
  s.resources    = 'PlayerKit/Resources/*'
  s.requires_arc = true
end
