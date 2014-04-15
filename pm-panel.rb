require 'rubygems'
require 'sinatra'
require 'json'
require "minecraft-query"
require "rcon/rcon"


@@cfg = { 'server' => '54.197.243.168', 'port' => '19132' }

@@rcon = RCON::Minecraft.new(@@cfg['server'], @@cfg['port'])
@@rcon.auth('f86f136e8c7543fcecc03cddd3736555af5346fa')


get '/' do
    halt 404
end

get '/server/:action' do
    case params[:action]

    when 'restart'
        "OUTPUT"

    when 'pid'
        "pid"

    end
end

get '/status/:option' do
    content_type :json

    case params[:option]

    when 'time'
        regex = /Time: ([0-9:]*), ([a-zA-Z]*)/
        timestring = @@rcon.command("time check")
        timeinfo = timestring.force_encoding('UTF-8').split(regex)
        time ||= {}
        time['game'] = timeinfo[1]
        time['server'] = Time.now
        time['state'] = timeinfo[2]
        body time.to_json

    when 'version'
        regex = /PocketMine-MP\ ([^\ ]*)\ (.*)API #([0-9]*) for Minecraft: PE v([0-9\.]*)[^#]*#(.*)/
        versionstring = @@rcon.command("version")
        versioninfo = versionstring.force_encoding('UTF-8').split(regex)
        version ||= {}
        version["api"] = versioninfo[3]        
        version["server"] = versioninfo[1]
        version["client"] = versioninfo[4]
        version["protocol"] = versioninfo[5]
        version["raw"] = versionstring
        version.to_json

    when 'plugins'
        regex = /Plugins: (.*)/
        string = @@rcon.command("plugins")
        pluginlist = string.force_encoding('UTF-8').split(regex)[1].split(", ")
        plugins ||= []
        pluginlist.inspect
        pluginlist.each do |plugin|
            info = plugin.split(': ')
            plugins << { "name" => info[0], "version" => info[1] }
        end
        body plugins.to_json

    else
        @@rcon.command(params[:option]).force_encoding('UTF-8').to_json
    end

end

not_found do
    'Page Not Found'
end

