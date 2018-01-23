class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  include SessionsHelper
  $PageSize = 10   #每页10条记录
end
