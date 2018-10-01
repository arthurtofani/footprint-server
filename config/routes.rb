Rails.application.routes.draw do
  resources :media do
    collection do
      post 'query'
      post 'clear'
    end
  end
end
