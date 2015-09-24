# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'logstash/inputs/udp'

class LogStash::Inputs::Udp
  attr_reader :udp
end

module UdpHelpers

  def input(plugin, size, &block)
    queue = Queue.new
    input_thread = Thread.new do
      plugin.run(queue)
    end
    # because the udp socket is created and bound during #run
    # we must ensure that it is open before sending data
    sleep 0.1 until (plugin.udp && !plugin.udp.closed?)
    block.call
    sleep 0.1 while queue.size != size
    result = nevents.times.inject([]) do |acc|
      acc << queue.pop
    end
    plugin.do_stop
    result
  end

end

RSpec.configure do |c|
  c.include UdpHelpers
end
