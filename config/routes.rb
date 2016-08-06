Rails.application.routes.draw do
  root to: 'top#index'

  post '/top/tweet' => 'top#tweet', as: :tweet
  # For OmniAuth
  get "/auth/:provider/callback" => "sessions#callback"
  get "/auth/failure"            => "sessions#failure"
  get "/logout"                  => "sessions#destroy", as: :logout

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
