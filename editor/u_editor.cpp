#include <ruby.h>

void main()
{
  // Rubyインタプリタの初期化
  ruby_init();
  ruby_init_loadpath();

  // スクリプトをファイルから読み込んで実行
  rb_load(rb_str_new2("test.rb"), 0);

  // Rubyインタプリタのクリーンアップ
  ruby_cleanup(0);
}