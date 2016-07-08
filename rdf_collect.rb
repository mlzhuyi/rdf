require 'open-uri'
require 'nokogiri'
require "rexml/document" 

file = File.new("test1.xml","w+") 
xml = REXML::Document.new
ele = xml.add_element 'rdf:RDF'
ele.add_namespace "rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
ele.add_namespace "team", "http://wangyi.com/team#"
ele.add_namespace "player", "http://wangyi.com/player#"
ele.add_namespace "match", "http://wangyi.com/match#"
ele.add_namespace "data", "http://wangyi.com/data/"

num=[49,39,51,54,68]
num.each do |num|
  q=20 if num!=49
  q=18 if num==49

  uri="http://goal.sports.163.com/#{num}/stat/standings/2015_3.html"
	doc = Nokogiri::HTML(open(uri))
	doc.xpath("//table[@class='daTb01']/tr").each_with_index do|val,key|
    if key.between?(1,q)
      i=0
      m=""
      team_attr =["","","","场次","胜","负","平","进球","失球","净胜球","","积分"]
      val.text.each_line do|n| 
        m=n.strip() if i==2
        i+=1
      end
      team = ele.add_element 'rdf:Description',{'rdf:about'=>"data:#{m}"}
      i=0
      val.text.each_line do|n| 
        if ![0,1,2,10,12].include?(i)
          info = team.add_element "team:#{team_attr[i]}"
          info.add_text "data:#{n.strip()}"
        end
        i+=1
      end
      info=team.add_element "team:联赛"
      info_data=doc.xpath("//div[@class='goal_crumbs']/a[@href='/#{num}/schedule.html']").text
      info.add_text "data:#{info_data}"
    end
	end

	uri="http://goal.sports.163.com/#{num}/schedule/team/0_0_0.html"
	doc = Nokogiri::HTML(open(uri))
	match_attr=["","时间","状态","主队","比分","客队"]
	match=""
	doc.xpath("//table[@id='table_eur']//tr/td").each_with_index do |val,key|
		if key%9==0
	    match= ele.add_element 'rdf:Description',{'rdf:about'=>"data:#{val.text.strip()}"}
	    info=match.add_element "match:联赛"
	    info_data=doc.xpath("//div[@class='goal_crumbs']/a[@href='/#{num}/schedule.html']").text
	    info.add_text "data:#{info_data}"
	  end 
    if [1,2,3,4,5].include?(key%9)
      info = match.add_element "match:#{match_attr[key%9]}"
      info.add_text "data:#{val.text.strip()}"
    end
	end

	uri="http://goal.sports.163.com/#{num}/stat/standings/2015_3.html"
	doc = Nokogiri::HTML(open(uri))
	player_data=["号码","","位置","出场","出场时间","进球","助攻","射门","射正","犯规","越位","扑救","黄牌","红牌","角球"]
	doc.xpath("//table[@class='daTb01']//a[@href]/attribute::href").each do |href|
    link="http://goal.sports.163.com"+href
    team_data= Nokogiri::HTML(open(link))
    team_data.xpath("//div[@id='PlayerOf2015']//tr/td[2]").each_with_index do |val,key|
      player = ele.add_element 'rdf:Description',{'rdf:about'=>"data:#{val.text}"}
      palyer_link="http://goal.sports.163.com"+val.css("a").first["href"]
      player_link_data_page= Nokogiri::HTML(open(palyer_link))
      img=player_link_data_page.xpath("//div[@class='fcon']//img/attribute::src")
      info = player.add_element "player:头像"
      info.add_text "data:#{img}"
      palyer_link_data=["","","年龄","生日","身高","体重","国籍"]
      player_link_data_page.xpath("//div[@class='fcon']/h2").text.split(/\|/).each_with_index do |val,key|
      	if key.between?(2,6)
	      	info = player.add_element "player:#{palyer_link_data[key]}"
	      	info.add_text "data:#{val.strip![3..-1]}"
	      end
      end
      team_data.xpath("//div[@id='PlayerOf2015']//tr[#{key}+1]/td").each_with_index do |val,key|
        if key!=1
          info = player.add_element "player:#{player_data[key]}"
          info.add_text "data:#{val.text}" 
        end
      end
      info=player.add_element "player:球队"
      info_data=team_data.xpath("//div[@class='goal_crumbs']/span").text.gsub(/\(.*\)/,"")
      info.add_text "data:#{info_data}"
    end
	end

end

xml.write(file)