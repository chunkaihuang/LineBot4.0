class BaseController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:callback]

	def index
	end

	def callback
		randnum = rand(1..100)
		if randnum <= 5
			msg = LineBotService.new.reply_msg(request)
			render plain: msg
		else
			render plain: randnum
		end
	end
end
