Pod::Spec.new do |s|
  s.name             = 'EHSlideView'
  s.version          = '1.0.0'
  s.summary          = 'a view you can slide between controllers\' view.'
  s.homepage         = 'https://github.com/waterflowseast/EHSlideView'
  s.screenshots      = 'https://github.com/waterflowseast/EHSlideView/raw/master/screenshots/1.png', 'https://github.com/waterflowseast/EHSlideView/raw/master/screenshots/2.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eric Huang' => 'WaterFlowsEast@gmail.com' }
  s.source           = { :git => 'https://github.com/waterflowseast/EHSlideView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'EHSlideView/Classes/**/*'
  s.dependency 'YYCache', '~> 1.0.4'
end
