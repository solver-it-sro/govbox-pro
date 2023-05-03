class SubmissionsController < ApplicationController
  def index
    @submissions = Current.subject.submissions
  end

  def show
    @submission = Submission.find(params[:id])
  end

  def destroy
    Submission.find(params[:id]).destroy

    redirect_to submissions_path
  end

  def destroy_all
    Current.subject.submission_packages.destroy_all
    Current.subject.submissions.destroy_all

    redirect_to submissions_path
  end

  def submit
    @submission = Submission.find(params[:submission_id])
    mark_submission_as_being_submitted(@submission)

    Submissions::SubmitJob.perform_later(@submission)
  end

  private

  def mark_submission_as_being_submitted(submission)
    Submission.transaction do
      submission.update(status: 'being_submitted')
    end
  end
end
