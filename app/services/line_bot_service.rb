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
      msg = event.message['text'].downcase
      if msg.include?('-ar') || msg.include?('-ap')
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text

            # 接收訊息後客製化回應訊息
            return_msg = bot.custom_message(msg)
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
    str = ''
    files = ['evalcookie', 'frommide', 'lin', 'withgirl', 'towu']
    case receive_message
    when /-ar/
      file = files.sample
      str = ''
      (1..100).each do |i|
        sample_str = File.readlines("public/docs/#{file}_utf8.txt").sample
        str = sample_str if sample_str.size >= 8
        break if str.size >= 8
      end
    when /-ap/
      search_string = receive_message.gsub!('-ap (', '')
      search_string = receive_message.gsub!(')', '')
      files.each do |file|
        File.foreach("public/docs/#{file}_utf8.txt") do |file|
          str = str + file.grep(/#{search_string}/)
        end
      end
    end
    return str
  end
end