require "msgpack/version"

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby" # This is same with `/java/ =~ RUBY_VERSION`
  require "java"
  require "msgpack/msgpack.jar"
  org.msgpack.jruby.MessagePackLibrary.new.load(JRuby.runtime, false)
else
  begin
    require "msgpack/#{RUBY_VERSION[/\d+.\d+/]}/msgpack"
  rescue LoadError
    require "msgpack/msgpack"
  end
end

require "msgpack/packer"
require "msgpack/unpacker"
require "msgpack/factory"
require "msgpack/symbol"

module MessagePack
  def load(src, param = nil)
    unpacker = nil

    if src.is_a? String
      unpacker = DefaultFactory.unpacker param
      unpacker.feed src
    else
      unpacker = DefaultFactory.unpacker src, param
    end

    unpacker.full_unpack
  end
  alias :unpack :load

  module_function :load
  module_function :unpack

  def pack(v, *rest)
    packer = DefaultFactory.packer(*rest)
    packer.write v
    packer.full_pack
  end
  alias :dump :pack

  module_function :pack
  module_function :dump
end

module MessagePack
  module CoreExt
    def to_msgpack(*args)
      if args.length != 1 || !args.first.is_a?(MessagePack::Packer)
        case args.length
        when 0 then MessagePack.pack(self)
        when 1 then MessagePack.pack(self, args.first)
        else
          raise
        end
      else
        _to_msgpack args.first
      end
    end
  end
end

class NilClass
  include MessagePack::CoreExt

  def _to_msgpack(packer)
    packer.write_nil
    packer
  end
end

class TrueClass
  include MessagePack::CoreExt

  def _to_msgpack(packer)
    packer.write_true
    packer
  end
end

class FalseClass
  include MessagePack::CoreExt

  def _to_msgpack(packer)
    packer.write_false
    packer
  end
end
