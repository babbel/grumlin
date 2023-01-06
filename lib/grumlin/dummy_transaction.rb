# frozen_string_literal: true

class Grumlin::DummyTransaction < Grumlin::Transaction
  attr_reader :uuid

  include Console

  def initialize(traversal_start_class, middlewares:, pool:)
    super
    @session_id = nil

    logger.info(self) do
      "#{Grumlin.config.provider} does not support transactions. commit and rollback are ignored, data will be saved"
    end
  end

  private

  def finalize(*)
    @pool.close
  end
end
