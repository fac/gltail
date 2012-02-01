require 'bunny'
require 'active_support'
module GlTail
  module Source
    
    class AMQPQueue
      def initialize
        @queue = []
        @mutex = Mutex.new
      end
      def enq payload
        @mutex.synchronize { @queue.push payload }
      end
      def deq
        @mutex.synchronize { @queue.shift }
      end
      def flush
        @mutex.synchronize { @queue = [] }
      end
    end
    class AMQPThread
      module Metadataize
        def self.metadata
          @metadata ||= {}
        end
      end
      def initialize config
        @queues = {}
        @config = config
        @mutex = Mutex.new
        Thread.new &method(:thread_main)
      end
      def thread_main
        connection = Bunny.new({
          :host => @config['host'],
          :port => @config['port'].to_i,
          :user => @config['username'],
          :pass => @config['password'],
          :vhost => @config['vhost'],
          :ssl => true,
          :logging => false
        })
        
        p connection.start

        queue = connection.queue('', :auto_delete => true, :exclusive => true)
        queue.bind('logs', :routing_key => '#')

        ret = queue.subscribe do |msg|
          payload = ActiveSupport::JSON.decode msg[:payload]
          queues = @mutex.synchronize { @queues[payload['@type']] }
          queues.each { |q| 
            q.enq payload
          } if queues
        end
      rescue 
        p $!
        puts $!.backtrace.join("\n\t")
      end
      
      def subscribe_queue type
        queue = AMQPQueue.new
        @mutex.synchronize {
          @queues[type] ||= []
          @queues[type] << queue
        }
        queue
      end
    end
    
    class AMQP < Base
      config_attribute :source, "The type of Source"
      config_attribute :host
      config_attribute :files, "The files to tail", :deprecated => "Should be embedded in the :command"

      def self.configure name, config, outer_config
        amqp = AMQPThread.new config
        
        config['types'].collect { |spec|
          name, config = *spec
          
          source = GlTail::Source::AMQP.new outer_config
          source.queue = amqp.subscribe_queue(name)
          source.parser = config['parser']
          source.color = config['color']
          source
        }
      end

      attr_accessor :queue
      def init
        @queue.flush
      end
    
      def process
        
        if payload = @queue.deq
          if parser.method(:parse).arity == 2
            parser.parse payload['@message'], payload
          else
            parser.parse payload['@message']
          end
        end
      end
      
      def update
      end
        
    end
  end
end
