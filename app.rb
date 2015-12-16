require 'sinatra'
require 'sinatra/activerecord'
require 'rack-flash'
require 'gon-sinatra'
require './config/environments'
require './models/gps_data'
require './models/gpsx_parser'
require './models/gps_collection'
require './models/gps_coords'


class Hashmapper < Sinatra::Base
  enable :sessions
  register Gon::Sinatra

  get '/' do
    @gps = GpsData.first
    gon.heat_data = (@gps ? @gps.data : [])
    erb :index
  end

  helpers do
    def flash(key=:flash)
      result = {}
      if session
        result = session.delete(key) if session.key? key
      end
      result
    end

    def flash_peek(key=:flash)
      session[key]
    end

    def bootstrap_class_for(flash_type)
      case flash_type.to_s
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

  get '/' do
    @gps = GpsData.first
    gon.heat_data = (@gps ? @gps.data : [])
    erb :index
  end

  post '/upload' do
    collection = GpsData.first || GpsData.new
    result = collection.process_uploaded_files(params['files'])

    if result
      session[:flash] = {}
      if result[:failure] > 0
        if result[:success] > 0
          session[:flash][:alert] = 'Not all files were successfully loaded'
        else
          session[:flash][:danger] = 'GPS data was not uploaded successfully.'
        end
      else
        session[:flash][:success] =  'GPS data successfully uploaded.'
      end
    end
    redirect '/'
  end
end