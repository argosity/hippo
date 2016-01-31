require 'jobba'
require 'lanes/api/pub_sub'

module Jobba
    module RecordStatus

        def self.included(klass)
            klass.send(:attr_reader, :job_status)
            klass.around_enqueue do |job, block|
                @job_status = Jobba.find!(job.job_id)
                @job_status.set_job_name(self.class.to_s)
                @job_status.unqueued!
                block.call
                @job_status.queued!
            end
            klass.around_perform do |job, block|
                # we use find! so it will create a record of the job even if
                # it's created using perform_now.  In that case the enqueue step's skipped
                @job_status = Jobba.find!(job.job_id)
                @job_status.started!
                block.call
                @job_status.succeeded!
            end
        end

    end
end

module Lanes

    # A job in lanes is identical to a ActiveJob::Base job, except it records it's
    # status using the Jobba::Status mixin module
    class Job < ::ActiveJob::Base

        after_perform{ |job|
            job.deliver_progress_to_clients
        }

        def deliver_progress_to_clients
            API::PubSub.publish("/lanes/job-statuses/#{job_id}", update: Job.status_for_id(job_id))
        end

        def save_progress(output, progress=1.0)
            job_status.set_progress(progress)
            job_status.save(output: output)
            deliver_progress_to_clients
        end

        def self.status_for_id(id)
            status = Jobba.find(id)
            return nil unless status
            {
                id:          status.id,
                job_name:    status.job_name,
                progress:    status.progress,
                attempt:     status.attempt,
                state:       status.state.name,
                recorded_at: status.recorded_at,
                queued_at:   status.queued_at,
                errors:      status.errors,
                data:        status.data
            }
        end

        def self.api_status_message(job, message="Job started")
            return {
                success: true, message: message, data: {
                    job: Lanes::Job.status_for_id(job.job_id)
                }
            }
        end

        include Jobba::RecordStatus
    end



end
