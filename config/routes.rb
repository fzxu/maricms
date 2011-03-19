MariCMS::Application.routes.draw do
  
  resources :ds_trees do
    member do
      post 'move_up'
      post 'move_down'
    end
    collection do
      get 'datatable'
    end
  end

  resources :mg_urls do
    collection do
      get 'datatable'
    end
  end

  resources :ds_tabs do
  	member do
  		post 'move_up'
  		post 'move_down'
  	end
    collection do
      get 'datatable'
    end
  end

  resources :ds_standards do
    member do
      post 'move_up'
      post 'move_down'
    end
    collection do
      get 'datatable'
    end
  end

  resources :ds do
  	member do
  		post 'create_ds_element'
  		delete 'destroy_ds_element'
  		get 'manage'
  	end
    collection do
      get 'datatable'
    end
  end

  resources :pages do
    collection do
      get 'datatable'
    end    
  end
  
  resources :mthemes do
    member do
      post 'sync'
    end
  end

  devise_for :users
  #resource :users, :only => [:new, :create, :edit, :update]
   
  # root
  root :controller => :pages, :action => :show

  themes_for_rails
  
  match 'editor_attachments/:action', :controller => :editor_attachments

	match 'manage(/:action)', :controller => :setting
	
	match 'dock(/:action)', :controller => :dock
	  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  match 'pages/:id/:alias' => 'pages#show'
  match ':alias' => 'pages#show'
  match ':id/:alias' => 'pages#show'
end
