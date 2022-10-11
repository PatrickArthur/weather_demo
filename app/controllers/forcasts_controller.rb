class ForcastsController < ApplicationController
	def new
	end

	def search
		if validate_fields
			missing_fields = forcast_params.select {|k,v| v.empty?}.keys
			flash[:alert] = missing_fields.join(" ,") + " are required fields"
			redirect_to root_path
		else
			client = OpenWeather::Client.new(api_key: ENV["OPEN_WEATHER_API"])
			forcast = client.current_weather(forcast_params)
			if forcast.present?
				forcast_data = {temp: forcast.main.temp, max_temp: forcast.main.temp_max, min_temp: forcast.main.temp_min, zip_code: forcast_params[:zip_code]}
				redirect_to forcasts_path(forcast_data: forcast_data)
			else
				flash[:alert] = "There was an error processoing your forcast"
				redirect_to root_path
			end
		end
	end

	def display
		cache_string = "weather_data_#{params[:forcast_data][:zip_code]}"
		if Rails.cache.read(cache_string).nil?
			@forcast_data = {temp: params[:forcast_data][:temp], max_temp: params[:forcast_data][:temp_max], min_temp: params[:forcast_data][:temp_min]}
			Rails.cache.fetch(cache_string, expires_in: 30.minutes) do
				@forcast_data
			end
			@forcast_data[:from_cache] = false
		else
			@forcast_data = Rails.cache.read(cache_string)
			@forcast_data[:from_cache] = true
		end
		@forcast_data
	end

	private

	def forcast_params
		params.except(:authenticity_token, :commit).permit(:address, :city, :state, :country, :zip_code)
	end

	def validate_fields
		params.values_at(:address, :city, :state, :country, :zip_code).uniq.include? ""
	end
end