desc "Run the Continuous Integration tests for Redmine"
task :ci do
  # RAILS_ENV and ENV[] can diverge so force them both to test
  ENV['RAILS_ENV'] = 'test'
  RAILS_ENV = 'test'
  Rake::Task["ci:setup"].invoke
  Rake::Task["ci:build"].invoke
  Rake::Task["ci:teardown"].invoke
end

namespace :ci do
  desc "Setup Redmine for a new build"
  task :setup do
    Rake::Task["tmp:clear"].invoke
    Rake::Task["log:clear"].invoke
    Rake::Task["db:create:all"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:schema:dump"].invoke
    if scms = ENV['SCMS']
      scms.split(',').each do |scm|
        Rake::Task["test:scm:setup:#{scm}"].invoke
      end
    else
      Rake::Task["test:scm:setup:all"].invoke
    end
    Rake::Task["test:scm:update"].invoke
  end

  desc "Build Redmine"
  task :build do
    if test_suite = ENV['TEST_SUITE']
      Rake::Task["test:#{test_suite}"].invoke
    else
      Rake::Task["test"].invoke
    end
    # Rake::Task["test:ui"].invoke if RUBY_VERSION >= '1.9.3'
  end

  desc "Finish the build"
  task :teardown do
  end
end

<<<<<<< HEAD
  desc "Creates and configures the databases for the CI server"
  task :database do
    path = 'config/database.yml'
    unless File.exists?(path)
      database = ENV['DATABASE_ADAPTER']
      ruby = ENV['RUBY_VER'].gsub('.', '').gsub('-', '')
      branch = ENV['BRANCH'].gsub('.', '').gsub('-', '')
      dev_db_name = "ci_#{branch}_#{ruby}_dev"
      test_db_name = "ci_#{branch}_#{ruby}_test"

      case database
      when 'mysql'
        raise "Error creating databases" unless
          system(%|mysql -u jenkins --password=jenkins -e 'create database #{dev_db_name} character set utf8;'|) &&
          system(%|mysql -u jenkins --password=jenkins -e 'create database #{test_db_name} character set utf8;'|)
        dev_conf =  { 'adapter' => (RUBY_VERSION >= '1.9' ? 'mysql2' : 'mysql'), 'database' => dev_db_name, 'host' => 'localhost', 'username' => 'jenkins', 'password' => 'jenkins', 'encoding' => 'utf8' }
        test_conf = { 'adapter' => (RUBY_VERSION >= '1.9' ? 'mysql2' : 'mysql'), 'database' => test_db_name, 'host' => 'localhost', 'username' => 'jenkins', 'password' => 'jenkins', 'encoding' => 'utf8' }
      when 'postgresql'
        raise "Error creating databases" unless
          system(%|psql -U jenkins -d postgres -c "create database #{dev_db_name} owner jenkins encoding 'UTF8';"|) &&
          system(%|psql -U jenkins -d postgres -c "create database #{test_db_name} owner jenkins encoding 'UTF8';"|)
        dev_conf =  { 'adapter' => 'postgresql', 'database' => dev_db_name, 'host' => 'localhost', 'username' => 'jenkins', 'password' => 'jenkins' }
        test_conf = { 'adapter' => 'postgresql', 'database' => test_db_name, 'host' => 'localhost', 'username' => 'jenkins', 'password' => 'jenkins' }
      when 'sqlite3'
        dev_conf =  { 'adapter' => 'sqlite3', 'database' => "db/#{dev_db_name}.sqlite3" }
        test_conf = { 'adapter' => 'sqlite3', 'database' => "db/#{test_db_name}.sqlite3" }
      else
        raise "Unknown database"
      end
=======
desc "Creates database.yml for the CI server"
file 'config/database.yml' do
  require 'yaml'
  database = ENV['DATABASE_ADAPTER']
  ruby = ENV['RUBY_VER'].gsub('.', '').gsub('-', '')
  branch = ENV['BRANCH'].gsub('.', '').gsub('-', '')
  dev_db_name = "ci_#{branch}_#{ruby}_dev"
  test_db_name = "ci_#{branch}_#{ruby}_test"
>>>>>>> 2.6.5

  case database
  when 'mysql'
    dev_conf =  {'adapter' => (RUBY_VERSION >= '1.9' ? 'mysql2' : 'mysql'),
                 'database' => dev_db_name, 'host' => 'localhost',
                 'encoding' => 'utf8'}
    if ENV['RUN_ON_NOT_OFFICIAL']
      dev_conf['username'] = 'root'
    else
      dev_conf['username'] = 'jenkins'
      dev_conf['password'] = 'jenkins'
    end
    test_conf = dev_conf.merge('database' => test_db_name)
  when 'postgresql'
    dev_conf =  {'adapter' => 'postgresql', 'database' => dev_db_name,
                 'host' => 'localhost'}
    if ENV['RUN_ON_NOT_OFFICIAL']
      dev_conf['username'] = 'postgres'
    else
      dev_conf['username'] = 'jenkins'
      dev_conf['password'] = 'jenkins'
    end
    test_conf = dev_conf.merge('database' => test_db_name)
  when /sqlite3/
    dev_conf =  {'adapter' => (Object.const_defined?(:JRUBY_VERSION) ?
                                 'jdbcsqlite3' : 'sqlite3'),
                 'database' => "db/#{dev_db_name}.sqlite3"}
    test_conf = dev_conf.merge('database' => "db/#{test_db_name}.sqlite3")
  when 'sqlserver'
    dev_conf =  {'adapter' => 'sqlserver', 'database' => dev_db_name,
                 'host' => 'mssqlserver', 'port' => 1433,
                 'username' => 'jenkins', 'password' => 'jenkins'}
    test_conf = dev_conf.merge('database' => test_db_name)
  else
    abort "Unknown database"
  end

  File.open('config/database.yml', 'w') do |f|
    f.write YAML.dump({'development' => dev_conf, 'test' => test_conf})
  end
end
