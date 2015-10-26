Pod::Spec.new do |s|
    s.name                = "PKAES"
    s.version             = "0.0.1"
    s.summary             = "Simple and configurable interface to CommonCrypto's AES mechanics."
    s.description         = "Simple and configurable interface to CommonCrypto's AES mechanics."
    s.homepage            = "http://github.com/pkluz/PKAES"
    s.license             = "MIT"
    s.author              = "Philip Kluz"
    s.source              = { :git => "https://github.com/pkluz/PKAES.git", :tag => "v#{s.version}" }
    s.requires_arc        = true
    s.platform            = :ios, "8.0"
    s.source_files        = "PKAES/**/*.{h,m}"
    
end
