Taxi::Application.routes.draw do
  scope '/users', controller: 'users' do
    get 'share/:ref' => :share          #reqvest example:    localhost:3000/users/share/d6450d9f689653d6548ea7b51103073e
    get 'register'   => :register       #reqvest example:    localhost:3000/users/register?device_id=1&email=Ua1@gmail.com&phone=3232323232323
    get 'reports'    => :reports_user   #report customers    request example: localhost:3000/users/reports?
    get 'reports_all'=> :reports_all
  end

  scope '/drivers', controller: 'drivers' do
    get 'share'      => :share             #reqvest example: localhost:3000/drivers/share/d6450d9f689653d6548ea7b51103073e
    get 'register'   => :register          #reqvest example: localhost:3000/drivers/register?device_id=2&phone=22222222222&email=Da1@gmail.com&name=DIK&car_id=AB1478521&brand=volkswagen
    get 'reports'    => :reports_driver    #report customers request example: localhost:3000/users/reports?
    get 'reports_all'=> :reports_all
  end

  resources :users, :only => [] do
    get 'point'     => :point      #check points when the application  request example: localhost:3000/users/<id>2/point
    get 'order'     => :order      #order taxi                         request example: localhost:3000/users/<id>4/order?country=Russia&city=Moscow&street=Minsk&house=55&gps_lat_user=32.084229&gps_long_user=34.888008 #address=moscva,mogevelovay5/4
    get 'status'    => :status     #status order                       request example: localhost:3000/users/<id>1/status?order_id=1
    get 'cancel'    => :cancel     #cansel from order                  request example: localhost:3000/users/<id>4/cancel?order_id=4
    get 'payment'   => :payment    #payment order points               request example: localhost:3000/users/<id>4/payment?points=2
    get 'withdrawn' => :withdrawn  #user took the driver               request example: localhost:3000/users/<id>/withdrawn?order_id=1

    get 'reserved'  => :reserved   #reserved order


  end

  resources :drivers, :only => [] do
    #reqvest list of orders
    get 'point'     => :point      #check points when the application  request example: localhost:3000/drivers/2/point
    get 'order'     => :order      #order list users                   request example: localhost:3000/drivers/2/order?gps_long_driver=34.884757&gps_lat_driver=32.084041
    get 'accept'    => :accept     #option of ordering                 request example: localhost:3000/drivers/<id>2/accept?order_id=1&gps_long_drivers=45.471325&gps_lat_drivers=45.587214
    get 'cancel'    => :cancel     #cansel from order                  request example: localhost:3000/drivers/<id>1/cancel?order_id=1
    get 'status'    => :status     #check order status driver          request example: localhost:3000/drivers/1/status?order_id=2&gps_long_drivers=34.884757&gps_lat_drivers=32.084055
    get 'took'      => :took       #driver took Users                  request example: localhost:3000/drivers/<id>/took?order_id=1

    get 'delivered' => :delivered  #
  end


  
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
