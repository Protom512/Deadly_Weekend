class TopController < ApplicationController
  skip_before_action :authenticate

   DOC_API_KEY = '2f504e697546696a4a454c6871326361636743386f35314974763671304a56544850304536795066434339'
    require 'twitter'
    require 'net/http'
    require 'uri'
  # トップ
  def index
    client = Twitter::REST::Client.new do |config|
      # applicationの設定
      config.consumer_key         = Settings.twitter_key
      config.consumer_secret      = Settings.twitter_secret
      # ユーザー情報の設定
      user_auth = current_user.authentications.first
      config.access_token         = user_auth.token
      config.access_token_secret  = user_auth.secret
    end
    @timeline=client.mentions_timeline(:count => 2).each do |tweet|
      @array = Array.new
      @total_array = Array.new
      text = tweet.full_text
      @array = [text]
      # p @array
    end
  end

  #tweet
  def tweet
    client = Twitter::REST::Client.new do |config|
      config.consumer_key         = Settings.twitter_key
      config.consumer_secret      = Settings.twitter_secret
      user_auth = current_user.authentications.first
      config.access_token         = user_auth.token
      config.access_token_secret  = user_auth.secret
    end
    # Twitter投稿
    result=client.update(params[:text])
    p "testing "
    p result.id
    sleep(2)

    endpoint = URI.parse('https://api.apigw.smt.docomo.ne.jp/voiceText/v1/textToSpeech')
    endpoint.query = 'APIKEY=' + DOC_API_KEY

    reply=client.mentions_timeline(:count => 1).each do |tweet|
      p tweet.text
      replied_id=tweet.in_reply_to_status_id
      p replied_id
      if replied_id == result.id
        p "has reply"
         text="うるさいよ"
        filename="urusaiyo.wav"
      else
        p "no reply"
        text="うるさいよ"
        filename="urusaiyo.wav"
      end
      request_body = {
      'text'=>text,
      'speaker'=>'hikari'
    }
    res = Net::HTTP.post_form(endpoint, request_body)
    case res
    when Net::HTTPSuccess
      file_name = filename
      File.binwrite(file_name, res.body)
      `afplay docomo.wav` # Linuxならaplayやmpg123を使う
      File.delete(file_name)
    else
      res.value
    end
    end
    redirect_to root_path
  end
end
