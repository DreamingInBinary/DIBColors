Pod::Spec.new do |s|
  s.name         = "DIBColors"
  s.version      = "0.0.1"
  s.summary      = "Add a color picker to your app with one line of code."
  s.description  = "Add a color picker with pre filled color schemes to your app. Requires no auto layout or frame manipulation."
  s.homepage     = "https://github.com/DreamingInBinary/DIBColors.git"
  s.screenshots  = "https://github.com/DreamingInBinary/DIBColors/blob/master/demo.gif?raw=true"
  s.requires_arc = true
  s.license      = "MIT"
  s.author             = { "Jordan Morgan" => "jordan@dreaminginbinary.co" }
  s.social_media_url   = "http://twitter.com/JordanMorgan10"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/DreamingInBinary/DIBColors.git", :tag => "0.0.1" }
  s.source_files = 'DIBColors.{h,m}'
  s.framework = "UIKit"
end
