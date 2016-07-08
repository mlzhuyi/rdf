require 'sparql'
require 'linkeddata'
queryable = RDF::Repository.load("http://127.0.0.1/test.xml")
param="拜仁慕尼黑"
sse = SPARQL.parse(%(
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX team: <http://wangyi.com/team#>
  PREFIX match: <http://wangyi.com/match#>
  PREFIX player: <http://wangyi.com/player#>
  SELECT  ?s ?p ?o
  WHERE { {?s match:主队 "#{param}"} UNION  {?s match:客队 "#{param}"} .
  				OPTIONAL {?s ?p ?o}
        } 
  LIMIT 20))
sse.execute(queryable) do |result|
  puts result.inspect
end
