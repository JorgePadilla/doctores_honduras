Rails.application.routes.draw do
  get "payments/show"
  # Onboarding flow routes
  get "onboarding/profile_type", to: "onboarding#profile_type_selection", as: :onboarding_profile_type
  post "onboarding/profile_type", to: "onboarding#save_profile_type", as: :onboarding_save_profile_type
  get "onboarding/basic_info", to: "onboarding#basic_info", as: :onboarding_basic_info
  post "onboarding/complete", to: "onboarding#complete", as: :onboarding_complete
  
  # Payment route for subscription
  get 'payment', to: 'payments#show', as: :payment
  get "products/index"
  get "products/show"
  resources :suppliers, path: "proveedores", only: [ :index, :show ] do
    resources :products, only: [ :index, :show ], path: "productos"
    resources :lead_contacts, only: [ :new, :create ], path: "contacto"
  end

  # Vendor dashboard
  namespace :vendor do
    resource :profile, only: [ :show, :edit, :update ]
    resources :products, path: "productos"
    resources :leads, only: [ :index, :show, :update ], path: "contactos"
  end
  resource :session
  resources :passwords, param: :token
  resources :doctors, only: [:index, :show] do
    resource :booking, only: [:new, :create] do
      get :slots, on: :collection
    end
  end

  # Paciente namespace
  namespace :paciente do
    resources :appointments, only: [:index, :show]
    resource :profile, only: [:show, :edit, :update]
  end

  # Agenda (doctor + secretary)
  namespace :agenda do
    resources :appointments
    resource  :settings, only: [:show, :update]
    resources :secretaries, only: [:index, :new, :create, :destroy]
    resources :slots, only: [:index]
    resources :patients, only: [:index, :show] do
      collection { get :search }
    end
    resources :notifications, only: [:index] do
      member do
        patch :mark_as_read
      end
      collection do
        patch :mark_all_as_read
      end
    end
  end
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
  
  # Settings routes
  get "settings" => "settings#index", as: :settings
  get "settings/account" => "settings#account", as: :settings_account
  get "settings/subscription" => "settings#subscription", as: :settings_subscription
  post "settings/subscribe" => "settings#subscribe", as: :settings_subscribe
  post "settings/process_payment" => "settings#process_payment", as: :settings_process_payment
  delete "settings/cancel_subscription" => "settings#cancel_subscription", as: :settings_cancel_subscription
  get "settings/notifications" => "settings#notifications", as: :settings_notifications
  patch "settings/notifications" => "settings#update_notifications"
  get "settings/security" => "settings#security", as: :settings_security
  get "settings/language" => "settings#language", as: :settings_language
  patch "settings/language" => "settings#update_language"
  
  # Stripe routes
  post "stripe/create_checkout_session" => "stripe#create_checkout_session", as: :stripe_checkout
  get "stripe/success" => "stripe#success", as: :stripe_success
  get "stripe/cancel" => "stripe#cancel", as: :stripe_cancel
  post "stripe/webhook" => "stripe#webhook", as: :stripe_webhook
  
  # Profile routes
  resource :profile, only: [:show, :new, :create, :edit, :update]

  # Specialty routes for subespecialties and services
  resources :specialties, only: [] do
    get 'subspecialties', on: :member
    get 'services', on: :member
  end

  # Department cities JSON endpoint
  resources :departments, only: [] do
    get 'cities', on: :member
  end

  # Service find or create endpoint
  post 'services/find_or_create', to: 'services#find_or_create'

  # Admin routes
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'users', to: 'dashboard#users'
    get 'doctors', to: 'dashboard#doctors'
    get 'subscriptions', to: 'dashboard#subscriptions'
    post 'doctors/:id/toggle_visibility', to: 'dashboard#toggle_doctor_visibility', as: 'toggle_doctor_visibility'
  end

  # Defines the root path route ("/")
  root "home#index"
end
