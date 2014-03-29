require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'watir-webdriver'
require	'pp'
class Show
	attr_accessor :show_name, :plot, :seasons, :episodes

	def initialize
		@show_name 	= {}
		@plot 		= ""
		@seasons 	= {}
		@episodes 	= {}
		
	end

	
end


#web page doers*********************************************************************************************
def parse_a_page(html_path)
page = Nokogiri::HTML(open(html_path))
# puts page
 page
end


def open_a_page(page)
# brows = Watir::Browser.new
# puts "\t\t\topening...."
# brows.goto page
`start #{page}`
end

def search_freetv(name)
	space(3)
puts "getting...... #{name}.....yah!"
		if name.include?(" ")
			term = name.gsub!(/\W/,"_") 
		else
			term = name
		end
		#http://www.free-tv-video-online.me/internet/game_of_thrones/
		search = "http://www.free-tv-video-online.me/internet/#{term}/"
		# p "in search free"
		# p search
		# p "out serch free"
		search
end


#page parsing*******************************************************************************************
def parse_with(page,select)
	parsed_page = ''
	
	#puts page
	case select
		when 1 #
			parsed_page = page.css("iframe#hmovie")[0]["src"]
		when 2
			#gets the plot
			
			parsed_page = page.css("div#plot").text
			
		
		when 3
			# gets the seasons
			parsed_page = page.css('td')

		when 4
			
			parsed_page = page.css('td[class="mnllinklist dotted"]')
		when 5
		

		else
			puts "thats not a choice"
	end

	parsed_page
end

#interaction***************************************************************************************************

def what_show_to_watch
	space(15)
	puts "\t\twhat show would you like to watch?"
	space(1)
	puts "\t\t\tor choose from a list type \'cho\'"
	space('std2')
	show_doer
	
end

def see_all_questions(*show_name)
	headings("Main Menue")
	space(3)
	puts "\t___ #{show_name.join} _____________"
	space(3)
	choice_ask("pick a show","pi")
	choice_ask("seasons","se")
	choice_ask("plot", "pl")
	space("std2")
end
def see_all_seasons(show_object)
	space(16)
	puts "\t___ #{show_object.show_name.keys*''} _____________\n\n"
	seas = show_object.seasons
				i = 1
					seas.each do |key, value|
						choice_ask(key,i)
						i += 1
					end
	space("std2")
end
def see_all_episodes(season,show_object)
	space(10)
	puts "\t#{show_object.show_name.keys*''}\n\n"
	puts "\t\t___ #{season} _____________\n\n"
	show_object.episodes[season].each_key do |key|

		puts "\t\t#{key}        -type #{key.to_s[-4..-1].gsub(/\D/,'')}"
	end
	space("std1")
end

def see_all_ep_links(season, episode, show_object)
	space(10)
	puts "\t#{show_object.show_name.keys*''}\n\n"

	puts "\t\t___ #{season} _____________\n\n"

		speed = link_speed_chooser
	i = 0
	show_object.episodes[season][episode].each_key do |key|
		#puts key 
		puts "\t\t#{key}        -type #{i}" if key.include?(speed)
		i += 1
		#gets
	end
	#puts "in see all ep out of loop"
	space("std1")
	
end

def link_speed_chooser
	choice_ask("show fast links?", "f")
	choice_ask("show average links?", "a")
	choice_ask("show slow links?","s")
	space('std2')
	speed = ''
	choice = gets.chomp
	case choice
	when 'f'
		speed = "Fast"
	when 'a'
		speed = "Average"
	when 's'
		speed = "Slow"
	end
	speed
end

#main processing***********************************************************************************************

def show_doer
	
	show_name 	= gets.chomp
	if show_name == "cho"



	else
		show		= processor(show_name)
	
		if show.plot.empty?
			what_show_to_watch
		else
			new_one		= 0
			until new_one == 1
				see_all_questions(show_name)
				new_one = main_chooser(show)
			end
		end
	end
end

def main_chooser(show_object)
	choice = gets.chomp
	case choice
		when "pi"
			new_one = 1
		when "se"
			go_back = ''
			until go_back == 'st' || go_back == 'b' || go_back == nil
				see_all_seasons(show_object)
				go_back = season_getter(show_object)
			end

		when "pl"
			space(5)
			puts "\tPlot:\n\n"
			puts show_object.plot
			gets
	end
	return new_one if new_one == 1
end


def processor(the_show_name)
		the_show = Show.new 

		show_url = search_freetv(the_show_name)

		the_show.show_name[the_show_name] = show_url
		
		get_plot(show_url,the_show)
	
		get_seasons(show_url,the_show)
end


