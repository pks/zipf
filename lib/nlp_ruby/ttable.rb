# table['some French string'] = [Array of English strings]
def read_phrase_table fn
  table = {}
  f = ReadFile.new fn
  while raw_rule = f.gets
    french, english, features = splitpipe(raw_rule)
    feature_map = read_feature_string(features)
    if table.has_key? french
      table[french] << [english, feature_map ]
    else
      table[french] = [[english, feature_map]]
    end
  end
  f.close
  return table
end

