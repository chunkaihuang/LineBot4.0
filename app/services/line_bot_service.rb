# app.rb
require 'line/bot'

class LineBotService

  def initialize
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
    }
  end

  def reply_msg request
    body = request.body.read

    @return_mag = "QQ"

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless @client.validate_signature(body, signature)
      # error 400 do 'Bad Request' end
      @return_mag = '400 Bad Request'
      return '400 Bad Request'
    end

    events = @client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # message = {
          #   type: 'text',
          #   text: event.message['text']
          # }
          @return_mag = ""
          case event.message['text']
          when "..."
            @return_mag = "你現在是要教訓我嗎= ="
          when "請問你是" || "職業"
            @return_mag = "我是一位工程師。"
          else
            @return_mag = "不要再講了辣..."
          end
          message = {
            type: 'text',
            text: @return_mag
          }
          
          puts "回傳訊息: #{@return_mag}"
          puts "token: #{event['replyToken']}"
            
          msg = @client.reply_message(event['replyToken'], message)
          puts "line回傳：#{msg}"
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = @client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }

    "OK"
    return @return_mag
  end
end