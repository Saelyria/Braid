Pod::Spec.new do |s|
  s.name             = 'Tableau'
  s.version          = '1.0.0'
  s.summary          = 'Declarative, type-safe table view binding.'
  s.description      = <<-DESC
  Tableau is a table view binding library that makes setup for table views more declarative, more functional, and
  more type-safe.
  DESC

  s.homepage         = 'https://github.com/Saelyria/Tableau'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Bosnjak' => 'aaron.bosnjak707@gmail.com' }
  s.source           = { :git => 'https://github.com/Saelyria/Tableau.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'

  s.ios.deployment_target = '8.0'
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = 'Core/', 'Core/Protocols/', 'Core/TableView/', 'Core/TableView/SingleSection', 'Core/TableView/MultiSection', 'Core/TableView/AnySection', 'Core/Diffing/'
    ss.ios.framework = "UIKit"
  end

  s.subspec "Rx" do |ss|
    ss.source_files = 'Rx/'
    ss.ios.framework = "UIKit"
    ss.dependency 'Tableau/Core'
    ss.dependency 'RxSwift', '~> 4.0'
    ss.dependency 'RxCocoa', '~> 4.0'
    ss.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DRX_TABLEAU', }
  end
end
