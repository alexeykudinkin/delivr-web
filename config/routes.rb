Shipper::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root "welcome#index"
  root controller: :sessions, action: :new

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

  resources :travels, only: [ :index, :new, :create ] do
    collection do

      # Lists travels taken by user
      get :taken

      # Lists travels created by user
      get :created

      # Lists active travels
      get :active

    end

    resources :places, only: [] do
      member do

        # Notifies about courier arriving at particular place
        post :arrive

      end
    end
  end

  resources :travels, only: [] do
    member do

      # Grabs travel
      post :take

      # Cancels travel
      post :cancel

      # Completes travel
      post :complete

      # Allows to query status of a particular travel
      get :status

      get :show, to: "travels#status"

    end
  end


  #
  # Dashboard
  #

  # resources :dashboard, only: [ :show ]

  get :dashboard, to: "dashboard#show"

  #
  # API
  #

  # FIXME: Employ proper namespacing

  # namespace :api do
  scope :api do

    # FIXME: Impose proper versioning for the whole API interface

    # namespace :v1 do
    scope :v1 do

      # namespace :access do
      scope :access do

        post :grant,  to: "sessions#grant"
        post :revoke, to: "sessions#revoke"

      end

    end

  end

  namespace :api do

    namespace :v1 do

      scope :state do

        post :activate,   to: "states#activate"
        post :deactivate, to: "states#deactivate"

      end

    end
  end


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
  # Subscriptions API
  #

  namespace :app do
    post :subscribe, to: "subscribing#subscribe"
  end

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
