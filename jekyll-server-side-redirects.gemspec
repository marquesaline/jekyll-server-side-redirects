Gem::Specification.new do |s|
    s.name        = 'jekyll-server-side-redirects'
    s.version     = '0.1.1'
    s.authors     = ['Aline Marques']
    s.email       = ['alinem_oliveira@yahoo.com']
    s.summary     = 'Jekyll plugin to generate server-side redirects'
    s.description = 'Generates server-specific files for handling redirects (e.g., .htaccess, firebase.json).'
    s.files       = Dir['lib/**/*.rb'] + ['LICENSE', 'README.md']
    s.require_paths = ['lib']
    s.licenses    = ['MIT']
    s.homepage    = 'https://github.com/marquesaline/jekyll-server-side-redirects'
     s.metadata = {
        "source_code_uri"   => "https://github.com/marquesaline/jekyll-server-side-redirects",
        "documentation_uri" => "https://github.com/marquesaline/jekyll-server-side-redirects#readme",
    }

    s.add_development_dependency 'rspec', '~> 3.13'
end
