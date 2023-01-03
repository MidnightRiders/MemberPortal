json.partial! 'user', user: @user
json.jwt current_user.jwt
