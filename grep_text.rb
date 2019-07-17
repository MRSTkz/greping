class String
  def colorize(color_code)
  "\e[#{color_code}m#{self}\e[0m"
  end

  def green
    colorize(32)
  end
  
  def yellow
    colorize(33)
  end

  def blue
    colorize(36)
  end
end

def option_ini(options)
  end_flag = false
  option = { 'MatchCase' => nil, 'BulkMatch' => nil, 'WholeWord' => nil, 'Regex' => nil }
  begin
    options.each do |key_ops|
      flag = false
      option.each do |key, _value|
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
  rescue StandardError
    puts 'sorry, typing retry please'
  end
  option
end

def directory(dir, word, option)
  @not_read_list = ['.png', '.csv', '.jpg', '.zip', '.ttf', '.ttc', '.pdf', '.ico', '.xls', '.xlsx', '.EUF', '.example', '.TTE', '.cache', '.bundle', '.so', '',]
  dir += '/' if dir[-1] != '/' && File.ftype(dir) == 'directory'
  Dir.glob(dir + '*') do |path|
    if File.ftype(path) == 'directory'
      directory(path, word, option)
    elsif @not_read_list.select { |ex| ex == File.extname(path) }.empty?
      open_files(path, word, option)
    else
      @cnt += 1
    end
  end
end

def open_files(file, word, option)
  text = File.open(file, 'r:utf-8').read
  word = str_to_regex(word, option)
  word_case_division(text, word, option)
  text_serch(text, file, word, option)
end

def str_to_regex(word, option)
  if option['Regex']
    Regexp.new(word)
  else
    word
  end
end

def word_case_division(text, word, option)
  return if option['MatchCase']

  begin
    text.downcase!
    word.downcase!
  rescue StandardError
    #error発生時は何もしない
  end
end

def regex(word)
  if word.class == String
    temp = '' << word
    Regexp.new(temp.gsub(/[^a-zA-Z0-9]+/, '\\\\\\&').gsub(/[a-zA-Z0-9]+/, '[a-zA-Z0-9]+'))
  elsif word.class == Regexp
    word
  end
end

def perfect_match?(text, word)
  texts = nil
  if word.class == String
    key = word.gsub(/[a-zA-Z0-9]+/, '').split('')
    texts = text.split(/[^a-zA-Z0-9]/)
    texts = text.split(/[^a-zA-Z0-9#{key}]/) unless key.empty?
  elsif word.class == Regexp
    texts = text.split(/[^#{word.inspect}]/)
  end
  texts.delete('')
  rt_flag = false
  texts.each do |t|
    if t.match(regex(word))
      if t == word
        rt_flag = true
      elsif word.class == Regexp
        rt_flag = true
      end
    end
  end
  rt_flag
end

def text_serch(text, file, word, option)
  file = file.blue
  if option['BulkMatch']
    if option['WholeWord'] || (option['Regex'] && word.class == Regexp)
      @result << file if perfect_match?(text, word)
    elsif text.include?(word)
      @result << file
    end
  else
    temp_result = []
    file_flag = false
    file_name = "file_name".yellow
    file_line = "file_line".green
    text.each_line.with_index(1) do |line, i|
      if option['WholeWord'] || (option['Regex'] && word.class == Regexp)
        if perfect_match?(line, word)
          file_flag = true
          temp_result << "#{file_line}[#{i}] : " + line.strip.gsub!(Regexp.new(word), "\\&".green)
        end
      elsif line.include?(word)
        file_flag = true
        temp_result << "#{file_line}[#{i}] : " + line.strip.gsub!(Regexp.new(word), "\\&".green) 
      end
    end
    @result << "#{file_name} : " + file unless temp_result.empty?
    @result.concat temp_result
  end
end

word = '' << ARGV[1]
@result = []
@not_read_list = []
@cnt = 0
directory(ARGV[0], word, option_ini(ARGV.slice(2..-1)))
puts @result
puts "#{@result.size} file scan"
puts "#{@cnt} file can't scan, #{@not_read_list.join(' ').gsub('.', '')}"
