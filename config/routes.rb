Rails.application.routes.draw do
  resources :buckets do
    resources :media, shallow: true
    member do
      get 'stats'
      post 'query'
      post 'clear'
    end
  end

end
