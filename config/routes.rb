Spree::Core::Engine.routes.draw do
  # Add your extension routes here

    namespace :api, defaults: { format: 'json' } do
      put '/fulfillments/:id/start', to: 'fulfillments#start'
    end

    namespace :admin do
      resources :shipping_lists
    end

end
