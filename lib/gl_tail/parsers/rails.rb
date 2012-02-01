# gl_tail.rb - OpenGL visualization of your server traffic
# Copyright 2007 Erlend Simonsen <mr@fudgie.org>
#
# Licensed under the GNU General Public License v2 (see LICENSE)
#

# Parser which handles Rails access logs
class RailsParser < Parser
  def parse( line, metadata )
    
    # Match: 'Started <method> "<uri>" for <ip> at <timestamp>' line
    if line =~ /^Started (.*) \"([^\"]+)\" for ([0-9\.]+)/
      method = $1
      url = $2
      ip = $3
      
      simple_url = url.gsub(/\d+/,"[num]").gsub(/\?.*$/,'')

      add_activity(:block => 'users', :name => ip)
      add_activity(:block => 'urls',   :name => "#{method} #{simple_url}")
    end
    
    # Match: '  Processing by <controller>#<action> as <type>
    if line =~ /Processing by ([^\#]+)#([^\s]+) as (.*)/
      controller = $1
      action = $2
      type = $3
      add_activity(:block => 'App Servers', :name => metadata['@source_host'])
      
      add_activity(:block => 'action', :name => "#{controller}##{action}")
    end
    
    # Match: 'Finding company for subdomain [<subdomain>]
    if line =~ /subdomain \[([^\]]+)\]/
      subdomain = $1
      puts subdomain
      add_activity(:block => 'subdomain', :name => subdomain)
    end
    
    # Match: Completed <code> <status> in <time>ms
    if line =~ /Completed (.*) in ([\d\.]+)ms/
      status = $1
      time_ms = $2.to_f
#      add_activity(:block => 'status', :name => status)
    end

    if controller == 'SessionsController' && action == 'create'
      if line =~ /\"email\"=>\"([^\"]+)\"/
        user = $1
        add_event(:block => 'info', :name => "Login", :message => "#{user} [#{subdomain}] logged in", :update_stats => true, :color => [0.0, 1.0, 0.0, 1.0])
      end
    end

  end
  #     
  #     puts "parsing: #{line}"
  #     #Completed in 0.02100 (47 reqs/sec) | Rendering: 0.01374 (65%) | DB: 0.00570 (27%) | 200 OK [http://example.com/whatever/whatever]
  #     if matchdata = /^Completed \d+ [^\s] in ([\d.]+) .* \[([^\]]+)\]/.match(line)
  #       _, ms, url = matchdata.to_a
  # url = nil if url == "http:// /" # mod_proxy health checks?
  #     #Rails 2.2.2+: Completed in 17ms (View: 0, DB: 11) | 200 OK [http://example.com/etc/etc]
  #     elsif matchdata = /^Completed \d+ [^\s] in ([\d]+)ms/.match(line)
  #       _, new_ms = matchdata.to_a
  # ms = new_ms.to_f / 1000
  # url = nil # if url == "http:// /" # mod_proxy health checks?
  # p [ms, url]
  #     end
  # 
  #     if url
  #       _, host, url = /^http[s]?:\/\/([^\/]*)(.*)/.match(url).to_a
  # 
  #       add_activity(:block => 'sites', :name => host, :size => ms.to_f) # Size of activity based on request time.
  #       add_activity(:block => 'urls', :name => HttpHelper.generalize_url(url), :size => ms.to_f)
  #       add_activity(:block => 'slow requests', :name => HttpHelper.generalize_url(url), :size => ms.to_f)
  #       add_activity(:block => 'content', :name => 'page')
  # 
  #       # Events to pop up
  #       add_event(:block => 'info', :name => "Logins", :message => "Login...", :update_stats => true, :color => [0.5, 1.0, 0.5, 1.0]) if url.include?('/login')
  #       add_event(:block => 'info', :name => "Sales", :message => "$", :update_stats => true, :color => [1.5, 0.0, 0.0, 1.0]) if url.include?('/checkout')
  #       add_event(:block => 'info', :name => "Signups", :message => "New User...", :update_stats => true, :color => [1.0, 1.0, 1.0, 1.0]) if(url.include?('/signup') || url.include?('/users/create'))
  #     elsif line.include?('Processing ')
  #       #Processing TasksController#update_sheet_info (for 123.123.123.123 at 2007-10-05 22:34:33) [POST]
  #       _, host = /^Processing .* \(for (\d+.\d+.\d+.\d+) at .*\).*$/.match(line).to_a
  #       if host
  #         add_activity(:block => 'users', :name => host)
  #       end
  #     elsif line.include?('Error (')
  #       _, error, msg = /^([^ ]+Error) \((.*)\):/.match(line).to_a
  #       if error
  #         add_event(:block => 'info', :name => "Exceptions", :message => error, :update_stats => true, :color => [1.0, 0.0, 0.0, 1.0])
  #         add_event(:block => 'info', :name => "Exceptions", :message => msg, :update_stats => false, :color => [1.0, 0.0, 0.0, 1.0])
  #         add_activity(:block => 'warnings', :name => msg)
  # 
  #       end
    # end
  # end
end
