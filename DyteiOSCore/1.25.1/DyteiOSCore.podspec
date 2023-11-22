Pod::Spec.new do |spec|
    spec.name                     = 'DyteiOSCore'
    spec.version                  = '1.25.1'
    spec.homepage                 = 'https://dyte.io'
    spec.source                   = { 
                                      :http => 'https://dyte-assets.s3.ap-south-1.amazonaws.com/sdk/ios_core/DyteiOSCore-1.25.1-3cd7450e-5ee2-4e9b-adab-f3ece296f594.xcframework.zip',
                                      :type => 'zip',
                                      :headers => ['Accept: application/octet-stream']
                                    }
    spec.authors                  = { 'Dyte' => 'dev@dyte.io' }
    spec.license                  = { :type => 'MIT' }
    spec.summary                  = 'Dyte Audio/Video SDKs'
    spec.vendored_frameworks      = 'DyteiOSCore.xcframework'
            
    spec.ios.deployment_target = '13.0'
    spec.dependency 'WebRTC-SDK', '114.5735.08'
    spec.libraries = ''
    spec.platform = :ios, '13.0'
end