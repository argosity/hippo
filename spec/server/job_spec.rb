require_relative "spec_helper"
require 'active_job/test_helper'

class TestJob < Lanes::Job

    def perform
        sleep 0.1
        job_status.save(output: {one:1})
    end
end


class JobSpec < ActiveJob::TestCase

    def setup
        @adapter = ActiveJob::Base.queue_adapter
        ActiveJob::Base.queue_adapter = :test
    end

    def teardown
        ActiveJob::Base.queue_adapter = @adapter
    end

    def test_job_records_status
        job = TestJob.perform_later
        assert_equal job.job_status.job_name, 'TestJob'
        status_id = job.job_status.id
        status = Jobba.find(status_id)

        refute_same status, job.job_status
        assert_equal status.data, job.job_status.data
    end

    def test_queue_progress
        assert_no_enqueued_jobs
        job = TestJob.new
        perform_enqueued_jobs do
            assert_nil job.job_status
            job.enqueue
            assert_equal 'queued', job.job_status.state.name
            Thread.new do
                job.perform_now
            end
            sleep 0.1
            assert_equal 'started', job.job_status.state.name
            sleep 0.1
            assert_equal 'succeeded', job.job_status.state.name
        end
        job_status = Jobba.find(job.job_id)
        assert_equal 'succeeded', job_status.state.name
        assert_equal( {"output" => {"one" => 1}}, job_status.data )
    end

end
