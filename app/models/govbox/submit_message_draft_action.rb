class Govbox::SubmitMessageDraftAction
  def self.run(message, jobs_batch: nil)
    is_submittable = message.submittable?

    if is_submittable
      if jobs_batch
        jobs_batch.add { Govbox::SubmitMessageDraftJob.perform_later(message, schedule_sync: false) }
      else
        Govbox::SubmitMessageDraftJob.perform_later(message)
      end

      message.being_submitted!
    end

    is_submittable
  end
end
