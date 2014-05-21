module RbMetis

  # @visibility private
  module Lib

    extend FFI::Library
    ffi_lib LIBMETIS
    attach_function :METIS_PartGraphRecursive, [:pointer]*13, :int
    attach_function :METIS_PartGraphKway, [:pointer]*13, :int
    attach_function :METIS_SetDefaultOptions, [:pointer], :int

    case IDXTYPEWIDTH
    when 32
      def alloc_idx_ary(ary)
        a = FFI::MemoryPointer.new(:int32, ary.size)
        a.write_array_of_int32(ary)
        a
      end
      def alloc_idx(num)
        a = FFI::MemoryPointer.new(:int32)
        a.write_int32(num)
        a
      end
      def read_idx_ary(a,n)
        a.read_array_of_int32(n)
      end
      def read_idx(a)
        a.read_int32
      end
    when 64
      def alloc_idx_ary(ary)
        a = FFI::MemoryPointer.new(:int64, ary.size)
        a.write_array_of_int64(ary)
        a
      end
      def alloc_idx(num)
        a = FFI::MemoryPointer.new(:int64)
        a.write_int64(num)
        a
      end
      def read_idx_ary(a,n)
        a.read_array_of_int64(n)
      end
      def read_idx(a)
        a.read_int64
      end
    end
    module_function :alloc_idx
    module_function :alloc_idx_ary
    module_function :read_idx
    module_function :read_idx_ary

    case REALTYPEWIDTH
    when 32
      def alloc_real_ary(ary)
        a = FFI::MemoryPointer.new(:float32, ary.size)
        a.write_array_of_float32(ary)
        a
      end
    when 64
      def alloc_real_ary(ary)
        a = FFI::MemoryPointer.new(:float64, ary.size)
        a.write_array_of_float64(ary)
        a
      end
    end
    module_function :alloc_real_ary

    def check_idx_array(args,name,size=nil,sizename=nil)
      arg = args[name]
      if arg
        if !(Array===arg)
          raise ArgumentError, "#{name} must be an array"
        end
        if size && arg.size != size
          raise ArgumentError, "the size of #{name} must be #{sizename||size}"
        end
        alloc_idx_ary(arg)
      else
        nil
      end
    end
    module_function :check_idx_array

    def check_real_array(args,name,size=nil,sizename=nil)
      arg = args[name]
      if arg
        if !(Array===arg)
          raise ArgumentError, "#{name} must be an array"
        end
        if size && arg.size != size
          raise ArgumentError, "the size of #{name} must be #{sizename||size}"
        end
        alloc_real_ary(arg)
      else
        nil
      end
    end
    module_function :check_real_array

    def check_idx(args,name,default_value=nil)
      arg = args[name]
      if arg
        if !(Integer===arg)
          raise ArgumentError, "#{name} must be an integer"
        end
        alloc_idx(arg)
      else
        if default_value
          alloc_idx(default_value)
        else
          nil
        end
      end
    end
    module_function :check_idx

    def postprocess(retval)
      case retval
      when METIS_OK
        "that the function returned normally."
      when METIS_ERROR_INPUT
        raise MetisError, "input error"
      when METIS_ERROR_MEMORY
        raise MetisError, "memory allocation error"
      when METIS_ERROR
        raise MetisError, "other type of error"
      else
        raise MetisError, "unknown return code"
      end
    end
    module_function :postprocess

  end
end
