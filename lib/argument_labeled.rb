class Module
  public :define_method, :alias_method

  # Sets a list of required arguments for the next method defined
  def required_arguments(*args)
    @current_required_arguments = args
    define_our_temporary_method_added
  end

  # Sets default arguments for the next method defined
  def default_arguments(&block)
    @current_default_arguments = block
    define_our_temporary_method_added
  end

  # Sets a list of allowed arguments for the next method defined
  def allowed_arguments(*args)
    @current_allowed_arguments = args
    define_our_temporary_method_added
  end

  private
  def define_our_temporary_method_added
    # only define our hooks once, even if we add requirements as well as defaults/allowed arguments
    @defined_temporary_method_added ||= false
    return if @defined_temporary_method_added
    @defined_temporary_method_added = true

    # store the current hooks so we can restore them (less intrusive, yay)
    next_subs_ma = method(:method_added)
    next_subs_sma = method(:singleton_method_added)

    # define hooks
    [:method_added, :singleton_method_added].each do |hook|
      define_singleton_method(hook) do |name|
        return if name == :singleton_method_added
        return if name == :method_added
        define_singleton_method(:method_added, &next_subs_ma)
        define_singleton_method(:singleton_method_added, &next_subs_sma)

        # store the instance variables in local ones so we can use them in the following blocks
        current_required_arguments = @current_required_arguments || []
        current_default_arguments  = @current_default_arguments  || lambda {{}}
        current_allowed_arguments  = @current_allowed_arguments  || []

        # methods and singleton methods have other means of being get/defined
        case hook
        when :method_added
          our_method = instance_method(name)
          which_define_method = :define_method
        when :singleton_method_added
          our_method = method(name)
          which_define_method = :define_singleton_method
        end

        self.send(which_define_method, name) do |*args, &block|
          args = args[0] || Hash.new

          # check for unallowed keys
          unless current_allowed_arguments.empty?
            unknown = args.keys - current_allowed_arguments
            unless unknown.empty?
              raise ArgumentError, "Unknown arguments: #{unknown.join(", ")}", caller
            end
          end

          # check for missing keys
          args = current_default_arguments.call.merge args
          missing = current_required_arguments - args.keys
          unless missing.empty?
            raise ArgumentError, "Missing arguments: #{missing.join(', ')}", caller
          end

          begin
            # call the real method
            case hook
            when :method_added
              our_method.bind(self).call(args, &block)
            when :singleton_method_added
              our_method.call(args, &block)
            end
          rescue => e
            # hiding ourself from the backtrace
            bt = e.backtrace
            r = /^#{Regexp.escape(__FILE__)}:\d+:in/
              bt.delete_if do |line|
              line =~ r
            end
            e.set_backtrace bt
            raise e
          end
        end

        @current_required_arguments = nil
        @current_default_arguments  = nil
        @defined_temporary_method_added = false
      end
    end
  end
end
