ログインとは、サイトを操作しているユーザーが誰であるかが判別できる状態のことをさします。
操作しているユーザーに合わせて、同じURLでもユーザーごとに表示を変えることなどができます。

送信されたアドレスやパスワードをもとに、データベースから特定する。

まずはログインページを作るためにルーティング、アクション、ビューを追加しましょう。 
inputタグのtype属性をpasswordとすると右の図のように、入力したパスワードが伏字となるパスワード用のフォームになります。

########################################################################################################################

「rails g migration」を用いて、add_password_to_usersというファイル名のマイグレーションファイルを作成し,
中身を作ったら「rails db:migrate」を実行しましょう。


#############################################################################################################
投稿機能などと同じようにフォームに入力された内容をコントローラ側に送信できるようにしていこう。
まずはルーティングとアクションを追加しよう。

#/config/routes.rb
post "login" => "users#login"

#./controllers/users_controller.rb

def login_form
end

#/users/login_form.html.erb
#フォームの値を送信できるよう、ログインフォームにname属性を追加しましょう。
<%= form_tag ("/login") do%>
    <p>メールアドレス</p>
    <!-- name属性を追加してください -->
    <input name="email">
    <p>パスワード</p>
    <!-- name属性を追加してください -->
    <input name="password"  type="password">
    <input type="submit" value="ログイン">
  <!-- form_tag用のendを追加してください -->
 # <%end%>

###########################################################################################################################


次は送信されたメールアドレスとパスワードを用いてユーザーを特定しよう。

フォームに入力されたメールアドレスとパスワードはparams[:email]とparams[:password]で受け取れます。
usersテーブルから入力された値に一致するユーザーを取得し、変数@userに代入しましょう。
また、find_byメソッドは引数をコンマ( , )で区切ることで複数の条件からデータベースを検索することができます。


def login
  # 入力内容と一致するユーザーを取得し、変数@userに代入してください
  @user = User.find_by(email: params[:email],
                       password: params[:password])
  # @userが存在するかどうかを判定するif文を作成してください
  if @user
    flash[:notice] = "ログインしました"
    redirect_to("/posts/index")
  else
    render("users/login_form")
    
  end
end
################################################################################################################


ユーザーが存在しない場合
エラーメッセージを表示したり、フォームに初期値を入れる

エラーメッセージはバリデーションのエラーメッセージとは異なり、
「find_byメソッドで検索したが存在しなかった」という結果を伝えるためのものなので、自作する必要があります。

変数@emailと@passwordを定義し、それぞれにparams[:email]とparams[:password]の値を代入し、
フォームに入力した値が初期値となるようにしましょう。また、変数に代入した初期値を表示するために
フォームにvalue属性を追加しましょう。

else
  # @error_messageを定義してください
  @error_message = "メールアドレスまたはパスワードが間違っています"
  
  
  # @emailと@passwordを定義してください
  #renderメソッドによってログインページが再表示されたときに、
  #直前に入力したメールアドレスとパスワードが初期値としてセットされるようにしましょう。
  @email=params[:email]
  @password=params[:password]
  
  render("users/login_form")
end
end

#html
<%= form_tag("/login") do %>
  <p>メールアドレス</p>
  <!-- value属性を追加してください -->
  <input name="email" value="<%=@email%>">
  <p>パスワード</p>
  <!-- value属性を追加してください -->
  <input type="password" name="password" value="<%=@password%>">
  <input type="submit" value="ログイン">
<% end %>
</div>

##################################################################################################################


ログインページでユーザーを特定した後、そのユーザーの情報を保持し続ける必要がある。

session
ページを移動してもユーザー情報を保持し続ける。
sessionに代入された値は、ブラウザ(InternetExplorer, GoogleChrome等)に保存されます。
sessionに値を代入すると、ブラウザはそれ以降のアクセスでsessionの値をRailsに送信します。

具体的にsessionに値を代入するときには、user_idをキーとし、値を代入します。
@userが存在する場合に変数sessionに@user.idを代入することで、特定したログインユーザーの情報が保持され続けます。

if @user
  session[:user_id] = @user.id  #代入された値がブラウザに保存される。


session[:user_id]に代入した値がページを移動しても保持され続けることを確認するために、
ログインしたユーザーのidをヘッダーに表示しましょう。session[:user_id]とすることで、ブラウザから送信された
変数sessionの値を取得することができます。

<% if session[:user_id] %>
          <li>
            現在ログインしているユーザーのid:
            <%= session[:user_id]%>
            
          </li>
 #       <% end %>

#####################################################################################################################

ログアウト機能
変数 session のuser_id の値を削除するよ

ログアウトする、つまり「ログイン状態でなくする」には
session[:user_id]にnilを代入することで、session[:user_id]の値を空にすることができます。

#get/データベースを変更しないとき
#post/データベースを変更するとき、sessionの値を変更するとき

