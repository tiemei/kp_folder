# conding: utf-8
require 'kuaipan'
require 'json'

require 'set'

require 'kp_folder/config'

module KpFolder
  extend Kuaipan::OpenAPI
  class << self
    attr_reader :k_session
  end
  def self.init
    @oauth_result_file = '.oauth_result.json'
    input_config(Config.consumer_key, Config.consumer_secret) 
    @k_session = nil
    if File.exist?(@oauth_result_file)
      File.open(@oauth_result_file, 'r')do |f|
        oauth_result = JSON.parse(f.read)
        @k_session = g_session_skip_oauth(oauth_result['oauth_token'],
                                          oauth_result['oauth_token_secret'],
                                          oauth_result['user_id'])
      end
    else
      @k_session = g_session  
      authorize_url = @k_session[:authorize_url]
      puts 'please copy the url to your brower,then get number here:'
      puts authorize_url
      oauth_verifier = gets
      oauth_result = @k_session.set_atoken oauth_verifier
      File.open(@oauth_result_file, 'w+')do |f|
        f.write(JSON.generate(oauth_result))
      end
    end
    @folders_file = '.folders_upload'
    @db_file = '.db'
    File.open(@folders_file, 'w'){|f| f.write('[]')} unless File.exist?(@folders_file)
    File.open(@db_file, 'w'){|f| f.write('{}')} unless File.exist?(@db_file)
  end

  def self.remove(folder)
    arr = []
    File.open(@folders_file, 'r')do |f|
      arr = JSON.parse(f.read)
    end
    if arr.delete(folder)
      File.open(@folders_file, 'w')do |f|
        f.write(JSON.generate(arr))
      end
      puts "success!remove #{ folder }"
    else
      puts "failed to remove #{ folder }"
    end
  end

  def self.add(folder)
    arr = []
    File.open(@folders_file, 'r')do |f|
      arr = JSON.parse(f.read)
    end
    set = arr.to_set
    set.add(folder)
    File.open(@folders_file, 'w')do |f|
      f.write(JSON.generate(set.to_a))
    end
    puts "success to add #{folder}"
  end

  # 1.upload local files that aren't in file '.db',and update .db
  # 2.clear remote files
  def self.start(filter=".*")
    filter = Regexp.compile(filter)
    @local_files = []
    File.open(@folders_file, 'r'){|f| @folders = JSON.parse(f.read)}
    @folders.each do |folder|
      files_in_folder(folder)
    end
    
    File.open(@db_file, 'r')do |f|
      @db = JSON.parse(f.read)
    end
    @db_tmp = {}
    @local_files.each do |file_name|
      next if filter =~ File.basename(file_name)
      m = %r{/.*/}.match(file_name)
      file = File.open(file_name, 'rb')
      if @db[file_name] == nil 
        puts "upload file: \t\t#{ file_name }"
        k_session.upload_file(file, :path => m[0])
        @db_tmp[file_name] = k_session.metadata(file_name)
      elsif @db[file_name]['size'] != File.size(file_name)
        k_session.delete(file_name)
        puts "update file: \t\t#{ file_name }"
        k_session.upload_file(file, :path => m[0])
        @db_tmp[file_name] = k_session.metadata(file_name)
      else
        @db_tmp[file_name] = @db[file_name]
      end
    end
    @db = @db_tmp
    File.open(@db_file, 'w'){|f| f.write(JSON.generate(@db))}
    
    @files_remote = {}
    @folders.each do |folder|
      check_folder(folder)
    end
    
    diff = @files_remote.select {|k,_| @db[k] == nil }
    diff.each do |k,_| 
      k_session.delete(k) 
      p "clear remote file: \t#{ k }"
    end
  end

  private
    def self.files_in_folder(folder)
      Dir.foreach(folder)do |name|
        absolute_path = "#{ folder }/#{ name }"
        @local_files <<  absolute_path  if File.file?(absolute_path)
        next if (name == '.' or name == '..')
        files_in_folder(absolute_path) if File.directory?(absolute_path)
      end
    end
  
    def self.check_folder(folder)
      puts "check remote folder: \t#{ folder }"
      begin
        @k_session.metadata(folder)
      rescue Kuaipan::NotFound => nf
        @k_session.create_folder(folder)
      ensure
        hash = @k_session.metadata(folder)
        files = hash['files']
        files.each do |f|
          @files_remote["#{ hash['path'] }/#{ f['name'] }"] = f if f['type'] == 'file'        
          check_folder("#{ hash['path'] }/#{ f['name'] }") if f['type'] == 'folder'
        end 
      end
    end

end
