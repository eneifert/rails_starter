Rails.application.routes.draw do    
  
  scope "(:locale)", locale: /en/ do    

    resources :permissions
    resources :roles
    
    devise_for :users, controllers: { sessions: "sessions", passwords: "passwords" }, :path_prefix => 'devise'
    devise_scope :user do 
      get '/devise/users/sign_out' => 'sessions#destroy'
    end      

    resources :users

    get 'todo', to: 'home#todo', as: :todo

    get 'test' , to: 'tests#index'    
    # get 'super_secret_route_that_clears_outs_the_stuff_yo', to: 'tests#super_secret_route_that_clears_outs_the_stuff_yo'
    root 'home#index'
  end
end
