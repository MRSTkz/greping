rubyの勉強がてらになんか作ってみました

最終目標としては、自作のテキストエディタ作って、grep_text.rbを利用して全文検索機能とか、更に別機能でファイル検索とか作りたいなぁとか思ってます

ruby(rails),c#(.Net),c言語専用のリッチテキストなエディタを作りたい。ワード補完機能も付ける感じで。

補完機能もお手製で作りたいですが、エディタ部分全般は既存のフレームワークとか使いたいなぁとか思ってますまる

How To Use  grep_text.rb
> ruby grep_text.rb 【file_or_directory_name】 【search_word】 【comand】

ex)def 
> ruby grep_text.rb project/task 'def (\w+)' Regex
