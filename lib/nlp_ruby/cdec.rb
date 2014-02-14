module CDEC

require 'open3'


# FIXME
CDEC_BINARY = "/toolbox/cdec-dtrain/decoder/cdec"


def CDEC::kbest input, ini, weights, k, unique=true
  o, s = Open3.capture2 "echo \"#{input}\" | #{CDEC_BINARY} -c #{ini} -w #{weights} -k #{k} -r  2>/dev/null"
  j = -1
  ret = []
  o.split("\n").map{|i| j+=1; t=Translation.new; t.from_s(i, false, j); ret << t}
  return ret
end


end

