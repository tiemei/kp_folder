# conding: utf-8

require 'kp_folder'
require 'test/unit'
require 'uri'

class KpFolderTest < Test::Unit::TestCase
  def test_init
    KpFolder.init
    p KpFolder.k_session.metadata('/') 
    KpFolder.k_session.create_folder('/tiemei_test/')
    p KpFolder.k_session.metadata('/tiemei_test')
    p KpFolder.k_session.delete('/tiemei_test')
#KpFolder.k_session.metadata('/tiemei_test')
  end

  def test_rm_add
    KpFolder.add('/home/jdk')
    KpFolder.add('/home/jdk/Desktop')
    KpFolder.remove('/home/jdk/Desktop')
    KpFolder.add('/home/jdk')
    KpFolder.remove('/home/jdk')
  end
  
  def test_files_in_folders
    KpFolder.instance_eval do
      @local_files = []
      files_in_folder('/home/jdk/codespace/ruby_space/kp_folder/lib')
      p @local_files
    end
  end

  def test_start
    KpFolder.add('/home/jdk/codespace/ruby_space/kp_folder/lib')
    KpFolder.start
  end
  
end

