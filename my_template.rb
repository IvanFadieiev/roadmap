# Add the current directory to the path Thor uses
# to look up files
def source_paths
  Array(super) +
    [File.expand_path(File.dirname(__FILE__))]
end
# Gemfile
remove_file 'Gemfile'
run 'touch Gemfile'
add_source 'https://rubygems.org'
gem 'rails', '4.0.2'
gem 'bootstrap-sass', '2.3.2.0'
gem 'bcrypt-ruby', '3.1.2'
gem 'faker', '1.1.2'
gem 'will_paginate', '3.0.4'
gem 'bootstrap-will_paginate', '0.0.9'
gem 'sprockets', '=2.11.0'
gem 'pg', '0.15.1'
gem 'rails_12factor', '0.0.2'
gem 'slim-rails'
gem 'sass-rails', '4.0.1'
gem 'uglifier', '2.1.1'
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails', '3.0.4'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'
gem 'factory_girl_rails', '4.2.1'
gem 'spring'
gem_group :doc do
  gem 'sdoc', '0.3.20', require: false
end

# CONFIG FOLDER
inside 'config' do
  # SECRET_TOKEN
  create_file 'initializers/secret_token.rb' do <<-EOF
require 'securerandom'

def secure_token
  token_file = Rails.root.join('.secret')
  if File.exist?(token_file)
    # Use the existing token.
    File.read(token_file).chomp
  else
    # Generate a new token and store it in token_file.
    token = SecureRandom.hex(64)
    File.write(token_file, token)
    token
  end
end

#{app_name.capitalize}::Application.config.secret_key_base = secure_token
  EOF
  end
  # ROUTES
  remove_file 'routes.rb'
  create_file 'routes.rb' do <<-EOF
#{app_name.capitalize}::Application.routes.draw do
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :users
  resources :sessions,   only: [:new, :create, :destroy]
  resources :microposts, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  get "users/new"
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  root  'static_pages#home'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
end
  EOF
  end
  # DATABASE.YML
  remove_file 'database.yml'
  puts '================================'
  puts 'We use postgres DB, so...'
  db_name = ask('enter DB name')
  db_pass = ask('enter DB password')
  puts '================================'
  create_file 'database.yml' do <<-EOF
development:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_development
  pool: 5
  host: localhost
  username: #{db_name}
  password: #{db_pass}

test:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_test
  pool: 5
  host: localhost
  username: #{db_name}
  password: #{db_pass}

production:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_production
  pool: 5
  username: #{db_name}
  password: #{db_pass}
    EOF
  end
end
# development.rb app_name
  gsub_file 'config/environments/development.rb', /Rails.application/, "#{app_name.capitalize}::Application"
 
  # application.rb config
  gsub_file 'config/application.rb', /config/, ' #config'
 
  # application.rb
  insert_into_file 'config/application.rb', after: "require 'rails/all'\n" do <<-RUBY
  require "active_record/railtie"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "sprockets/railtie"
  RUBY
  end

# SCAFFOLDING
generate 'scaffold', 'users name:string email:string password_digest:string remember_token:string admin:boolean'
generate 'scaffold', 'microposts content:string user_id:integer'
generate 'scaffold', 'relationships follower_id:integer followed_id:integer'

# ASSETS
inside 'app/assets' do
  # JS
  remove_file 'javascripts/application.js'
  create_file 'javascripts/application.js' do <<-EOF
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require_tree .
    EOF
  end

  # STYLESHEETS
  remove_dir 'stylesheets'
  empty_directory 'stylesheets'
  inside 'stylesheets' do
    create_file 'application.css' do <<-EOF
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or vendor/assets/stylesheets of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require_tree .
 */
    EOF
    end
    create_file 'custom.css.scss' do <<-EOF
@import "bootstrap";

/* universal */

$grayMediumLight: #eaeaea;

@mixin box_sizing {
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
}
$lightGray: #999;
html {
  overflow-y: scroll;
}

body {
  padding-top: 60px;
}

section {
  overflow: auto;
}

textarea {
  resize: vertical;
}

.center {
  text-align: center;
 h1 {
  margin-bottom: 10px;
}
}

/* miscellaneous */

.debug_dump {
  clear: both;
  float: left;
  width: 100%;
  margin-top: 45px;
  @include box_sizing;
}

/* typography */

h1, h2, h3, h4, h5, h6 {
  line-height: 1;
}

h1 {
  font-size: 3em;
  letter-spacing: -2px;
  margin-bottom: 30px;
  text-align: center;
}

