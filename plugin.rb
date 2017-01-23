# name: zipto-plugin
# about: A plugin extending original capabilities of Discourse via few QoL updates
# version: 0.0.1
# authors: ziptofaf


after_initialize do

  module ::ZiptoIrcBot
    class Engine < ::Rails::Engine
      engine_name "zipto_irc_bot"
      isolate_namespace ZiptoIrcBot
    end
  end
  require_dependency 'application_controller'
  class ZiptoIrcBot::ZiptoIrcController < ::ApplicationController
    skip_before_action :verify_authenticity_token #kinda necessary since we will play with external services

    def addToQueue #adds a message to the queue
      status = {'status'=>'unauthorized'} #default status
      queue = setQueue
      render json: status.to_json and return unless current_user
      user = current_user.username
      time = Time.new
      status['status']='invalid_entry'
      render json: status.to_json and return unless params[:message]
      message = sanitize(params[:message])
      queue.push("#{user} - #{message}")
      status['status']='success'
      PluginStore.set("irc_queue", 0, queue)
      render json: status.to_json
    end

    def popFromQueue #pops one from queue
      jsonResponse = {'permission'=>'false'}
      queue = setQueue
      key = SiteSetting.zipto_irc_queue_key
      render json: jsonResponse and return unless params[:key] and params[:key]== key
      jsonResponse['permission']='true'
      if queue.length == 0
        jsonResponse['message']=''
        render json: jsonResponse
        return
      end
      jsonResponse['message'] = queue[0]
      queue.delete_at(0)
      PluginStore.set("irc_queue", 0, queue)
      render json: jsonResponse.to_json
      return
    end

    def setQueue #if queue doesnt exist yet - create it
      queue = PluginStore.get("irc_queue", 0)
      if queue
      else
        PluginStore.set("irc_queue", 0, Array.new)
        queue = PluginStore.get("irc_queue", 0)
      end
      return queue
    end

    def saveIrcState
      array = Array.new
      content = `tail #{SiteSetting.zipto_irc_resource_hook_url}`
      content.split(/\n/).each do |line|
        lines = line.split("::")
        key = {'name'=>lines[0].html_safe, 'content'=>sanitize(lines[1])}
        array.push(key)
      end
      array = array.to_json
      PluginStore.set("irc_log", 0, array)
      PluginStore.set("irc_log", 1, Time.now)
    end

    def loadIrcState
      getIrcState
      return PluginStore.get('irc_log', 0)
    end

    def getIrcState
      modify_date = PluginStore.get('irc_log', 1)
      if !modify_date
        saveIrcState
      else
        if modify_date < 5.seconds.ago
          saveIrcState
        end
      end
    end

    def index
      render json: loadIrcState
    end

    private
    def sanitize(string)
      new_string = string.gsub(/[<>\\]/, '*')
      return new_string
    end
  end

  ZiptoIrcBot::Engine.routes.draw do
    get '/' => 'zipto_irc#index'
    post '/push' => 'zipto_irc#addToQueue'
    post '/pop' => 'zipto_irc#popFromQueue'
  end

  Discourse::Application.routes.append do
    mount ::ZiptoIrcBot::Engine, at: "/zipto_irc"
  end


end
