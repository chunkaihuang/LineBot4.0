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

          @return_mag = ""
          case event.message['text']
          when /蛙人/, /蛙人渣/, /陳蛙興/
            @return_mag = "比陳進興那些殺人犯還要不如的爛貨！"
          when /蔡竣宇/, /小護士/
            @return_mag = "你們可以自己仔細思考看看，他的這種惡劣行為大概比殺人在緩和一點而已！"
          else
            ''
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