def season_getter(show_object)
	go_back = ''
	
	until go_back == 'b'
		
		choice = gets.chomp
		if choice.to_i <= show_object.seasons.keys.count
			break if choice == 'b' || choice == nil || choice == 'st'
			get_choice = "season_#{choice}"
			episodes = get_episodes(show_object.seasons[get_choice])
			show_object.episodes[get_choice] = episodes

			see_all_episodes(get_choice,show_object)
			#puts "in season getter"
			choose_episode_links(get_choice, show_object)	
		end
		

	end
	go_back = 'st' if choice == 'st'
	go_back
end
def get_plot(html_path,show_object)
	html = parse_a_page(html_path)
	show_object.plot = parse_with(html,2)
	# puts "in get plot"
	# p show_object
	# puts "out plot"
	show_object	
end



#html_path = "http://www.free-tv-video-online.me/internet/game_of_thrones/"
def get_seasons(html_path,show_object)
	show_object
	page = parse_a_page(html_path)
	td_page =  parse_with(page,3)
	#puts td_page
	broken = td_page.to_s.split(" ").uniq


	broken.each do |line|
		if line.include?('season')
			season_single = line.scan(/(?<=").*(?=")/)
				john = html_path + season_single.join
			show_object.seasons[season_single.join.gsub(/.html/,"")] = john
		end
	end


	puts "end"
	show_object
end

def get_episodes(html_path)
	#show_object
	page = parse_a_page(html_path)
	td_page =  parse_with(page,4)
	episode_links = {}
	#ep_links = {}	
	current_title = ''
	broken = td_page.to_s.split("Stream").uniq


		broken.each do |line|

				dom = Nokogiri.HTML(line)
					elements = dom.at_xpath '//td'
						links = dom.xpath('//td/a/@href')[0]
					title = dom.xpath('//td/a/div/text()')

				break if elements == nil

				episode_links[title.to_s] = Hash.new if title.to_s != current_title
			episode_links[title.to_s][elements.text.gsub(/\t/," ")] = links.to_s if elements.text.include?("#{title.to_s}")
			current_title = title.to_s
		end



	episode_links
end

def choose_episode_links(season,show_object)
	#puts "in choose episode"
	go_back = ''
	unless go_back == 'b' 
		choice = gets.chomp
		#break if choice == 'b' || go_back == nil
		if choice == nil
		else
			puts "choose episode links"
			epi = ""
			i = show_object.episodes[season].keys.first[-4..-1].gsub(/\D/,"").to_i
			show_object.episodes[season].each_key do |key|
			
				epi = key if i == choice.to_i
				i += 1
			end
			see_all_ep_links(season, epi, show_object)
			get_ep_link_link(season, epi, show_object)
			puts "end of choose ep links"
		end
		go_back = 'b' if choice == 'b' 
	end
	go_back
end

def get_ep_link_link(season, epi, show_object)

	get_choice_link = gets.chomp
	choice_link 	= ''
	i = 0
	show_object.episodes[season][epi].each do |key,value|
		#puts key 
		if get_choice_link.to_i == i
			space('std1')
		
		puts "\t\t#{key}"
		puts "\t#{value}"
		choice_link = value
		space('std2')
		#parsed_value = parse_a_page(value)
		#open_a_page(value)
		puts "here all"
		
		player =  get_iframe(value)
		open_a_page(player)
		end    

		i += 1
		#gets
	end
end

def get_iframe(value)
	dom = Nokogiri::HTML(open(value))
	#puts dom
	iframe_link = dom.css('iframe')[0]["src"]
	iframe_link
end
#get_seasons(html_path)

#style elements*******************************************************************************************

	# headings creats consistent heading lengths through each screen
	def headings(name)
		head_length_remove = name.to_s.length/2
		heading = "________________________________   #{name}   ________________________________"
		puts "\n\n"+ "  " + heading[head_length_remove..(head_length_remove*-1)] + "\n\n\n\n"
	end
	# choice_ask creates consistent placement of choices and input optoins on each screen
	def choice_ask(choices, input_option)
		space = "                           "
		in_opt = "- type '#{input_option.to_s}'\n\n"
		choice = "\t#{choices.to_s}"
		new_space = space[choice.length..space.length]
		your_choice = choice + new_space + in_opt
		puts your_choice 
	end

	#this gives opetional standard spacing for printed strings
	def space(standard_or_number_of_times)
		space ="\n"
		tab = "\t"
		case standard_or_number_of_times
			when 'std1'
				3.times{puts space}
			when 'std2'
				9.times{puts space}
			when 'tab1'
				2.times{puts tab}
			else
				standard_or_number_of_times.times{puts space}
			end
	end


def start
what_show_to_watch
start 
end

start




#html_path = "http://www.google.com"#{}"http://www.free-tv-video-online.me/player/movshare.php?id=48f93311e51e6"

#open_a_page(html_path)