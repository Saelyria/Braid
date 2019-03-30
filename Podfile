platform :ios, '9.0'

workspace 'Braid'

target 'BraidExample' do
  project 'BraidExample'
  use_frameworks!
  
  pod 'Braid/Rx', :path => '.'
#  pod 'Braid', :path => '.'
  pod 'RxCocoa', '~> 4'
  pod 'RxSwift', '~> 4'
end

target 'BraidExampleTests' do
    project 'BraidExample'
    use_frameworks!
    
    pod 'Braid/Rx', :path => '.'
    #  pod 'Braid', :path => '.'
    pod 'RxCocoa', '~> 4'
    pod 'RxSwift', '~> 4'
    pod 'Nimble', '~> 8'
end
