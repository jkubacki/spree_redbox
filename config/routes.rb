Spree::Core::Engine.routes.draw do
  namespace :api, :defaults => { :format => 'json' } do
    resources :products do
      member do
        get :update_redbox
      end
    end
  end
  namespace :admin do
    resources :redbox_products do
      collection do
        put :update_multiple
      end
    end
  end
end