h2 {
  font-size: 1.2em;
  letter-spacing: -1px;
  margin-bottom: 30px;
  text-align: center;
  font-weight: normal;
  color: $lightGray;
}

p {
  font-size: 1.1em;
  line-height: 1.7em;
}

/* header */

#logo {
  float: left;
  margin-right: 10px;
  font-size: 1.7em;
  color: #fff;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
  line-height: 1;
&:hover {
  color: #fff;
  text-decoration: none;
}
}

/* footer */

footer {
  margin-top: 45px;
  padding-top: 5px;
  border-top: 1px solid #eaeaea;
  color: $lightGray;
 a {
  color: #555;


&:hover {
  color: #222;
}
}
  small {
  float: left;
}

  ul {
  float: right;
  list-style: none;

  li {
  float: left;
  margin-left: 10px;
}
}
}

/* sidebar */

aside {
  section {
    padding: 10px 0;
    border-top: 1px solid $grayLighter;
    &:first-child {
      border: 0;
      padding-top: 0;
    }
    span {
      display: block;
      margin-bottom: 3px;
      line-height: 1;
    }
    h1 {
      font-size: 1.4em;
      text-align: left;
      letter-spacing: -1px;
      margin-bottom: 3px;
      margin-top: 0px;
    }
  }
}

.gravatar {
  float: left;
  margin-right: 10px;
}

.stats {
  overflow: auto;
  a {
    float: left;
    padding: 0 10px;
    border-left: 1px solid $grayLighter;
    color: gray;
    &:first-child {
      padding-left: 0;
      border: 0;
    }
    &:hover {
      text-decoration: none;
      color: $blue;
    }
  }
  strong {
    display: block;
  }
}

.user_avatars {
  overflow: auto;
  margin-top: 10px;
  .gravatar {
    margin: 1px 1px;
  }
}

/* forms */

input, textarea, select, .uneditable-input {
  border: 1px solid #bbb;
  width: 100%;
  margin-bottom: 15px;
  @include box_sizing;
}

input {
  height: auto !important;
}
#error_explanation {
  color: #f00;
  ul {
    list-style: none;
    margin: 0 0 18px 0;
  }
}

.field_with_errors {
  @extend .control-group;
  @extend .error;
}

/* Users index */

.users {
  list-style: none;
  margin: 0;
  li {
    overflow: auto;
    padding: 10px 0;
    border-top: 1px solid $grayLighter;
    &:last-child {
      border-bottom: 1px solid $grayLighter;
    }
  }
}

/* microposts */

.microposts {
  list-style: none;
  margin: 10px 0 0 0;

  li {
    padding: 10px 0;
    border-top: 1px solid #e8e8e8;
  }
}
.content {
  display: block;
}
.timestamp {
  color: $grayLight;
}
.gravatar {
  float: left;
  margin-right: 10px;
}
aside {
  textarea {
    height: 100px;
    margin-bottom: 5px;
  }
}
    EOF
    end
  end
end
# CONTROLLERS
inside 'app/controllers' do
  remove_file 'application_controller.rb'
  create_file 'application_controller.rb' do <<-EOF
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
end
  EOF
  end

  remove_file "users_controller.rb"
  create_file 'users_controller.rb' do <<-EOF
class UsersController < ApplicationController
  before_action :signed_in_user,
                only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end 
end
  EOF
  end

  remove_file 'microposts_controller.rb'
  create_file 'microposts_controller.rb' do <<-EOF
class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
  EOF
  end

  remove_file 'relationships_controller.rb'
  create_file 'relationships_controller.rb' do <<-EOF
class RelationshipsController < ApplicationController
  before_action :signed_in_user

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
  EOF
  end

  remove_file 'sessions_controller.rb'
  create_file 'sessions_controller.rb' do <<-EOF
class SessionsController < ApplicationController

  def new
  end

 def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
  EOF
  end

  remove_file 'static_pages_controller.rb'
  create_file 'static_pages_controller.rb' do <<-EOF
class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end
  
  def about
  end

  def contact
  end
end
  EOF
  end
end

inside 'app/helpers' do
  remove_file 'application_helper.rb'
  create_file 'application_helper.rb' do <<-EOF
module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      base_title + "|" + page_title
    end
  end
end
  EOF
  end

  remove_file 'sessions_helper.rb'
  create_file 'sessions_helper.rb' do <<-EOF
