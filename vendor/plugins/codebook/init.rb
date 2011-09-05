require 'redmine'

# shamelessly copied from the stuff-to-do plugin by Eric Davis  
Dir[File.join(directory,'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  Dependencies.load_paths << path
  Dependencies.load_once_paths.delete(path)
end

Redmine::Plugin.register :codebook do
  name 'Redmine Codebook plugin'
  author 'Steffen Roegner'
  author_url 'http://www.sroegner.org'
  description 'A knowledge and source code sharing plugin for Redmine'
  version '0.3.1'
  requires_redmine :version_or_higher => '1.0.0'

  settings(:partial => 'preferences/codebook_prefs',
           :default => {
             'show_line_numbers' => '0'
           })
  menu(:top_menu, :codebook, {:controller => "codebook", :action => 'index'}, :caption => :codebook_title, :if => Proc.new{ User.current.logged? })
end
