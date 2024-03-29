# last-defense-system

//////////

UPDATE：googlebotを許可するためのIPリスト自動取得スクリプトを追加しました。

googleが使用するIPレンジを一覧化 参考：

`https://ichiro-kun.com/post/14049/`

//////////

This repository contains User-Agent lists and IPv4 addresses to block unwanted crawlers, bad robots, suspicious spiders, junk web-scrapers, malicious spammers, and unauthorized access including DDoS attack.

![monogatari_sanbikinokobuta](https://user-images.githubusercontent.com/99088821/153359727-543d3837-2b21-46ca-8fe0-e8d1a3750fc6.png)

—This makes your arsenal iron-wall and protected, like a magical mithril-shield that bounces back monsters with ease.

However, this is not the final network security tool used by web professionals, nor is it special fantasy. It's just a first choice.

An ordinary suit that anyone can easily equip will become the armor of legend. Let's overcome our daily battle saga against threats and also get safety and peace frontier together...

## はじめに

日本での使用を想定していますが、誰もが馴染みのある古典的な手法のため、各ユーザの望む環境に合わせて自由に改変して対応することが可能でしょう。

スターサーバーのApache 2.4 環境下で動作確認済みです。cronの実行、シェルスクリプトとphp、htaccessを扱えるWebホスティングサービスであることが前提となります。

cronによって、事前に用意したブロックリストと、APNICから取得する日本国内IPリストを合わせて整形し、htaccessとして出力します。

Googleを除いて、ほとんどのボットやスパムのアクセスを遮断することが出来ます。

非常に簡易かつ単純な仕組みのため、本体のファイルに比べればこの長いREADMEの方が明らかに主演俳優といえます。

※なお、将来的にGoogleは、ブラウザにおける既存のuser-agentを全く別の仕様に置き換えることを目指し、各社もそれに合意しているようですが、まだしばらくはUAによる制限は有効なものとして機能するでしょう。

## 使用方法

以下のファイルをサーバ上にアップロードする。今回の例では /home/hogehoge/hogehoge.domain/public_html/cron/ のディレクトリに配置することとする。

* allow_ip.txt - ここで特別に許可するIPを定義する
* block_ua.txt - ここでブロックするUAを定義する
* block_ip.txt - ここでブロックするリモートホストおよびIPを定義する
* get_ip.php - 上記2つのリストと、APNICから取得した国内IPリストを結合する
* jpip_get.sh - 実行されると上記phpを呼び出し、.htaccessとして出力する
* googleip_get.sh - 実行されるとgoogleボットのIPリストをjsonから取得する (整形されたリストがgooglebot_ip.txtとして出力される)

jpip_get.sh(およびgoogleip_get.sh)をcronによって実行することで、ブロックリストの定期更新が可能となる。

なお、各ファイル内に記載されているファイルパス等は、各自の環境に合わせて適宜書き換える必要がある。

少なくとも、block_uaとblock_ipリストのみ、または国内IPリストのみでも、不要なアクセスを十分に遮断することが出来る。

※つまり言い換えれば、phpによって3リストから生成されたブロックリストは、アダマンタイト製のゴーグルを付け、オリハルコン製の室内で来訪者を待っているようなものです。しかしそれは平穏を好む人を必ず満足させるでしょう。

※スターサーバーにおける使用例は、別途後述します。

## 従来からの誤解

まずここで、従来から使用されるUAsブロックリストについて改めて振り返ってみます。

### キャレットについて

多くのSetEnvIfを用いたUAsブロックリストでは、キーワードに対してキャレット、ドット、アスタリスク、バックスラッシュ、ドルマークなどを正規表現として使用しています。

しかし少なくとも、ロボットをブロックするためという目的を持ち、かつhtaccessのファイルの変数定義においては、それらのほとんどは使用する必要がありません。

例えば、拒否するUAのキーワードをダブルクオーテーションで囲み、"Google"と設定したとき、部分一致としてUAに「Google」の文字列を含む全てのボットがブロックされます。

もしこのとき、キャレットを使用して"^Google"と設定してしまうと、UAの行頭に「Google」があるときにしかマッチしません。

これはどういうことかというと、実際のUA例として、"Googlebot/2.1 (+`http//www.google.com/bot.html`)"の場合であればブロックが可能です。

ところが、"Mozilla/5.0 (compatible; Googlebot/2.1; +`http//www.google.com/bot.html`)"の場合は、「Google」の文字列が行頭ではないため、ブロックすることができません。

つまり、キャレットの定義はあくまでも「行頭」を示すものであり、「Googlebot」といった個々のボット名称の先頭を示すために無闇に付与するのは誤用です。

※今般リストでは、必要なサービスがブロックされることを防ぐために、また逆に確実にブロックするため、あえてキャレットを付けた行がいくつかあります。

### 正規表現について

前述の通り、htaccessにおけるSetEnvIfのUA指定は、何もせずとも最初から部分一致のキーワードとして認識されます。つまり正規表現を施して多様なボットをマッチさせる、という手法はほとんど必要がありません。

またダブルクオーテーションでキーワードを囲んでさえいれば、"/2.1; +http:"といったメタ文字を含む文字列に対して、バックスラッシュによるエスケープは不要です。

空白も\sとして表記する必要はありません。

ただし、"/5.0 (compatible; "のように丸括弧を含む場合は、これをエスケープしないとステータス500のサーバエラーを起こします。

※とはいえ、そもそもそういった正規表現におけるメタ文字扱いのキーワードを設定する必要性自体が乏しく、単にブロックしたいUAの英数字のみを設定すれば良いのです。

### SetEnvIfの特徴

ダブルクオーテーションを使用するもう一つの利点として、変数を正しく設定できるということです。

例えば、「SetEnvIfNoCase User-Agent "like Gecko" blockua」と記載すると、"like Gecko"のスペース入り文字列が、変数名「blockua」に真として設定されます。

ところがこれを、「SetEnvIfNoCase User-Agent like Gecko blockua」と記載すると、「like」という文字列が、変数名「Gecko」と「blockua」の両方に真として設定されます。

このように、複数の変数に同時にセットする場合には便利ですが、思わぬ間違いを防ぐためにも、ダブルクオーテーションでキーワードを囲むメリットがあるといえます。

さて、ここでSetEnvIfNoCaseを使用するのは、言うまでもなく大文字小文字を区別せずにマッチさせるためです。

つまり、正規表現で[gG]oogleなどと表記する必要が無く、gOOgleでもGooGLEでも、いかなるパターンのUAにおいてもブロックすることが出来ます。

なお、UAのみの変数設定のためにBrowserMatchNoCase(BrowserMatch)ディレクティブも用意されています。この場合は「BrowserMatchNoCase "Google" blockua」と書き、幾分SetEnvIfより簡易な表記で指定することができます。

ちなみに単に環境変数を設定する「SetEnv」(SetEnvIfではない)を用いてブロックリストを記載している例がしばしばあります。

SetEnvによる表記でも結果としてボットをブロックすることは可能ですが、リクエスト処理の段階の中で遅くに実行されるディレクティブであることが、Apache2.4のマニュアルに記載されています。

つまりSetEnvは処理が分岐することの多い大量のブロックリストに対しては不向きですので、より高速なSetEnvIfNoCase(SetEnvIf)が推奨されます。

SetEnvとSetEnvIfの比較 参考：

`https://elephantcat.work/2020/01/30/post-279/`

## ブロックリストの内容

block_uaリストにおいては古今東西、ネット上において確認できる様々なクローラー情報を網羅的に取り入れ、また前述の記載ルールを踏まえ、UA文字列を変数定義しリスト化したものです。

しかしキーワードの部分一致によって、重複してマッチする行も多く含まれていることが予想されます。また、今や使われることのなくなった古いUAも存在するでしょう。

さらに迷惑ボット等ではなく、正常なWebサービスのクローラーであっても、基本的にはほとんどブロックされます。そのため、必要に応じて個々によってカスタマイズされることが望ましいです。

なおblock_ipリストについては、変数に設定したUAと共に、アーカイブサイトのリモートホストおよびIPsのブロックを意図したものになります。

### アーカイブサイトについて

日本で主要なアーカイブサイトである、いわゆるWeb魚拓は"Megalodon"のUA指定、あるいはmetaタグで"noarchive"等とすることでブロックできることは有名です。

しかし同じく世界で主要なWayback Machine(ウェイバックマシン/インターネットアーカイブ)のブロックに関しては、状況が変わっています。

いまでもrobots.txtでは、ia_archiverやia_archiver-web.archive.org、archive.org_bot、あるいはalexaなどのUAでブロックを試みる例がしばしば見受けられます。

ですが現時点でそれらのボットは運用されておらず、実際にhtaccessで指定してもブロックすることはできませんでした。

その際のアクセスログを解析した結果、archive.orgからのUAは特定の文字列を含まないごく一般的なものに偽装されていました。つまり、ブロックのためにはIPアドレスを直接指定するしかありません。

現在は一定のホスティング企業におけるIPが使用されているようですが、今後定期的に変化することが予想されます。

そのため、サイト管理者へメールで直接連絡することによって、自サイトへのクロールを除外依頼することが最も効率的になるでしょう。

ただしその場合、archive.orgの管理チームがあなたのサイト所有権を確認しに来るので、一時的に彼らのIPブロックを解除する必要があるでしょう。

また、archive.is(その他系列ドメイン)に対しては、リモートホストによるブロックはほとんど効果は期待できません。そしてサイト管理者への連絡によっても、対応はほぼ間違いなくなされません。

例えばabuseの報告やDMCA侵害の申し立ては、少なからず対抗策として成功するかもしれません。

つまり実際のところ、こちらもIPでのブロックしか手段がありませんが、archive.is等のIPは変化が早いため特定が難しく、完全なブロックには至りにくいのが現状です。

なお、iframeのクリックジャッキングを利用した転載を防ぐために、必ずSAMEORIGINを設定すべきでしょう。いまやほとんどのサーバーではデフォルトで有効になっているかもしれませんが、もし必要なら下記のオプションを使用してください。

`Header always append X-Frame-Options SAMEORIGIN`

NOTES：

検索エンジンへのインデックスはしてほしいが、キャッシュを保存されたくないならmetaタグにnoarchiveは忘れるべきではありません。いくつかのWebキャプチャーサイトはその記述に従ってくれます。

その他に、noimageindexも画像の著作権を守るために有効ですし、Pinterest向けにnopinを設定しておくのも良いでしょう。

ちなみに、htmlの文法的には正しくないものの、少なくともGoogleのbotはhead以外のどこにmeta robotsを書いても読みに来て、適切に解釈してくれることが良く知られています。

これは無料のブログサービスなどを利用していてheadタグ内をさわれないユーザーにとっては、次善の策となるでしょう。

また言うまでもなく、今回彼らをhtaccessでブロックすれば、もはやrobots.txtを読むことさえできないので、今後彼らのロボット名の記述でファイルを汚す必要は無くなります。

archive.is情報 参考：

`https://blog.wolfs.jp/contents/archiveis-ipaddress/` (閉鎖)

## 国内IPリスト

上記の観点から、少なくとも悪質なボットやアクセスを防ぐためには、UAやIPによる制限では十分ではありません。

そこで、最も効果的かつ効率的であるのが、国内IPのみを許可する手法となります。
前述のUAおよびIPブロックと併用すれば、よく言えば平穏が、悪く言えば閑古鳥がサイトに訪れるでしょう。

かつては、アクセスIPを国内に絞る方法は、「不定期で国内IPリストが変化する」ことが良く知られている通り、そのメンテンナンスがネックとなっていました。

しかし昨今、個人でも安価で高速かつ高機能なサーバをレンタルすることが可能になったことで作業を自動化することができ、そのデメリットはほぼ無くなったと言えます。

今般は、国内IPの取得をしhtaccess化の作業を自動化するにあたって、下記2つのサイトが非常に有益かつ明瞭であったこと、この場を借りて感謝申し上げます。

ip自動取得およびhtaccess作成 参考：

`https://nodoame.net/archives/550` (origin)

`https://zuntan02.hateblo.jp/entry/20140523/1400837726` (mod)

### 許可リモートホスト

上記の参考サイトでも挙げられていますが、国内からのアクセスのみに制限する場合、かつてはリモートホストによる設定がされていました。

かといって、例えば特定の国を拒否するブラックリスト方式では逆引きが上手く働かないことが多々あり、ホワイトリスト形式で.jpを許可するという記載がとられました。

同時に、jpドメイン以外のbbtec.netおよびil24.netを許可する定型文が流行りましたが、国内IPが正確かつ簡易に自動取得できるようになった現状において、それはほぼ形骸化していると判断できるため、今般リストには加えていません。

とはいえ、海外IPであってもGoogleのサービスは使用したいサイト運営者がほとんどだと思いますので、例外的にgoogle.com, googlebot.com、およびLet's Encryptはそのまま許可としています。

## IP取得とファイル生成

基本的な流れは参考サイトの通りですが、今回はあらかじめ用意されたUA等のブラックリストをマージしてhtaccess化するにあたって、元々のget_ip.phpを改変しています。

※実際問題、国内IPのみにアクセスが制限されていれば、ほとんどの場合においてUA等を併用したブロックは不要かと思いますが、実に汎用性の高いプログラムのため、Webサイトの究極的な平和を実現するために活用しています。

今回、最も重要になってくるのは各ファイルの準備と、cronでシェルスクリプトを実行することです。

動作が上手くいくと、まずgoogleip_get.shを実行され→googleボットの許可IPリストが出力→次にjpip_get.shが走り→phpがAPNICからIP取得しUAとIPの許可/ブロックリストから文字列を生成→統合された.htaccessを自動的に配置する、となります。

NOTE：WordPressなどのCMSを使用している場合は、既存のhtaccessのバックアップを取り、必ずそのファイルに書かれたコードを保存しておきましょう。

## スターサーバーでの例

レンタルサーバに上記を適用するにあたって、最も障害となるのが各サーバ会社における仕様の差、ひいてはユーザがいじれるUI部分の差、そしてその情報の差となってきます。

例えば、様々な面で導入例の多いエックスサーバーなどであれば、ネット上にも情報は豊富に存在します。

しかし残念ながら今般使用するスターサーバーでは、それに比べて圧倒的に情報の絶対量が足りません。

個人的には、ごく普通の用途では全く支障なく活用できており満足なのですが、同じく愛用している数少ないスターサーバー利用者に向けて、つまづくポイントを記載しておきます。

なお、スターサーバーの有料プランのみならず、これはスタードメインに付属の無料サーバーにおいても動きます。

cronを設定する前に、まず参考サイトのphpでは不足している部分が、ファイル行頭の「#!/bin/php」の表記です。いわゆるおまじないとも言われるこのshebangがないと動きません。

そしてスターサーバーにおける最大の問題が、cron設定時のコマンド部分の表記です。ここさえ乗り越えれば、作業の9割は済んだものとなります。

### cronを実行する

実行日時等はアスタリスクなどを用いて適宜入力するとして、コマンド部分には「/usr/bin/sh /home/hogehoge/hogehoge.ドメイン/public_html/cron/jpip_get.sh」とします。(googleip_get.shはjpip_get.shより1分前程度に実行するようにセットしておきましょう)

もちろんhogehogeはサーバ管理ツールのUIにおける「サーバーID」であり、ドメインは自身が契約しているcomやnetなどです。

そして最も重要なのは、shファイルパスの前の「/usr/bin/sh 」(半角スペース含む)の部分です。これがないと動きません。

さて、無事cronが動き、何らかエラーがあると通知先に設定したアドレスにメールが届きます。(正常終了すれば何も通知は来ませんので、htaccessファイルが出来上がっていることを確認してください。)

このときのメール内容で、それぞれの状況に対応していくことになります。

1.「許可がありません」となっていたら、それはファイルの実行権限がありません。権限を755などにしてください。

2.「誤ったインタプリタです: そのようなファイルやディレクトリはありません」となっていれば、それは改行コードの問題です。LFでファイルを開きなおして保存してください。

3.「Warning: fopen(xxx.txt): failed to open stream: No such file or directory」および「Warning: fclose() expects parameter 1 to be resource, boolean given」であれば、事前に準備したブロックリストのファイルパスが間違っています。

スターサーバーにおける当該ファイルの絶対パスは、「/home/hogehoge/hogehoge.ドメイン/public_html/cron/xxx.txt」(自ドメイン直下のcronフォルダに配置したとき)です。

4.「Notice: Undefined variable: jp_ip4」であれば、文字通り変数が定義されていません。関数内で使う前に、まず変数を" "などで初期化するか、何か必要な文字列を最初に定義してください。

5.「Parse error:  syntax error, unexpected '$jp_ip4' (T_VARIABLE) 」であれば、どこかに無駄に全角スペースが入っていたり、コメントアウト忘れなど、どこかしら書式が間違っています。これはphpの自動整形ツールを使った場合にも起こることがあります。

だいたいのエラーは上記の通りですが、言うまでもなく、4および5はほぼ丸々コピペのphpが実行されていればまず発生しない問題です。

cronに設定された日時になったとき、何のメールも通知されなければ、無事に.htaccessは計3ファイル分の内容が統合されたブロックリストとなっているはずです。コーヒーを楽しむ時間が終わったら、ファイルの内容を確認してみましょう。

### 補足：htaccess表記

Apacheバージョンは2.4を使用しているため、それに準拠し、RequireAll, RequireAny, (RequireNone)を記載しています。

今回の場合、「ブロックUA, リモートホスト＆IPのいずれにも当てはまらない」かつ「国内IP(か例外googleホスト等)のいずれか」をすべて満たすものが許可されます。

なお、2.2系までで使われていた従来の「order allow,deny」なども併用は可能です。少なくともスターサーバーにおいて、現状問題無くブロックが働くことを確認済みです。

ただし注意点があります。基本的に.htaccessファイルは内容が上から順に解釈されていきます。

それを考えてみれば当然ですが、例えば今般のRequireディレクティブの前に、「deny from x.x.x.x」と何らかIPを指定した場合、その後いくらRequire内で許可されているものであっても、拒否されます。

逆に、Require内で拒否されたものを、後の行で「allow from x.x.x.x」と書いても、もはや既に拒否されているため、アクセスできません。

つまりRequireと共に従来のdenyやallowもあわせて使う際、条件が満たされた時点でキックされ弾かれてしまう拒否の方が優先的に強い、というのが絶対のようです。

ところが、Requireディレクティブを複数用いて矛盾した内容を記載した場合は、多様な挙動を見せます。
例えばRequireディレクティブを一旦閉じた後に、また別のRequireディレクティブを書いたとしましょう。

すると、最初にRequireAllおよびNoneを通過して許可されたIPを、後のRequireAll(ip not)で拒否しようとすると、先の許可の方が優先されます。
逆に(None)で拒否しているIPを、後のRequireAll(ip)で許可しようとすると、今度は後の許可が優先されます。

なお後方のディレクティブをRequireAllではなく、RequireAnyで許可や拒否しようとすると、500エラーを起こしてしまいます。

以上のことから、予期せぬ動作を起こさないためにも、2.2系の表記を混在させない、Requireディレクティブを閉じた後は、再度後方に記載しない、という決まりごとが必要です。

### 応用例

get_ip.phpに適宜追記することによって、普段使用しているリダイレクトや、Header set X-Robots-Tag, ErrorDocumentなど各種設定を同時に一元化し作成することも可能です。

ただしリダイレクトのRewriteCond, RewriteRuleにおいては、上位ディレクトリのリダイレクトを上書きする影響を及ぼすことは忘れがちです。

そういったことを防止する際は、RewriteOptions Inheritなどを使用しましょう。なおこのオプションはスターサーバーにおいても使用できます。

別ディレクトリへのアクセスで、意図せずリダイレクトが発生したり、想定したリダイレクトが反映されなかったりなど、各記載には注意が必要です。

ちなみに、上層ディレクトリhtaccess内のSetEnvIFで設定した変数は、下層ディレクトリでは改めて宣言しなくとも再利用可能です。これもスターサーバーにおいて確認しました。

この性質を生かして、.htacccessによるブラックリスト管理を各ファイルに分散し、ファイルサイズの軽量化をすることも可能でしょう。

しかし複数のディレクトリにそれぞれhtaccessが存在することによって、リクエストはそれらを同時に確認しに行くことになりますので、かえってパフォーマンス低下を招く可能性があります。

NOTE：もし現状でBasic認証を使用しているなら、以下のように既存のコードはブロックリスト内のRequireディレクティブの中に挿入しなければなりません。

例)
```
<RequireAll>
    AuthUserFile /var/www/html/.htpasswd
    AuthGroupFile /dev/null
    AuthName "Input ID and Password"
    AuthType Basic
    Require valid-user
［...]
</RequireAll>
```

SetEnvIf変数引き継ぎ 参考：

`http://web.tvbok.com/web/server/htaccesssetenvifor.html`

![renga_pattern](https://user-images.githubusercontent.com/99088821/153359928-a13b4450-5cd1-42ca-8ff7-a8e04798ab45.png)

—Now that our work is done, let's get some rest.

## ライセンス表記

Author: maon-git

このリポジトリにはMITライセンスが適用されます。

`https://opensource.org/licenses/mit-license.php`
