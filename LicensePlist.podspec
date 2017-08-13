Pod::Spec.new do |s|
  s.name        = 'LicensePlist'
  s.version     = '1.6.0'
  s.summary     = 'A license list generator of all your dependencies for iOS applications'
  s.homepage    = 'https://github.com/simorgh3196/LicensePlist'
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.author      = 'Masayuki Ono'
  s.source      = { :http => '#{s.homepage}/releases/download/#{s.version}/portable_licenseplist.zip' }
end
