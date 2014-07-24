Spree::Core::Engine.routes.draw do
  namespace :api, :defaults => { :format => 'json' } do
    resources :products do
      member do
        get :show_redbox
      end
    end
  end
end
