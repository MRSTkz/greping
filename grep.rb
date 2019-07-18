require './app/grep_text'

grep = Grept.new
grep.search(ARGV[0], ARGV[1], grep.option_ini(ARGV.slice(2..-1)))
grep.write

# search : ワードの検索
# write  : 検索結果の出力
