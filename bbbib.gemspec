require 'rake'

Gem::Specification.new do |s|
    s.name = 'bbbib'
    s.version = '0.1.0'
    s.date = '2019-02-10'
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
    s.add_runtime_dependency "nokogiri", '~> 1.10'
end