module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.encrypt(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end
end
  EOF
  end

  remove_file 'users_helper.rb'
  create_file 'users_helper.rb' do <<-EOF
module UsersHelper
  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "http://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
  EOF
  end
end

# MODELS
inside 'app/models' do
  remove_file 'micropost.rb'
  create_file 'micropost.rb' do <<-EOF
class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC') }
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  # Returns microposts from the users being followed by the given user.
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (" + followed_user_ids + ") OR user_id = :user_id",
          user_id: user.id)
  end
end
  EOF
  end
  remove_file 'relationship.rb'
  create_file 'relationship.rb' do <<-EOF
class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
  EOF
  end
  remove_file 'user.rb'
  regex = '/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i'
  create_file 'user.rb' do <<-EOF
class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  before_save { self.email = email.downcase }
  before_create :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = #{regex}
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
    # Это предварительное решение. См. полную реализацию в "Following users".
    Micropost.where("user_id = ?", id)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
  EOF
  end
end
# VIEWS
inside 'app/views' do
  # LAYOUTS
  inside 'layouts' do
    remove_file '_footer.html.slim'
    create_file '_footer.html.slim' do <<-EOF
footer.footer
  small
    a href="http://railstutorial.org/" Rails Tutorial by Michael Hartl
  nav
    ul
      li = link_to "About",   about_path
      li = link_to "Contact", contact_path
      li 
        a href = "http://news.railstutorial.org/" News
EOF
    end

    remove_file '_header.html.slim'
    create_file '_header.html.slim' do <<-EOF
header.navbar.navbar-fixed-top.navbar-inverse
  .navbar-inner
    .container
      = link_to "sample app", root_path, id: "logo"
      nav
        ul.nav.pull-right
          li = link_to "Home", root_path
          li = link_to "Help", help_path
          - if signed_in?
            li = link_to "Users", users_path
            li.fat-menu.dropdown
              a href="#" class="dropdown-toggle" data-toggle="dropdown"
                Account 
                  b.caret
              ul.dropdown-menu
                li = link_to "Profile", current_user
                li = link_to "Settings", edit_user_path(current_user)
                li.divider
                li = link_to "Sign out", signout_path, method: "delete"
          - else
            li = link_to "Sign in", signin_path

    EOF
    end
    remove_file '_shim.html.slim'
    create_file '_shim.html.slim' do <<-EOF
<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
    EOF
    end
    remove_file 'application.html.erb'
    create_file 'application.html.slim' do <<-EOF
doctype html
html
  head
    title
      = full_title(yield(:title))
    = stylesheet_link_tag "application", media: "all",
                                           "data-turbolinks-track" => true
    = javascript_include_tag "application", "data-turbolinks-track" => true
    = csrf_meta_tags
    = render 'layouts/shim'
  body
    = render 'layouts/header'
    .container
      - flash.each do |key, value|
        .alert.alert
          = key
        = value
      = yield
      = render 'layouts/footer'
      = debug(params) if Rails.env.development?
    EOF
    end
  end 

  # MICROPOSTS
  remove_dir "microposts"
  empty_directory "microposts"
  inside 'microposts' do
    create_file '_micropost.html.slim' do <<-EOF
li
  span.content
    = micropost.content
  span.timestamp
    'Posted 
    =' time_ago_in_words(micropost.created_at) 
    'ago.
  - if current_user?(micropost.user)
    = link_to "delete", micropost, method: :delete,
                                     data: { confirm: "You sure?" },
                                     title: micropost.content
    EOF
    end
  end
  # RELATIONSHIPS
  remove_dir "relationships"
  empty_directory "relationships"
  inside 'relationships' do
    create_file 'create.js.erb' do <<-EOF
$("#follow_form").html("<%= escape_javascript(render('users/unfollow')) %>")
$("#followers").html('<%= @user.followers.count %>')
    EOF
    end
    create_file 'destroy.js.erb' do <<-EOF
$("#follow_form").html("<%= escape_javascript(render('users/follow')) %>")
$("#followers").html('<%= @user.followers.count %>')
    EOF
    end
  end 
  # SESSIONS
  remove_dir "sessions"
  empty_directory "sessions"
  inside 'sessions' do
    create_file 'new.html.slim' do <<-EOF
-provide(:title, "Sign in")
h1 Sign in

