require_relative './servers/firebase'
require_relative './servers/apache'

module Jekyll
    module RedirectGenerator
      def self.get_server(site)
        config = site.config['server_redirects']
        return unless config
        server = config['server']
        
        case server
        when 'firebase'
            Jekyll::ServerSideRedirects::Firebase.generate_redirects(site)
        when 'apache' 
            Jekyll::ServerSideRedirects::Apache.generate_redirects(site)
        else
            raise 'Invalid server specified'
        end
      end
    end
end
  