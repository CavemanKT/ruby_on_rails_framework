Rails.application.routes.draw do
  # Public routes
  get "home/index"
  resource :session
  resource :registration, only: [:new, :create]
  resources :passwords, param: :token
  
  # Profile routes
  resource :profile, only: [:show, :edit, :update]
  
  # Community routes
  resources :posts do
    member do
      post :like
    end
    resources :comments, except: [:show, :index]
  end
  
  # Breathing exercises
  resources :breathing_exercises, path: 'breathing' do
    member do
      get :completed
      post :finish
      get :debug # 添加调试路由
    end
    collection do
      get :history
    end
  end
  
  # Reports
  resources :reports, only: [:new, :create]
  get 'reports/new', to: 'reports#new'
  
  # Admin namespace
  namespace :admin do
    # ... 现有管理员路由
    root to: "dashboard#index"
    
    resources :reports, only: [:index, :show] do
      member do
        post :resolve
        post :dismiss
      end
    end
    
    resources :users, only: [:index, :show] do
      member do
        post :ban
        post :unban
      end
    end
    
    get "activity_log", to: "activity_log#index"
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")



  root "home#index"
end