.row
  .span6.offset3
    = form_for(:session, url: sessions_path) do |f|
      = f.label :email
      = f.text_field :email
      = f.label :password
      = f.password_field :password
      = f.submit "Sign in", class: "btn btn-large btn-primary"
    p 
      'New user?
      = link_to "Sign up now!", signup_path
    EOF
    end
  end

  # SHARED
  remove_dir 'shared'
  empty_directory 'shared'
  inside 'shared' do
    create_file '_error_messages.html.slim' do <<-EOF
-if object.errors.any?
  #error_explanation
    .alert.alert-error The form contains errors.
    ul
    - object.errors.full_messages.each do |msg|
      li = msg
    EOF
    end
    create_file '_feed.html.slim' do <<-EOF
-if @feed_items.any?
  ol.microposts
    = render partial: 'shared/feed_item', collection: @feed_items
  = will_paginate @feed_items
    EOF
    end
    create_file '_feed_item.html.slim' do <<-EOF
li
  = link_to gravatar_for(feed_item.user), feed_item.user
  span class="user"
      = link_to feed_item.user.name, feed_item.user
  span.content
    = feed_item.content
  span.timestamp 
    |Posted 
    = time_ago_in_words(feed_item.created_at)
    | ago.
- if current_user?(feed_item.user)
  = link_to "delete", feed_item, method: :delete,
                                   data: { confirm: "You sure?" },
                                   title: feed_item.content
    EOF
    end
    create_file '_micropost_form.html.slim' do <<-EOF
  = form_for(@micropost) do |f|
    = render 'shared/error_messages', object: f.object
    .field
      = f.text_area :content, placeholder: "Compose new micropost..."
    = f.submit "Post", class: "btn btn-large btn-primary"
    EOF
    end
    create_file '_stats.html.slim' do <<-EOF
- @user ||= current_user
.stats
  a href = following_user_path(@user)
    strong#following.stat
      = @user.followed_users.count
    |following
  a href = followers_user_path(@user)
    strong#followers.stat
      = @user.followers.count
    |followers
    EOF
    end
    create_file '_user_info.html.slim' do <<-EOF
= link_to gravatar_for(current_user, size: 52), current_user
h1
  = current_user.name
span
  = link_to "view my profile", current_user
span
  = pluralize(current_user.microposts.count, "micropost")
    EOF
    end
  end
  # STATIC PAGES
  remove_dir 'static_pages'
  empty_directory 'static_pages'
  inside 'static_pages' do
    create_file 'about.html.slim' do <<-EOF
- provide(:title, 'About Us')
h1 About Us
p
  |The 
  a href="http://railstutorial.org/" Ruby on Rails Tutorial 
  |is a project to make a book and screencasts to teach web development 
  |with 
  a href="http://rubyonrails.org/" Ruby on Rails. 
  |This is the sample application for the tutorial.
    EOF
    end
    create_file 'contact.html.slim' do <<-EOF
- provide(:title, 'Contact')
h1 Contact
p
  |Contact Ruby on Rails Tutorial about the sample app at the 
  a href="http://railstutorial.org/contact" contact page.
    EOF
    end
    create_file 'example_user.rb' do <<-EOF
class User
  attr_accessor :name, :email

  def initialize(attributes = {})
    @name  = attributes[:name]
    @email = attributes[:email]
  end

  def formatted_email
    @name+ <+@email+>
  end
end
    EOF
    end
    create_file 'help.html.slim' do <<-EOF
doctype html
html
  head
    title Ruby on Rails Tutorial Sample App
  body
    h1 Help
    p
      |Get help on the Ruby on Rails Tutorial at the 
      a href="http://railstutorial.org/help" Rails Tutorial help page. 
      |To get help on this sample app, see the 
      a href="http://railstutorial.org/book" Rails Tutorial book.
    EOF
    end 

    create_file 'home.html.slim' do <<-EOF
- if signed_in?
  .row
    aside.span4
      section
        = render 'shared/user_info'
      section
        = render 'shared/stats'
      section
        = render 'shared/micropost_form'
    .span8
        h3 Micropost Feed
        = render 'shared/feed'
- else
  .center.hero-unit
    h1 Welcome to the Sample App
    h2
      |This is the home page for the
      a href="http://railstutorial.org/" Ruby on Rails Tutorial 
      |sample application.
    = link_to "Sign up now!", signup_path, class: "btn btn-large btn-primary"
  = link_to image_tag("rails.png", alt: "Rails"), 'http://rubyonrails.org/'

    EOF
    end   
  end
  # USERS
  remove_dir 'users'
  empty_directory 'users'
  inside 'users' do
    create_file '_follow.html.slim' do <<-EOF
