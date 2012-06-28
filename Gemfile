source :rubygems

platform :jruby do
  gem 'redstorm', '~> 0.6.0', :git => "git://github.com/colinsurprenant/redstorm.git", :branch => "dependencies"
end

platform :mri  do
  gem 'twitter-stream', '~> 0.1.15'
  gem 'redis', '~> 2.2.2'
  gem 'hiredis', '~> 0.4.5'
end

group :topology do
  gem 'redis', '~> 2.2.2', :platforms => :jruby
  gem 'json', :platforms => :jruby
end