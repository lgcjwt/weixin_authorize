require "rest-client"

require "carrierwave"
require "weixin_authorize/carrierwave/weixin_uploader"

require 'yajl/json_gem'

require "weixin_authorize/config"
require "weixin_authorize/handler"
require "weixin_authorize/api"
require "weixin_authorize/client"

module WeixinAuthorize

  # Storage
  autoload(:Storage,       "weixin_authorize/adapter/storage")
  autoload(:ClientStorage, "weixin_authorize/adapter/client_storage")
  autoload(:RedisStorage,  "weixin_authorize/adapter/redis_storage")

  OK_MSG     = "ok".freeze
  OK_CODE    = 0.freeze
  GRANT_TYPE = "client_credential".freeze
  UDESK_PROXY = !ENV["UDESK_PROXY"].nil?

  class << self

    def http_get_without_token(url, headers={}, endpoint="plain")
      get_api_url = endpoint_url(endpoint, url)
      load_json(RestClient.get(get_api_url, :params => headers))
    end

    def http_post_without_token(url, payload={}, headers={}, endpoint="plain")
      post_api_url = endpoint_url(endpoint, url)
      payload = JSON.dump(payload) if endpoint == "plain" # to json if invoke "plain"
      load_json(RestClient.post(post_api_url, payload, :params => headers))
    end

    # return hash
    def load_json(string)
      result_hash = JSON.parse(string)
      code   = result_hash.delete("errcode")
      en_msg = result_hash.delete("errmsg")
      ResultHandler.new(code, en_msg, result_hash)
    end

    def endpoint_url(endpoint, url)
      send("#{endpoint}_endpoint") + url
    end

    def plain_endpoint
      UDESK_PROXY ? \
        "http://api.weixin.udesk.cn:9001/cgi-bin" : \
        "https://api.weixin.qq.com/cgi-bin"
    end

    def file_endpoint
      UDESK_PROXY ? \
        "http://file.api.weixin.udesk.cn:9002/cgi-bin" : \
        "https://file.api.weixin.qq.com/cgi-bin"
    end

    def mp_endpoint(url)
      UDESK_PROXY ? \
        "http://mp.weixin.udesk.cn:9003/cgi-bin#{url}" : \
        "https://mp.weixin.qq.com/cgi-bin#{url}"
    end

  end

end
