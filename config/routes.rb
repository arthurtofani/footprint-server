Rails.application.routes.draw do
  resources :media do
    collection do
      post 'query'
      post 'clear'
      get 'stats'
    end
  end
end
