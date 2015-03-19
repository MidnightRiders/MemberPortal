class DownloadsController < ApplicationController
  def show
    authorize! :show, :download
    filename = Rails.root.join('private', params[:filename] + '.' + params[:format])
    if File.file? filename
      File.open filename, 'rb' do |f|
        send_data f.read
      end
    else
      redirect_to root_path, alert: 'No such file exists: ' + filename.to_s
    end
  end
end
