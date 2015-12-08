require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'gon-sinatra'
require './config/environments'
require './models/gps_data'
require './models/gpsx_parser'
require './models/gps_collection'
require './models/gps_coords'

enable :sessions

class Hashmapper < Sinatra::Base
  register Gon::Sinatra
  register Sinatra::Flash

  get '/' do
    @gps = GpsData.first
    gon.heat_data = (@gps ? @gps.data : [])
    erb :index
  end

  helpers do
    def bootstrap_class_for(flash_type)
      case flash_type
        when "success"
          "alert-success"   # Green
        when "error"
          "alert-danger"    # Red
        when "alert"
          "alert-warning"   # Yellow
        when "notice"
          "alert-info"      # Blue
        else
          flash_type.to_s
      end
    end
  end

  post '/upload' do
    collection = GpsData.first || GpsData.new
    result = collection.process_uploaded_files(params['files'])

    if result
      if result[:failure] > 0
        if result[:success] > 0
          flash[:alert] = 'Not all files were successfully loaded'
        else
          flash[:alert] = 'GPS data was not uploaded successfully.'
        end
      else
        flash[:success] = 'GPS data successfully uploaded.'
      end
    end
    redirect '/'
  end
end