defmodule Hnet.RegistrationController.DoctorTest do
  use Hnet.ConnCase

  alias Hnet.Account.User
  alias Hnet.Account.Doctor
  import Hnet.DefaultModels

  @valid_attrs %{address: "Winterfell", email: "catelyn.stark@mail.com", gender: "female", 
                 first_name: "Catelyn", last_name: "Stark", phone: "1230984576",
                 username: "catstark", password: "phoenix", password_confirmation: "phoenix", 
                 doctor: %{hospital_id: nil}}
  @invalid_attrs %{}

  test "registration page", %{conn: conn} do
    create_default_hospital()
    user_id = create_default_administrator().id

    conn
    |> login(user_id)
    |> get(registration_path(conn, :new_doctor))
    |> assert_conn(:success, "New Doctor")
  end

  test "registration with valid attrs", %{conn: conn} do
    # Prepare the doctor data.
    hospital_id = create_default_hospital().id
    user_id = create_default_administrator().id
    params = set_hospital_id(@valid_attrs, hospital_id)

    # Send the request & check the response.
    conn = login conn, user_id
    conn = post conn, registration_path(conn, :create_doctor), user: params
    assert redirected_to(conn) == user_path(conn, :index)

    # Check session.
    assert get_session(conn, :current_user_id) == user_id

    # Check database.
    new_user = Repo.get_by(User, username: @valid_attrs.username)
    assert new_user
    assert new_user.account_type == :doctor
    assert Repo.get_by(Doctor, user_id: new_user.id)
  end

  test "registration with invalid attrs", %{conn: conn} do
    # Prepare the doctor data.
    create_default_hospital()
    user_id = create_default_administrator().id
    
    # Send the request & check the response.
    conn = login conn, user_id
    conn = post conn, registration_path(conn, :create_doctor), user: @invalid_attrs
    assert html_response(conn, 200) =~ "something went wrong"

    # Check that the new user is automatically logged in.
    assert get_session(conn, :current_user_id) == user_id

    # Check database.
    assert Repo.aggregate(User, :count, :id) == 1
  end

  test "registration page not logged in", %{conn: conn} do
    create_default_hospital()

    conn = get conn, registration_path(conn, :new_doctor)
    assert redirected_to(conn) =~ auth_path(conn, :signin)
  end

  test "registration not logged in", %{conn: conn} do
    # Prepare the doctor data.
    hospital_id = create_default_hospital().id
    params = set_hospital_id(@valid_attrs, hospital_id)

    # Send the request & check the response.
    conn = post conn, registration_path(conn, :create_doctor), user: params
    assert redirected_to(conn) =~ auth_path(conn, :signin)

    # Check database.
    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(Doctor, :count, :id) == 0
  end

  test "registration page logged in as doctor", %{conn: conn} do
    create_default_hospital()
    user_id = create_default_doctor().id

    conn
    |> login(user_id)
    |> get(registration_path(conn, :new_doctor))
    |> assert_conn(:redirect, :similar_to, auth_path(conn, :signin))
  end

  test "registration logged in as doctor", %{conn: conn} do
    # Prepare the doctor data.
    hospital_id = create_default_hospital().id
    user_id = create_default_doctor().id
    params = set_hospital_id(@valid_attrs, hospital_id)

    # Send the request & check the response.
    conn
    |> login(user_id)
    |> post(registration_path(conn, :create_doctor), user: params)
    |> assert_conn(:redirect, :similar_to, auth_path(conn, :signin))

    # Check database.
    assert Repo.aggregate(User, :count, :id) == 1
    assert Repo.aggregate(Doctor, :count, :id) == 1
  end

  defp set_hospital_id(attrs, hospital_id) do
    Map.update!(attrs, :doctor, fn d ->
      %{d | hospital_id: hospital_id}
    end)
  end
end