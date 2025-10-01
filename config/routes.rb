Rails.application.routes.draw do
  # Public routes
  get "home/index"
  resource :session
  resource :registration, only: [:new, :create]  # 添加这行
  resources :passwords, param: :token
  
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
  root "sessions#new"
end
