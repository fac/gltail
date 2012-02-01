class DelayedJobParser < Parser
  def parse( line, metadata )
    
    if line =~ /Worker\(host:([^\s]+) .*\)\] acquired lock on (.*)/
      worker = $1
      job = $2
      add_activity(:block => 'jobs', :name => job)
    end
    if line =~/\[JOB\] .* completed after/
      add_activity(:block => 'DJ Servers', :name => metadata['@source_host'])
    end
  end
end