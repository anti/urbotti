class Worldcup
  include Cinch::Plugin

  match /!worldcup/, :method => :worldcup
  match /!wc/, :method => :worldcup

  def worldcup(m)
    content = open("http://worldcup.sfg.io/matches/today").read
    matches = JSON.parse(content)

    future = []
    in_progress = []
    completed = []

    matches = matches.sort_by { |m| m["datetime"] }

    matches.each do |match|
      home = match["home_team"]
      away = match["away_team"]

      time = (Time.parse(match['datetime']).localtime)

      # this doesn't work!
      if match["status"] == "in progress"
        duration = ((Time.now - time) / 60).to_i
        played = duration

        if duration > 45 && duration < 60
          played = 45
        elsif duration > 60
          played = duration - 15
        end

        string = "#{home['code']} - #{away['code']} (#{home['goals']}-#{away['goals']}) @ #{played} min"
        in_progress << string
      elsif match["status"] == "future"
        string = "#{home['country']} - #{away['country']} @ #{time.strftime('%H:%M')}"
        future << string
      elsif match["status"] == "completed"
        string = "#{home['code']} - #{away['code']} (#{home['goals']}-#{away['goals']})"
        completed << string
      end
    end

    m.reply "Live: #{in_progress.join(' | ')}" unless in_progress.empty?
    m.reply "Next: #{future.join(' | ')}" unless future.empty?
    m.reply "Completed: #{completed.join(' | ')}" unless completed.empty?

  end

end