#ルーティング
post "logout" => "users#logout"
#アクション
def logout
  session[:user_id] = nil
  flash[:notice] = "ログアウトしました"
  redirect_to("/login")
 end
 #ビュー
 #<%= link_to("ログアウト", "/logout", {method: :post}) %>　

 ###################################################################################################################


 ＜ユーザー登録時にパスワードを保管する＞
 ユーザー登録フォームにパスワード用のフォームを追加しましょう。
 また、ユーザー登録時にpasswordカラムの値が設定されるようにしましょう。
 そのために、createアクションのnewメソッドの引数としてpasswordを追加するようにします。

 ＜ユーザー登録成功した時に、ログイン状態にする＞
 usersコントローラのcreateアクション内で作成したユーザーのidをsession[:user_id]に代入しましょう。

 #パスワードフォームの追加
 <input type ="password" name = "password" value = "<%= @user.password %>">
 ユーザー登録に失敗したときに初期値をセットするためvalue属性をこれにする

 #フォームから送信されたパスワードを取得し、ユーザーを保存する際にパスワードが保存されるようにしましょう。
 createアクションで、ユーザー登録フォームから送信されたパスワードをparams[:password]で取得
 params[:password]=@user.id
 
 #ユーザー登録が成功した場合、ログイン状態となるようにしましょう。
 #creatアクション内で
 session[:user_id] = @user.id

 ##################################################################################################################

 ログイン中のユーザー名を表示する
 session[:user_id]の値をもとに、ログイン中のユーザーの情報をデータベースから取得しましょう。
 find_byメソッドを用いてusersテーブルからidカラムの値がsession[:user_id]と等しいユーザーを取得し、変数に代入します。
 変数名は「現在のユーザー」という意味でcurrent_userとしましょう。
 また、表示するユーザー名はそのユーザーの詳細ページへのリンクとする

 <% if current_user%>
          <li>
            <%= link_to(current_user.name , "/users/#{current_user.id}") %>
          </li>

###################################################################################################################


#各アクションに対応したビューファイルは、application.html.erbの<%= yield %>部分に代入され表示されています。
#<top.html.erb>　→→代入→→　application.html.erbの<%= yield %>

これによりapplication.html.erbは全てのアクションで呼び出されるため、
application.html.erbでアクション側の変数を使おうとすると、全アクションで@current_userを定義する必要があります。

各コントローラの全アクションで共通する処理がある場合には、
before_actionを用いることで、アクションが呼び出される際に必ずbefore_actionの処理が実行されます。

全てのコントローラで共通する処理はapplicationコントローラにまとめることができます。
ログイン中のユーザーを取得するset_current_userメソッドを定義し、before_actionに指定しましょう。

#applicationコントローラー
before_action : set_current_user
  
  def set_current_user
    @current_user = User.find_by(id: session[:user_id])
  end

#application.htmlで、
#定義した@current_userに書き換える

#################################################################################################################

ログインしていない場合のアクセス制限
@current_userがいない場合にはログインページにリダイレクトするようにしましょう。
しかし、この処理は他のアクションや他のコントローラでも使いたいので、applicationコントローラとbefore_actionを用いて
処理を共通化させましょう

#applicationコントローラにauthenticate_userというメソッドを作成し、アクセス制限の処理を共通化します。
#authenticate_userは「ユーザーを認証する」という意味です。

def authenticate_user
  if @current_user==nil
     flash[:notice] = "ログインが必要です"
     redirect_to("/login")
  end
end

#onlyを用いて各コントローラでbefore_actionを使うことで、指定したアクションでのみそのメソッドを実行することができます。
#各コントローラは、applicationコントローラを継承しているので、継承元のメソッドを使うことができます。

before_action :authenticate_user , {only:[:index, :show, :edit, :update]}

#@current_userがauthenticate_userメソッドの中でも使用されていることに注目しましょう。
#@変数で定義した変数は同じクラスの異なるメソッド間で共通して使用することが可能です。

#############################################################################################################################

ログインしているユーザーが入れないページを作る

forbid_login_userメソッド
ログインユーザーが存在する場合、投稿一覧ページにリダイレクトするようにします。

def forbid_login_user
  if @current_user
    flash[:notice] = "すでにログインしています"
    redirect_to("/posts/index")
  end

メソッドの実行にはbefore_actionを用い、onlyで適用したいアクションを指定しましょう。

before_action :forbid_login_user,{only:[:new, :create, :login_form, :login]}

######################################################################################################################


ユーザー編集を制限する機能
ユーザー詳細ページで、ログインしているユーザーではない場合には編集ページへのリンクを非表示にしましょう。

#<%if @user.id==@current_user.id %>  #idがログインしているユーザーidと一致する場合にリンクを表示する
#      <%= link_to("編集", "/users/#{@user.id}/edit") %>
#      <%end%>

##################################################################################################################

今のままでは、編集ページの URL を直接入力すれば、簡単に編集ページに入ることができてしまう.
これを防ぐために、ビューでリンクを消すだけでなく、アクション側でも同様の条件分岐を用いて制限しよう。

#users_controller.rb

before_action :ensure_correct_user,{only: [:edit, :update]}

def ensure_correct_user
  if @current_user.id != params[:id].to_i #ログイン中のユーザーidと編集したいユーザーidが一致しないとき
    flash[:notice] = "権限がありません"
    redirect_to("/posts/index")
  end
end

#to_iメソッド
#ログイン中のユーザーのidは@current_user.idに、編集したいユーザーのidはparams[:id]にそれぞれ代入されています。
#しかし、params[:id]で取得できる値は文字列であり、数値である@current_user.idと比較してもfalseとなります。
#to_iメソッドを用いると、文字列を数値に変換することができます。

################################################################################################################
