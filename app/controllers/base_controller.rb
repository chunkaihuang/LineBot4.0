class BaseController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:callback]

	def index
	end

	def callback
		if rand(1..100) <= 3
			msg = LineBotService.new.reply_msg(request)
			render plain: msg
		else
			render plain: ''
		end
	end
end
