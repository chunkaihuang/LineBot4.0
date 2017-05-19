require 'line/bot'

class LineBotService

  attr_accessor :client
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
    }
  end

  def reply_msg request
    body = request.body.read

    bot = LineBotService.new
    bot.varify_signature(request)

    return_msg = ''
    events = client.parse_events_from(body)
    events.each { |event|
      if event.message['text'].downcase.include?('rand ce')
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text

            # 接收訊息後客製化回應訊息
            return_msg = bot.custom_message(event.message['text'])
            # 組成回覆字串
            message = bot.format_message(return_msg)
            # 回覆
            client.reply_message(event['replyToken'], message)

          when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
            response = client.get_message_content(event.message['id'])
            tf = Tempfile.open("content")
            tf.write(response.body)
          end
        end
      else
        break
      end
    }
    return return_msg
  end

  def format_message return_msg
    {
      type: 'text',
      text: return_msg
    }
  end

  def varify_signature request
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      # error 400 do 'Bad Request' end
      return_msg = '400 Bad Request'
      return '400 Bad Request'
    end
  end

  def custom_message receive_message=nil

    filename = ['evalcookie', 'frommide', 'lin', 'withgirl', 'towu'].sample(5).first

    # rand_line = rand(1..100)
    # str = ''
    # loop_index = 0
    # File.open("public/docs/#{filename}_utf8.txt", "r").each_line do |line|
    #   # loop_index = loop_index+1
    #   rand_line = rand(1..10)
    #   if line.size >= 6 && rand_line >= 8
    #     str = line
    #     break
    #   end
    # end
    str = ''
    (1..100).each do |i|
      sample_str = File.readlines("public/docs/#{filename}_utf8.txt").sample(10).first
      str = sample_str if sample_str.size >= 8
      break if str.size >= 8
    end

    return str
  end
end