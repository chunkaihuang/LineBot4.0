require 'line/bot'

class LineBotService

  # Check_Array ||= ['-help', '-ar', '-ap', '-av', '-en', '-gay', '-kila']
  Files ||= ['evalcookie', 'frommide', 'lin', 'withgirl', 'towu']
  MATCH_STRING ||= ['竣宇', '俊宇', '小護士', '高果', '承洋', '餅乾', '彥廷', '蛙人', '人渣', '阿鄙']

  attr_accessor :client
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['CHANNEL_SECRET']
      config.channel_token = ENV['CHANNEL_TOKEN']
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
            return_msg = bot.random_message(msg, bot)
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

  def carousel_format return_msg=nil
    imgs = Dir.entries("public/imgs/kila/")
    imgs.delete('.')
    imgs.delete('..')
    columns = []
    imgs.sample(5).each_with_index do |img, index|
      columns << {
            thumbnailImageUrl: "https://ayumi9487.herokuapp.com/imgs/kila/#{img}",
            title: "kila交往",
            text: "文件#{index+1}",
            actions: [
              {
                type: "uri",
                label: "查看",
                uri: "https://ayumi9487.herokuapp.com/imgs/kila/#{img}"
              },
            ]
          }
    end
    {
      type: "template",
      altText: "this is a carousel template",
      template: {
        type: "carousel",
        columns: columns
      }
    }
    # {
    #   type: "template",
    #   altText: "this is a carousel template",
    #   template: {
    #     type: "carousel",
    #     columns: [
    #       {
    #         thumbnailImageUrl: "https://ayumi9487.herokuapp.com/imgs/kila/1465367218542.png",
    #         title: "kila交往",
    #         text: "文件1",
    #         actions: [
    #           {
    #             type: "uri",
    #             label: "查看",
    #             uri: "https://ayumi9487.herokuapp.com/imgs/kila/1465367218542.png",
    #           },
    #         ]
    #       },
    #       {
    #         thumbnailImageUrl: "https://ayumi9487.herokuapp.com/imgs/kila/1465367218542.png",
    #         title: "kila交往",
    #         text: "文件1",
    #         actions: [
    #           {
    #             type: "uri",
    #             label: "查看",
    #             uri: "https://ayumi9487.herokuapp.com/imgs/kila/1465367218542.png",
    #           },
    #         ]
    #       }
    #     ]
    #   }
    # }
  end

  def button_format
    {
      type: "template",
      altText: "this is a confirm template",
      template: {
        type: "confirm",
        text: "我是一位工程師？",
        actions: [
          {
            type: "message",
            label: "是",
            text: "你也懂我"
          },
          {
            type: "message",
            label: "不是",
            text: "哪有這樣子的啊..."
          }
        ]
      }
    }
  end

  def msg_varify! msg
    # return true if Check_Array.any? { |c| msg.include?(c) }
    true
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
    # case receive_message
    # when /-help/
    #   str = "白痴廢物智障靠爸人渣使用方式：\n"+
    #         "-help 查看所有指令\n"+
    #         "-ar 隨機文字\n"+"-ap(文字) 搜尋指定文字\n"+
    #         "-av 讚貼圖\n"+
    #         "-en 問題\n"+
    #         "-gay 甲霸承洋\n"
    #   message = bot.text_format(str)
    # when /-ar/
    #   file = Files.sample
    #   str = ''
    #   (1..100).each do |i|
    #     sample_str = File.readlines("public/docs/#{file}_utf8.txt").sample
    #     str = sample_str if sample_str.size >= 8
    #     break if str.size >= 8
    #   end
    #   message = bot.text_format(str)
    # when /-ap/
    #   search_string = receive_message.gsub!("-ap(", "")
    #   search_string = search_string.gsub!(")", "")
    #   target_array = []
    #   Files.each do |file|
    #     str_array = File.foreach("public/docs/#{file}_utf8.txt").grep(/#{search_string}/)
    #     # str += "\n檔名：#{file}\n\n" if str_array.present?
    #     str_array.each do |target_str|
    #       target_array << target_str
    #     end
    #   end
    #   str = target_array.sample
    #   message = bot.text_format(str)
    # when /-av/
    #   message = bot.image_format
    # when /-en/
    #   message = bot.button_format
    # when /-gay/
    #   gays = ['當Gay也不錯', '總之承洋你開心最重要 我才放心 再造成你困擾我該切老二哈了', '當Gay比較好']
    #   str = gays.sample
    #   message = bot.text_format(str)
    # when /-kila/
    #   message = bot.carousel_format
    # else
    # end
  end

  def random_message receive_message=nil, bot
    str = ''
    search_string = ''
    if MATCH_STRING.any? { |s| receive_message.include?(s); search_string = s if receive_message.include?(s); }
      randnum = rand(1..100)
      if randnum <= 10
        target_array = []
        Files.each do |file|
          str_array = File.foreach("public/docs/#{file}_utf8.txt").grep(/#{search_string}/)
          str_array.each do |target_str|
            target_array << target_str
          end
        end
        str = target_array.sample
      else
        str = ''
      end
    else
      randnum = rand(1..100)
      if randnum <= 5
        file = Files.sample
        (1..100).each do |i|
          sample_str = File.readlines("public/docs/#{file}_utf8.txt").sample
          str = sample_str if sample_str.size >= 8
          break if str.size >= 8
        end
      else
        str = ''
      end
    end
    message = bot.text_format(str)
    return message
  end
end