Rails.application.routes.draw do
  get "products/index"
  get "products/show"
  resources :suppliers, path: 'proveedores', only: [:index, :show] do
    resources :products, only: [:index, :show], path: 'productos'
  end
  resource :session
  resources :passwords, param: :token
  resources :doctors, only: [:index, :show]
  resources :establishments, only: [:index, :show], path: 'hospitales-y-clinicas'
  
  # User registration routes
  get "signup" => "users#new"
  post "signup" => "users#create"
  get "home/index"
  get "home/color_test"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Dashboard routes for authenticated users
  get "dashboard" => "dashboard#index", as: :dashboard
  
  # Defines the root path route ("/")
  root "home#index"
end
