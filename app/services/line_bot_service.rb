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
      if bot.msg_varify!(msg)
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text

            # 接收訊息後客製化回應訊息
            return_msg = bot.custom_message(msg, bot)
            # 回覆
            client.reply_message(event['replyToken'], return_msg)

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

  def text_format return_msg
    {
      type: 'text',
      text: return_msg
    }
  end

  def image_format return_msg=nil
    {
      type: 'sticker',
      packageId: 1,
      stickerId: 13,
    }
  end

  def msg_varify! msg
    check_array = ['-ar', '-ap', '-av']
    return true if check_array.any? { |c| c.include? msg }
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

  def custom_message receive_message=nil, bot
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
      message = bot.text_format(str)
    when /-ap/
      search_string = receive_message.gsub!("-ap(", "")
      search_string = search_string.gsub!(")", "")
      target_array = []
      files.each do |file|
        str_array = File.foreach("public/docs/#{file}_utf8.txt").grep(/#{search_string}/)
        # str += "\n檔名：#{file}\n\n" if str_array.present?
        str_array.each do |target_str|
          target_array << target_str
        end
      end
      str = target_array.sample
      message = bot.text_format(str)
    when /-av/
      message = bot.image_format(str)
    end
    return str
  end
end