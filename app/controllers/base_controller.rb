class BaseController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:callback]
	before_action :count_random_num, only: [:callback]

	def index
	end

	def callback
		msg = LineBotService.new.reply_msg(request)
		render plain: msg
	end

	private
		def count_random_num
			rand(1..100) <= 3
		end
	# 	def varify_line_message
			
	# 	end
end
