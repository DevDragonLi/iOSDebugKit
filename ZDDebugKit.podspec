

Pod::Spec.new do |s|
  s.name             = 'ZDDebugKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of ZDDebugKit.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DevDragonLi/iOSDebugKit'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'DevDragonli' => 'Dragonli_52171@163.com'}
  s.source           = { git:'https://github.com/DevDragonLi/iOSDebugKit.git', tag: s.version.to_s }

  s.ios.deployment_target = '10.0'
  
  s.default_subspec = 'framework'
  
  s.subspec 'source' do |source|
   source.source_files     = "DebugKit/**/*.{h,m}"
   source.public_header_files = ['DebugKit/ZDDebugKit.h','DebugKit/ZDCore/ZDDEBUGMENU.h',
                           'DebugKit/ZDProtocol/*.h']
  end

   s.subspec 'framework' do |framework|
    framework.ios.vendored_frameworks = 'framework/*.framework'
   end

end
