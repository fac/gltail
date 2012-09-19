class NginxJsonParser < Parser
  def parse( line, metadata )
    add_activity(:block => 'sourcehost', :name => metadata['@fields']['remote_addr'])
    add_activity(:block => 'Nginx Servers', :name => metadata['@source_host'])
    add_activity(:block => 'user agents', :name => metadata['@fields']['http_user_agent'])
    add_activity(:block => 'revision', :name => metadata['@fields']['app_rev'])
    add_activity(:block => 'status', :name => metadata['@fields']['http_status'])      
  end
end