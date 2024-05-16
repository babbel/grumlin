# frozen_string_literal: true

class Grumlin::Repository::ErrorHandlingStrategy
  def initialize(mode: :retry, **params)
    @mode = mode
    @params = params
    @on_exceptions = params[:on]
  end

  def raise?
    @mode == :raise
  end

  def ignore?
    @mode == :ignore
  end

  def retry?
    @mode == :retry
  end

  def apply!(&)
    return yield if raise?
    return ignore_errors!(&) if ignore?

    retry_errors!(&)
  end

  private

  def ignore_errors!
    yield
  rescue *@on_exceptions
    # ignore errors
  end

  def retry_errors!(&)
    Retryable.retryable(**@params, &)
  end
end
