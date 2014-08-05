Shipper::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root "welcome#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get :login,   to: "sessions#new"
  get :logout,  to: "sessions#destroy"

  resources :sessions, only: [ :new, :create, :destroy ]

  # resources :users do
  #   resources :travels, except: [ :show, :new, :create ] # only: [ :index ]
  # end
  #
  # resources :travels, only: [ :show, :index, :new, :create ] do
  #   member do
  #     post  :take
  #   end
  #
  #   collection do
  #     get   :taken, to: "users#travels#show"
  #   end
  # end

  resources :users, only: [ :show ] do
    resources :travels, except: [ :show, :new, :create ] # only: [ :index ]

    collection do
      post  :adopt
    end
  end


  #
  # This separation is to assure :index, :new, :create actions' routes
  # take precedence of the other actions upon `travel` resource
  #

  resources :travels, only: [ :index, :new, :create ]

  resources :travels do
    member do

      # Allows to grab particular travel
      post  :take

      # Allows to query status of a particular travel
      get   :status

      get   :show, to: "travels#status"

    end

    collection do
      get   :taken
      get   :created

      get   :active
    end
  end


  #
  # Dashboard
  #

  # resources :dashboard, only: [ :show ]

  get :dashboard, to: "dashboard#show"


  #
  # Communications API
  #

  post  :send,  to: "communications#send0"
  get   :text,  to: "communications#text"


  #
  # Accounting API
  #

  get :account, to: "accounting#account"


  #
  # Administrative dashboard
  #

  namespace :admin do
    resources :users, only: [ :create, :new ] do
      get   :new,     to: "users#new"
      post  :create,  to: "users#create"
    end

    get "", to: "dashboard#show", as: "/"
  end

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
