require_relative './servers/firebase'

module Jekyll
    module RedirectGenerator
      def self.get_server(site)
        config = site.config['server_redirects']
        return unless config
        server = config['server']
        
        case server
        when 'firebase'
            Jekyll::ServerSideRedirects::Firebase.generate_redirects(site)
        else
            raise 'Invalid server specified'
        end
      end
    end
end
  