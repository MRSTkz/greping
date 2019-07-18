require 'yaml'
require "#{Dir.getwd}/lib/str"

class Grept
  def option_ini(options)
    end_flag = false
    option = @data['option']
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
    dir += '/' if dir[-1] != '/' && File.ftype(dir) == 'directory'
    p dir
    p Dir.getwd
    Dir.glob(dir + '*') do |path|
      if File.ftype(path) == 'directory'
        directory(path, word, option)
      elsif @data['ext'].select { |ex| ex == File.extname(path) }.empty? || path.include?('Gemfile')
        open_files(path, word, option)
      else
        p path
        @ext << File.extname(path)
        @cnt += 1
      end
    end
  end
  alias search directory

  def open_files(file, word, option)
    @file_cnt += 1
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
      # error発生時は何もしない
    end
  end

  def regex(word)
    if word.class == String
      temp = '' << word
      Regexp.new(temp.gsub(/[^a-zA-Z0-9]/, '\\\\\\&').gsub(/[a-zA-Z0-9]+/, '[a-zA-Z0-9]+'))
    elsif word.class == Regexp
      word
    end
  end

  def perfect_match?(text, word)
    texts = nil
    if word.class == String
      key = word.gsub(/[a-zA-Z0-9]+/, '').split('')
      texts = text.split(/[^a-zA-Z0-9]/)
      texts = text.split(/[^a-zA-Z0-9\\\\\[\]\-#{key}]/) unless key.empty? # 正規表現で[]内に書く類の記号は判別がきついので実力行使となります。抜けがあれば随時追加
    elsif word.class == Regexp
      texts = text.split(/[^#{word.inspect}]/)
    end
    rt_flag = false
    texts.delete('')
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
      file_name = 'file_name'.yellow
      file_line = 'file_line'.green
      text.each_line.with_index(1) do |line, i|
        if (option['WholeWord'] || word.class == Regexp) && perfect_match?(line, word)
          file_flag = true
          if option['Regex']
            temp_result << "#{file_line}[#{i}] : " + line.strip.gsub(Regexp.new(word), '\\&'.green)
          else
            temp_result << "#{file_line}[#{i}] : " + line.strip.gsub(word, '\\&'.green)
          end
        elsif line.include?(word)
          file_flag = true
          temp_result << "#{file_line}[#{i}] : " + line.strip.gsub(Regexp.new(word), '\\&'.green)
        end
      end
      @result << "#{file_name} : " + file unless temp_result.empty?
      @result.concat temp_result
    end
  end

  def write
    puts @result
    puts "#{@file_cnt} file scan"
    puts "#{@cnt} file can't scan, EXTENSION(#{@ext.uniq.join(' ').delete('.')}) can't readring" unless @cnt.zero?
  end

  def initialize
    @result = []
    @ext = []
    @cnt = 0
    @file_cnt = 0
    @data = open("#{Dir.getwd}/config/sample.yml", 'r') { |f| YAML.safe_load(f) }
  end
end
