require 'sparql'
require 'linkeddata'
queryable = RDF::Repository.load("http://127.0.0.1:3000/test1.xml")
param="data:德甲"
sse = SPARQL.parse(%(
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX team: <http://wangyi.com/team#>
  PREFIX match: <http://wangyi.com/match#>
  PREFIX player: <http://wangyi.com/player#>
  PREFIX data: <http://wangyi.com/data/>
  SELECT  ?player ?p ?o 
  WHERE { ?team  team:联赛 “#{param}”  .
          OPTIONAL { ?player player:球队 ?team} .
          OPTIONAL { ?player ?p ?o}
        } 
  LIMIT 20))
sse.execute(queryable) do |result|
  puts result.inspect
end
