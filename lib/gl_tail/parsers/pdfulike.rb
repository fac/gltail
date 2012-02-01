class PdfULikeParser < Parser
  def parse( line, metadata )
    add_activity(:block => 'PDF Servers', :name => metadata['@source_host'])
    
    if line =~ /Time to generate: ([\d.]+) seconds/
      add_activity(:block => 'info', :name => "PDF Generated")
    end
  end
end