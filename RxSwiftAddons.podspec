Pod::Spec.new do |s|
s.name             = "RxSwiftAddons"
s.version          = "0.0.1"
s.summary          = "Addons for RxSwift"
s.description      = <<-DESC
This are convenient addons for working with RxSwift
DESC
s.homepage         = "https://github.com/ReactiveX/RxSwift"
s.license          = 'MIT'
s.author           = { "Andrés Cecilia" => "a.cecilia.luque@gmail.com" }
s.source           = { :git => "https://github.com/acecilia/RxSwiftAddons.git", :tag => s.version.to_s }

s.requires_arc          = true

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.10'
s.watchos.deployment_target = '2.0'
s.tvos.deployment_target = '9.0'

s.source_files          = 'Sources/RxSwiftAddons.h', 'Sources/Common/**/*.{swift,h,m}'
s.ios.source_files      = 'Sources/iOS/**/*.swift'
s.osx.source_files      = 'Sources/OSX/**/*.swift'
s.watchos.source_files  = 'Sources/iOS/**/*.swift'
s.tvos.source_files     = 'Sources/iOS/**/*.swift'

s.dependency 'RxSwift', '~> 2.5'
s.dependency 'RxCocoa', '~> 2.5'

end