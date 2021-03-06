require 'sidekiq/logging/shared'

module Sidekiq
  class LogstashJobLogger
    include Sidekiq::Logging::Shared

    def call(job, _queue)
      started_at = Time.now.utc
      yield
      Sidekiq.logger.info log_job(job, started_at)
    rescue => exc
      begin
        Sidekiq.logger.warn log_job(job, started_at, exc)
      rescue => ex
        Sidekiq.logger.error 'Error logging the job execution!'
        Sidekiq.logger.error "Job: #{job}"
        Sidekiq.logger.error "Job Exception: #{exc}"
        Sidekiq.logger.error "Log Exception: #{ex}"
      end
      raise
    end
  end
end