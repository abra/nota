Pod::Spec.new do |s|
  s.name             = 'speech_apple'
  s.version          = '0.1.0'
  s.summary          = 'SpeechAnalyzer bridge for Nota dictation.'
  s.description      = <<-DESC
Continuous on-device dictation through the iOS 26 SpeechAnalyzer API.
                       DESC
  s.homepage         = 'https://github.com/abra/nota'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Nota' => 'noreply@github.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'speech_apple/Sources/speech_apple/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
