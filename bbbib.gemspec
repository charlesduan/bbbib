require 'rake'
require 'date'

Gem::Specification.new do |s|
    s.name = 'bbbib'
    s.version = '1.0.8'
    s.date = Date.today.to_s
    s.summary = 'Automatic bibliographic information retrieval'
    s.description = 'Collects information for citations to websites'
    s.author = [ 'Charles Duan' ]
    s.email = 'rubygems.org@cduan.com'
    s.executables << 'bbbib'
    s.executables << 'cap'
    s.files = FileList[
        'lib/**/*.rb',
        'test/**/*.rb',
        'bin/*'
    ].to_a
    s.add_runtime_dependency "nokogiri", '~> 1.5'
    s.license = 'MIT'
    s.homepage = 'https://github.com/charlesduan/bbbib'
end

