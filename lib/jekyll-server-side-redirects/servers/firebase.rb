module Jekyll
    module ServerSideRedirects
        module Firebase
            def self.generate_redirects(site)
                redirects_data = []

                redirects_data += process_redirects(site.pages)
                redirects_data += process_redirects(site.posts.docs)
                generate_firebase_json(redirects_data)

                redirects_data
            end

            def self.generate_firebase_json(redirects_data)
                file_path = "firebase.json"
                firebase_content = {}

                if File.exist?(file_path)
                    file_content = File.read(file_path)
                    firebase_content = JSON.parse(file_content)
                else
                    firebase_content["hosting"] = { "redirects" => [] }
                end

                valid_keys = ['source', 'destination', 'type']
                existing_redirects = firebase_content["hosting"]["redirects"].map do |redirect|
                    redirect.select { |key, _| valid_keys.include?(key) }
                end

                firebase_content["hosting"]["redirects"] = (existing_redirects + redirects_data).uniq { |r| r["source"] }

                File.open(file_path, "w") do |file|
                    file.write(JSON.pretty_generate(firebase_content))
                end
            end

            def self.process_redirects(data)
                redirects = []
                data.each do |item|
                    next unless item.data['redirect_from']

                    redirect_from = item.data['redirect_from']
                    redirect_from = [redirect_from] unless redirect_from.is_a?(Array)

                    redirect_from.each do |source|
                        redirects << {
                            'source' => source,
                            'destination' => item.permalink,
                            'type' => item.data['redirect_type'] || 301 
                        }
                    end
                end
                redirects
            end
        end
    end
end
