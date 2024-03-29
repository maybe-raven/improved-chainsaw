defmodule Hnet.Router do
  use Hnet.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Hnet.Account.Plugs.AssignUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hnet do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/patient", PageController, :patient
    get "/admin", PageController, :administrator
    get "/doctor", PageController, :doctor
    get "/nurse", PageController, :nurse
    resources "/hospitals", HospitalController
  end

  scope "/", Hnet.Account do
    pipe_through :browser

    get "/login", AuthController, :signin
    post "/login", AuthController, :login
    post "/logout", AuthController, :logout
    resources "/users", UserController, only: [:index, :show, :delete]
    get "/profile", UserController, :edit_profile
    put "/profile", UserController, :update_profile
  end

  scope "/registration", Hnet.Account do
    pipe_through :browser

    get "/", RegistrationController, :index
    get "/patient", RegistrationController, :new_patient
    post "/patient", RegistrationController, :create_patient
    get "/admin", RegistrationController, :new_administrator
    post "/admin", RegistrationController, :create_administrator
    get "/doctor", RegistrationController, :new_doctor
    post "/doctor", RegistrationController, :create_doctor
    get "/nurse", RegistrationController, :new_nurse
    post "/nurse", RegistrationController, :create_nurse
  end

  # Other scopes may use custom stacks.
  # scope "/api", Hnet do
  #   pipe_through :api
  # end
end
