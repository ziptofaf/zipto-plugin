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
    def index
      array = Array.new
      content = `tail /home/marcin/pieknylog/irc.txt` #this has to be changed eventually to application level setting!
      content.split(/\n/).each do |line|
        lines = line.split("::")
        key = {'name'=>lines[0].html_safe, 'content'=>sanitize(lines[1])}
        array.push(key)
      end
      array = array.to_json
      render json: array
    end

    private
    def sanitize(string)
      new_string = string.gsub(/[<>\\\/]/, '*')
      return new_string
    end
  end

  ZiptoIrcBot::Engine.routes.draw do
    get '/' => 'zipto_irc#index'
  end

  Discourse::Application.routes.append do
    mount ::ZiptoIrcBot::Engine, at: "/zipto_irc"
  end




end
