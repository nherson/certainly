Rails.application.routes.draw do
 
  scope :api do
    scope :v1 do
      get 'cas/:id/info', to: 'api/v1/certificate_authorities#info', as: 'ca_info'
      get 'cas/:id/pem', to: 'api/v1/certificate_authorities#pem', as: 'ca_pem'
      get 'cas/:id/der', to: 'api/v1/certificate_authorities#der', as: 'ca_der'
      resources :cas, only: [ :create, :destroy], controller: 'api/v1/certificate_authorities'  do
        resources :certs, only: [ :create ], controller: 'api/v1/certificates'
        put 'certs/:id/revoke', to: 'api/v1/certificates#revoke', as: 'revoke_certificate'
        get 'certs/:id/pem', to: 'api/v1/certificates#pem', as: 'certificate_pem'
        get 'certs/:id/der', to: 'api/v1/certificates#der', as: 'der_certificate_der'
        get 'certs/:id/info', to: 'api/v1/certificates#info', as: 'certificate_info'
        # resource :profile, :only => [:create, :show, :update, :destroy]
        # resource :crl, :only => [:create, :show]
        # get 'crl/publish', :to => 'crls#publish'
      end
    end
  end

end
