Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
  get '/:id', to: 'chat_rooms#show'
  resources :chat_rooms, only: [:create]
  root to: 'chat_rooms#new'
end
