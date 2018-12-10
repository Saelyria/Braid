platform :ios, '9.0'

workspace 'Tableau'

target 'TableauExample' do
  project 'TableauExample'
  use_frameworks!
  
  pod 'Tableau/Rx', :path => '.'
#  pod 'Tableau', :path => '.'
  pod 'RxCocoa', '~> 4.4'
  pod 'RxSwift', '~> 4.4'
end

target 'TableauExampleTests' do
    project 'TableauExample'
    use_frameworks!
    
    pod 'Tableau/Rx', :path => '.'
    #  pod 'Tableau', :path => '.'
    pod 'RxCocoa', '~> 4.4'
    pod 'RxSwift', '~> 4.4'
    pod 'Nimble', '~> 7'
end
