map.search '/code_documents/search', :controller => 'code_documents', :action => 'search'
map.resources :code_documents
connect 'codebook/:action.:format', :controller => 'codebook'
