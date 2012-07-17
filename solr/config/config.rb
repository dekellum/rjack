
RJack::Solr.configure do |c|

  c.setup_http_server do |s|
    s.port = 8983
    s.max_threads = 10
  end

end
