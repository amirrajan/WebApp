Rails.application.routes.draw do
  get 'welcome/index'
  get 'welcome/login'
  root 'welcome#index'
end
