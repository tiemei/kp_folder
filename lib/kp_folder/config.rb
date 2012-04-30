# conding: utf-8

module KpFolder
  module Config
    @consumer_key, @consumer_secret = %w(xcWcZhCNKFJz1H8p 8RvkM0aGYiQF5kJF)
    class << self
      attr_reader :consumer_key, :consumer_secret
    end
  end 
end
