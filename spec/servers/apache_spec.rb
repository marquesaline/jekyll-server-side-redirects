require 'jekyll'
require 'fileutils'
require_relative '../../lib/jekyll-server-side-redirects/servers/apache'

RSpec.describe Jekyll::ServerSideRedirects::Apache do
  let(:site) do
    instance_double('Jekyll::Site').tap do |mock|
      allow(mock).to receive(:pages).and_return([
        instance_double('Page',
          permalink: '/page1/',
          data: { 
            'redirect_from' => ['/old-page1/']
          }
        ),
        instance_double('Page',
          permalink: '/page2/',
          data: { 
            'redirect_from' => ['/old-page2/']
          }
        )
      ])

      allow(mock).to receive(:posts).and_return(
        instance_double('Posts', docs: [
          instance_double('Post',
            permalink: '/post1/', 
            data: {
              'redirect_from' => ['/old-post1/']
            }
          ),
          instance_double('Post',
            permalink: '/post2/',
            data: {
              'redirect_from' => ['/old-post2/']
            }
          )
        ])
      )
    end
  end

  after(:each) do
    File.delete('.htaccess') if File.exist?('.htaccess')
  end

  describe '#generate_htaccess' do
    it 'creates a new .htaccess when it does not exist' do
      redirects_data = Jekyll::ServerSideRedirects::Apache.generate_redirects(site)
      Jekyll::ServerSideRedirects::Apache.generate_htaccess(redirects_data)

      htaccess_content = File.read('.htaccess')

      expect(htaccess_content).to include("Redirect 301 /old-page1/ /page1/")
      expect(htaccess_content).to include("Redirect 301 /old-page2/ /page2/")
      expect(htaccess_content).to include("Redirect 301 /old-post1/ /post1/")
      expect(htaccess_content).to include("Redirect 301 /old-post2/ /post2/")
    end

    it 'maintains existing redirects and adds new ones without duplications' do
      initial_content = <<~HTACCESS
        # Existing .htaccess file
        Redirect 301 /existing-page /existing-destination
      HTACCESS
      File.open('.htaccess', 'w') { |file| file.write(initial_content) }

      redirects_data = Jekyll::ServerSideRedirects::Apache.generate_redirects(site)
      Jekyll::ServerSideRedirects::Apache.generate_htaccess(redirects_data)

      htaccess_content = File.read('.htaccess')

      expect(htaccess_content).to include("Redirect 301 /existing-page /existing-destination")
      expect(htaccess_content).to include("Redirect 301 /old-page1/ /page1/")
      expect(htaccess_content).to include("Redirect 301 /old-page2/ /page2/")
      expect(htaccess_content).to include("Redirect 301 /old-post1/ /post1/")
      expect(htaccess_content).to include("Redirect 301 /old-post2/ /post2/")
    end
  end
end

RSpec.describe Jekyll::ServerSideRedirects::Apache do
  let(:site) do
    instance_double('Jekyll::Site').tap do |mock|
      allow(mock).to receive(:pages).and_return([
        instance_double('Page',
          permalink: '/page1/',
          data: { 
            'redirect_from' => ['/old-page1/'],
            'redirect_type' => 302
          }
        ),
        instance_double('Page',
          permalink: '/page2/',
          data: { 
            'redirect_from' => ['/old-page2/'],
            'redirect_type' => 301
          }
        )
      ])

      allow(mock).to receive(:posts).and_return(
        instance_double('Posts', docs: [
          instance_double('Post',
            permalink: '/post1/',
            data: {
              'redirect_from' => ['/old-post1/'],
              'redirect_type' => 302
            }
          ),
          instance_double('Post',
            permalink: '/post2/',
            data: {
              'redirect_from' => ['/old-post2/'],
              'redirect_type' => 301
            }
          )
        ])
      )
    end
  end

  after(:each) do
    File.delete('.htaccess') if File.exist?('.htaccess')
  end

  describe '#generate_htaccess' do
    it 'creates a .htaccess with the correct redirect types' do
      redirects_data = Jekyll::ServerSideRedirects::Apache.generate_redirects(site)
      Jekyll::ServerSideRedirects::Apache.generate_htaccess(redirects_data)

      htaccess_content = File.read('.htaccess')

      expect(htaccess_content).to include("Redirect 302 /old-page1/ /page1/")
      expect(htaccess_content).to include("Redirect 301 /old-page2/ /page2/")
      expect(htaccess_content).to include("Redirect 302 /old-post1/ /post1/")
      expect(htaccess_content).to include("Redirect 301 /old-post2/ /post2/")
    end
  end
end
