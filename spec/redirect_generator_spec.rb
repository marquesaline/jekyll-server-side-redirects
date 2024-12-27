require 'jekyll'
require_relative '../lib/jekyll-server-side-redirects/generator'

RSpec.describe Jekyll::RedirectGenerator do
  let(:site) do
    instance_double('Jekyll::Site', 
      config: {
        'server_redirects' => {
          'server' => 'firebase'
        }
      },
      pages: [], 
      posts: instance_double('Posts', docs: []) 
    )
  end

  describe '#generate' do
    it 'correctly identifies the Firebase server' do
      expect { Jekyll::RedirectGenerator.get_server(site) }.not_to raise_error
    end
  end
end

RSpec.describe Jekyll::RedirectGenerator do
  let(:site) do
    instance_double('Jekyll::Site', 
      config: {
        'server_redirects' => {
          'server' => 'apache'
        }
      },
      pages: [], 
      posts: instance_double('Posts', docs: []) 
    )
  end

  describe '#generate' do
    it 'correctly identifies the Apache server' do
      expect { Jekyll::RedirectGenerator.get_server(site) }.not_to raise_error
    end
  end
end
