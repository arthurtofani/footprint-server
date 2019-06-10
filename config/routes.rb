Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :buckets do
    resources :media, shallow: true
    member do
      get 'stats'
      post 'query'
      post 'clear'
      get 'integrity'
    end
  end

end
