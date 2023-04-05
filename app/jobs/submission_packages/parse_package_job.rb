require 'csv'

class SubmissionPackages::ParsePackageJob < ApplicationJob
  queue_as :high_priority

  class << self
    delegate :uuid, to: SecureRandom
  end

  def perform(package, package_zip_path, load_submission_content_job: Submissions::LoadSubmissionContentJob)
    extracted_package_path = File.join(Utils.file_directory(package_zip_path), File.basename(package_zip_path, ".*"))
    system("unzip", package_zip_path, '-d', extracted_package_path)

    csv_paths = Dir[extracted_package_path + "/*.csv"]

    raise "Package must contain 1 CSV file!" if csv_paths.size != 1

    submissions_list = load_package_csv(package, csv_paths.first)

    Dir.each_child(extracted_package_path) do |entry_name|
      if Utils.directory?(entry_name)
        submission = Submission.find_or_create_by(
          package_id: package.id,
          package_subfolder: File.basename(entry_name)
        )

        load_submission_content_job.perform_later(submission, File.join(extracted_package_path, entry_name))
      end
    end

    package.update(status: 'parsed')
    submissions_list.each do |submission|
      submission.update(status: 'created')
    end

  rescue StandardError
    # TODO Send notification
    # TODO Delete package
  end

  private

  CSV_OPTIONS = {
    encoding: 'UTF-8',
    col_sep: ',',
    headers: true
  }

  def load_package_csv(package, csv_path)
    submissions_list = []

    CSV.parse(File.read(csv_path), **CSV_OPTIONS) do |row|
      submissions_list << Submission.create!(
        package_id: package.id,
        package_subfolder: row['subfolder'],
        recipient_uri: row['recipient_uri'],
        posp_id: row['posp_id'],
        posp_version: row['posp_version'],
        message_type: row['message_type'],
        message_subject: row['message_subject'],
        sender_business_reference: row['sender_business_reference'],
        recipient_business_reference: row['recipient_business_reference'],
        message_id: uuid,
        correlation_id: uuid
      )
    end

    submissions_list
  end

  delegate :uuid, to: self
end
