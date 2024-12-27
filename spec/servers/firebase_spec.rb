require 'jekyll'
require 'json'
require 'fileutils'
require_relative '../../lib/jekyll-server-side-redirects/servers/firebase'

RSpec.describe Jekyll::ServerSideRedirects::Firebase do
  let(:site) do
    instance_double('Jekyll::Site').tap do |mock|
      allow(mock).to receive(:pages).and_return([
        instance_double('Page',
          permalink: '/page1/',
          data: { 
            'redirect_from' => ['/other-page1/']
          }
        ),
        instance_double('Page',
          permalink: '/page2/',
          data: { 
            'redirect_from' => '/other-page2/'
          }
        )
      ])

      allow(mock).to receive(:posts).and_return(
        instance_double('Posts', docs: [
          instance_double('Post',
            permalink: '/post1/', 
            data: {
              'redirect_from' => ['/other-post1/']
            }
          ),
          instance_double('Post',
            permalink: '/post2/',
            data: {
              'redirect_from' => '/other-post2/'
            }
          )
        ])
      )
    end
  end

  after(:each) do
    File.delete('firebase.json') if File.exist?('firebase.json')
  end

  describe '#generate_firebase_json' do
    it 'creates a new firebase.json when it does not exist' do
      redirects_data = Jekyll::ServerSideRedirects::Firebase.generate_redirects(site)
      Jekyll::ServerSideRedirects::Firebase.generate_firebase_json(redirects_data)

      json_output = JSON.parse(File.read('firebase.json'))

      expect(json_output["hosting"]["redirects"]).to contain_exactly(
        { 'source' => '/other-page1/', 'destination' => '/page1/', 'type' => 301 },
        { 'source' => '/other-page2/', 'destination' => '/page2/', 'type' => 301 },
        { 'source' => '/other-post1/', 'destination' => '/post1/', 'type' => 301 },
        { 'source' => '/other-post2/', 'destination' => '/post2/', 'type' => 301 }
      )
    end

    it 'maintains existing redirects and adds new ones without duplications' do
      initial_content = {
        "hosting" => {
          "redirects" => [
            { 'source' => '/existing-page/', 'destination' => '/existing-destination/', 'type' => 301 }
          ]
        }
      }
      File.open('firebase.json', 'w') { |file| file.write(JSON.pretty_generate(initial_content)) }

      redirects_data = Jekyll::ServerSideRedirects::Firebase.generate_redirects(site)
      Jekyll::ServerSideRedirects::Firebase.generate_firebase_json(redirects_data)

      json_output = JSON.parse(File.read('firebase.json'))

      expect(json_output["hosting"]["redirects"]).to contain_exactly(
        { 'source' => '/existing-page/', 'destination' => '/existing-destination/', 'type' => 301 },
        { 'source' => '/other-page1/', 'destination' => '/page1/', 'type' => 301 },
        { 'source' => '/other-page2/', 'destination' => '/page2/', 'type' => 301 },
        { 'source' => '/other-post1/', 'destination' => '/post1/', 'type' => 301 },
        { 'source' => '/other-post2/', 'destination' => '/post2/', 'type' => 301 }
      )
    end
  end
end

RSpec.describe Jekyll::ServerSideRedirects::Firebase do
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
    File.delete('firebase.json') if File.exist?('firebase.json')
  end

  describe '#generate_firebase_json' do
    it 'creates a firebase.json with the correct redirect types' do
      redirects_data = Jekyll::ServerSideRedirects::Firebase.generate_redirects(site)
      Jekyll::ServerSideRedirects::Firebase.generate_firebase_json(redirects_data)

      json_output = JSON.parse(File.read('firebase.json'))

      expect(json_output["hosting"]["redirects"]).to contain_exactly(
        { 'source' => '/old-page1/', 'destination' => '/page1/', 'type' => 302 },
        { 'source' => '/old-page2/', 'destination' => '/page2/', 'type' => 301 },
        { 'source' => '/old-post1/', 'destination' => '/post1/', 'type' => 302 },
        { 'source' => '/old-post2/', 'destination' => '/post2/', 'type' => 301 }
      )
    end
  end
end
