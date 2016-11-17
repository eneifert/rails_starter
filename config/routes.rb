Rails.application.routes.draw do  
  
  
  get 'home/index'

  devise_for :admin, controllers: { sessions: "admin/sessions" }
  devise_scope :admin do 
    get '/admin/sign_out' => 'admin/sessions#destroy'
  end
  resources :admins, path: 'admin/users', controller: 'admin/users'

  namespace :admin do
    # resources :survey_results

    get '', to: 'home#index', as: 'home'    
  end

  root 'home#index'
end