= form_for(current_user.relationships.build(followed_id: @user.id),remote: true) do |f|
  div = f.hidden_field :followed_id
  = f.submit "Follow", class: "btn btn-large btn-primary"
    EOF
    end
    create_file '_follow_form.html.slim' do <<-EOF
- unless current_user?(@user)
  div#follow_form
  - if current_user.following?(@user)
    = render 'unfollow'
  - else
    = render 'follow'
    EOF
    end
    create_file '_unfollow.html.slim' do <<-EOF
= form_for(current_user.relationships.find_by(followed_id: @user),html: { method: :delete },remote: true) do |f|
  = f.submit "Unfollow", class: "btn btn-large"
    EOF
    end
    create_file '_user.html.slim' do <<-EOF
li
  = gravatar_for user, size: 52
  = link_to user.name, user
  - if current_user.admin? && !current_user?(user)
    | = link_to "delete", user, method: :delete, data: { confirm: "You sure?" }

    EOF
    end
    create_file 'edit.html.slim' do <<-EOF
- provide(:title, "Edit user")
h1 Update your profile

.row
  .span6.offset3
    = form_for(@user) do |f|
      = render 'shared/error_messages', object: f.object

      = f.label :name
      = f.text_field :name

      = f.label :email
      = f.text_field :email

      = f.label :password
      = f.password_field :password

      = f.label :password_confirmation, "Confirm Password" 
      = f.password_field :password_confirmation

      = f.submit "Save changes", class: "btn btn-large btn-primary"

    = gravatar_for(@user)
    a href="http://gravatar.com/emails" change

    EOF
    end
    create_file 'index.html.slim' do <<-EOF
- provide(:title, 'All users')
h1 All users

= will_paginate

ul.users
  = render @users

= will_paginate
    EOF
    end
    create_file 'new.html.slim' do <<-EOF
- provide(:title, 'Sign up')
h1 Sign up

.row
  .span6.offset3
    = form_for(@user) do |f|
      = render 'shared/error_messages', object: f.object
      = f.label :name
      = f.text_field :name

      = f.label :email
      = f.text_field :email

      = f.label :password
      = f.password_field :password

      = f.label :password_confirmation, "Confirmation"
      = f.password_field :password_confirmation

      = f.submit "Create my account", class: "btn btn-large btn-primary"
    EOF
    end
    create_file 'show.html.slim' do <<-EOF
- provide(:title, @user.name)
.row
  aside.span4
    section
      h1
        = gravatar_for @user
        = @user.name
    section
      = render 'shared/stats'
  .span8
    = render 'follow_form' if signed_in?
    - if @user.microposts.any?
      h3 
        |Microposts 
        = @user.microposts.count
      ol.microposts
        = render @microposts
      = will_paginate @microposts
    EOF
    end
    create_file 'show_follow.html.slim' do <<-EOF
- provide(:title, @title)
.row
  aside.span4
    section
      = gravatar_for @user
      h1 = @user.name
      span = link_to "view my profile", @user 
      span 
      b Microposts: 
      = @user.microposts.count
    section
      = render 'shared/stats'
      - if @users.any?
        .user_avatars
          - @users.each do |user|
            = link_to gravatar_for(user, size: 30), user
  .span8
    h3 = @title
    - if @users.any?
      ul.users
        = render @users
      = will_paginate
    EOF
    end
  end 
end
run 'rake db:drop'
run 'rake db:create'
run 'rake db:migrate'
run 'rails s'
          # Создать пустую директорию
            # empty_directory "schema/schemata"

          # Внутри папки
            # inside 'config' do

            # end

          # удалить файл
            # remove_file 'app/controllers/users_controller.rb'

          # создать файл с вложенным текстом
            # create_file 'users_controller.rb' do <<-EOF

            # EOF
            # end

          # запустить команду в терминале
            # run "touch Gemfile"

          # вставить в файл блок после строки
            # insert_into_file 'app/controllers/users_controller.rb', after: "class User < ActiveRecord::Base\n" do <<-RUBY

            #   RUBY
            #   end

          # cпросить  
            # if yes?("Would you like to create your name?")
          
          # ввести переменную
            # model_name = ask("What would you like the name? [user]")
          
          # копировать файл
            # copy_file "app/controllers/users_controller.rb"

            # Health Check route
            # generate(:controller, "health index")
            # route "root to: 'health#index'"

            # git :init
            # git add: "."
            # git commit: "-a -m 'Initial commit'"
