Rails.application.routes.draw do
  get 'welcome/index'
  get 'welcome/login'
  get 'welcome/celebrity'
  get 'welcome/view_celebrity'
  post 'welcome/create_celebrity'
  root 'welcome#index'
end
