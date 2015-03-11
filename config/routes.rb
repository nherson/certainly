Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

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
  
  scope :api do
    scope :v1 do
      get 'cas/:id/info', :to => 'api/v1/certificate_authorities#info', :as => 'ca_info'
      get 'cas/:id/ca_cert', :to => 'api/v1/certificate_authorities#ca_cert', :as => 'ca_cert'
      resources :cas, :only => [ :create, :destroy], :controller => 'api/v1/certificate_authorities'  do
        #resource :profile, :only => [:create, :show, :update, :destroy]
        resources :certs, :only => [:create, :show], :controller => 'api/v1/certificates', as: 'certificates'
        put 'certs/:id/revoke', :to => 'api/v1/certificates#revoke', as: 'api/v1/revoke_certificate'
        get 'certs/:id/pem', to: 'api/v1/certificates#pem', as: 'pem_certificate'
        resource :crl, :only => [:create, :show]
        # get 'crl/publish', :to => 'crls#publish'
      end
    end
  end

end
