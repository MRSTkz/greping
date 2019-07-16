def option_ini(options) 
  end_flag = false
  option = { 'MatchCase' => nil, 'BulkMatch' => nil, 'WholeWord' => nil, 'Regex' => nil }
  begin
    options.each do |key_ops|
      flag = false
      option.each do |key, value|
        if key == key_ops
          option[key_ops] = true
          flag = true
        end
      end
      unless flag
        puts "#{key_ops} comand option is not found"
        end_flag = true
      end
    end
    raise if end_flag
  rescue
    puts "sorry, typing retry please"
  end
  return option
end

def directory(dir, word, option)
  dir += '/' if dir[-1] != '/' && File::ftype(dir) == "directory"
  Dir.glob(dir + '*') do |path|
    if File::ftype(path) == "directory"
      directory(path, word, option)
    else
      open_files(path, word, option)
    end
  end
end

def open_files(file, word, option)
  text = File.open(file).read
  word = str_to_regex(word, option)
  word_case_division(text, word, option)
  text_serch(text, file, word, option)
end

def str_to_regex(word, option)
  if option["Regex"]
    Regexp.new(word)
  else
    word
  end
end

def word_case_division(text, word, option)
  unless option["MatchCase"]
    begin
      text.downcase!
      word.downcase!
    rescue
    end
  end
end

def regex(word)
  temp = '' << word
  Regexp.new(temp.gsub(/[a-zA-Z0-9]+/, "[a-zA-Z0-9]+"))
end


def perfect_match?(text, word)
  key = word.gsub(/[a-zA-Z0-9]+/, "").split("")
  texts = text.split(/[^a-zA-Z0-9#{key}]/)
  texts.delete("")
  rt_flag = false
  texts.each do |t|
    if t.match(regex(word)) && t == word
      rt_flag = true
    end
  end
  rt_flag
end

def text_serch(text, file, word, option)
  if option["BulkMatch"]
    unless option["WholeWord"]
      if text.include?(word)
        @result << file
      end
    else
      if perfect_match?(text, word)
        @result << file
      end
    end
  else
    temp_result = []
    file_flag = false
    text.each_line.with_index(1) do |line, i|
      unless option["WholeWord"]
        if line.match(word)
          file_flag = true
          temp_result << "file_line[#{i}] : " + line.strip
        end
      else
        if perfect_match?(line, word)
          file_flag = true
          temp_result << "file_line[#{i}] : " + line.strip
        end
      end
    end
    @result << "file_name : " + file unless temp_result.empty?
    @result.concat temp_result
  end
end

# メイン処理

word = '' << ARGV[1]
@result = []
directory(ARGV[0], word, option_ini(ARGV.slice(2..-1)))
puts @result
