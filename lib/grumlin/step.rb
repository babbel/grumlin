# frozen_string_literal: true

module Grumlin
  class Step
    attr_reader :name

    def initialize(name, *args, **params)
      @name = name
      @args = args
      @params = params
    end

    def args
      [*@args].tap do |args|
        args << @params if @params.any?
      end
    end
  end
end
