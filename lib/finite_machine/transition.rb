# encoding: utf-8

module FiniteMachine
  # Class describing a transition associated with a given event
  class Transition
    include Threadable

    attr_threadsafe :name

    # State transitioning from
    attr_threadsafe :from

    # State transitioning to
    attr_threadsafe :to

    # Predicates before transitioning
    attr_threadsafe :conditions

    # The current state machine
    attr_threadsafe :machine

    # The original from state
    attr_threadsafe :from_state

    # Initialize a Transition
    #
    # @param [StateMachine] machine
    # @param [Hash] attrs
    #
    # @api public
    def initialize(machine, attrs = {})
      @machine    = machine
      @name       = attrs.fetch(:name, DEFAULT_STATE)
      @from, @to  = *parse_states(attrs)
      @from_state = @from.first
      @if         = Array(attrs.fetch(:if, []))
      @unless     = Array(attrs.fetch(:unless, []))
      @conditions = make_conditions
    end

    # Reduce conditions
    #
    # @api private
    def make_conditions
      @if.map { |c| Callable.new(c) } +
        @unless.map { |c| Callable.new(c).invert }
    end

    # Extract states from attributes
    #
    # @param [Hash] attrs
    #
    # @api private
    def parse_states(attrs)
      _attrs = attrs.dup
      [:name, :if, :unless].each { |key| _attrs.delete(key) }
      raise_not_enough_transitions(attrs) unless _attrs.any?

      if [:from, :to].any? { |key| attrs.keys.include?(key) }
        [Array(_attrs[:from] || ANY_STATE), _attrs[:to]]
      else
        [(keys = _attrs.keys).flatten, _attrs[keys.first]]
      end
    end

    # Add transition to the machine
    #
    # @return [Transition]
    #
    # @api private
    def define
      from.each do |from|
        machine.transitions[name][from] = to || from
      end
    end

    # Define helper state mehods for the transition states
    #
    # @api private
    def define_state_methods
      from.concat([to]).each { |state| define_state_method(state) }
    end

    # Define state helper method
    #
    # @param [Symbol] state
    #
    # @api private
    def define_state_method(state)
      return if machine.respond_to?("#{state}?")
      machine.send(:define_singleton_method, "#{state}?") do
        machine.is?(state.to_sym)
      end
    end

    # Define event on the machine
    #
    # @api private
    def define_event
      _transition = self
      _name       = name

      machine.singleton_class.class_eval do
        undef_method(_name) if method_defined?(_name)
      end
      machine.send(:define_singleton_method, name) do |*args, &block|
        transition(_transition, *args, &block)
      end
    end

    # Execute current transition
    #
    # @return [nil]
    #
    # @api private
    def call
      sync_exclusive do
        transitions = machine.transitions[name]
        self.from_state = machine.state
        machine.state = transitions[machine.state] || transitions[ANY_STATE] || name
      end
    end

    # Return transition name
    #
    # @api public
    def to_s
      @name
    end

    # Return string representation
    #
    # @return [String]
    #
    # @api public
    def inspect
      "<#{self.class} name: #{@name}, transitions: #{@from} => #{@to}, when: #{@conditions}>"
    end

    private

    # Raise error when not enough transitions are provided
    #
    # @param [Hash] attrs
    #
    # @raise [NotEnoughTransitionsError]
    #   if the event has not enough transition arguments
    #
    # @return [nil]
    #
    # @api private
    def raise_not_enough_transitions(attrs)
      raise NotEnoughTransitionsError, "please provide state transitions for '#{attrs.inspect}'"
    end
  end # Transition
end # FiniteMachine
