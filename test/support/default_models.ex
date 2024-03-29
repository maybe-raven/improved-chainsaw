defmodule Hnet.DefaultModels do
  alias Hnet.Repo

  import Ecto.Query
  import Ecto.Changeset
  
  alias Hnet.Hospital
  alias Hnet.Account.User
  alias Hnet.Account.Doctor

  def create_default_hospital do
    record = %Hospital{name: "Baelor's Sept", location: "King's Landing"}
    Repo.insert!(record)
  end

  def create_default_user(username \\ "cerlann") do
    %User{address: "The Red Keep, King's Landing.'", email: "cersei.lannister@mail.com", 
          first_name: "Cersei", last_name: "Lannister", gender: "female", phone: "1230984576", 
          username: username, account_type: :doctor, password: "phoenix",
          password_hash: "$2b$12$EoAdWD1LeOKTdB67l5KLBO1hM9dkTy.dsSue8Ss9o/spzZs4g7Sr2"}
    |> Repo.insert!
  end

  def create_default_doctor(username \\ "hsparrow") do
    query = from h in Hospital, select: h.id, limit: 1
    hospital_id = List.first(Repo.all(query))
    %User{address: "Baelor's Sept", email: "high.sparrow@mail.com", first_name: "高",
          last_name: "麻雀", gender: "male", phone: "1890235467", username: username,
          account_type: :doctor, password: "phoenix",
          password_hash: "$2b$12$EoAdWD1LeOKTdB67l5KLBO1hM9dkTy.dsSue8Ss9o/spzZs4g7Sr2"}
    |> change
    |> put_assoc(:doctor, %{hospital_id: hospital_id})
    |> Repo.insert!
  end

  def create_default_nurse do
    query = from h in Hospital, select: h.id, limit: 1
    hospital_id = Repo.one(query)
    %User{address: "High Garden.", email: "margaery.tyrell@mail.com", first_name: "margaery",
          last_name: "Tyrell", gender: "female", phone: "0192384756", username: "martyrel",
          account_type: :nurse, password: "phoenix",
          password_hash: "$2b$12$EoAdWD1LeOKTdB67l5KLBO1hM9dkTy.dsSue8Ss9o/spzZs4g7Sr2"}
    |> change
    |> put_assoc(:nurse, %{hospital_id: hospital_id})
    |> Repo.insert!
  end

  def create_default_administrator do
    query = from h in Hospital, select: h.id, limit: 1
    hospital_id = List.first(Repo.all(query))
    %User{address: "Casterly Rock", email: "tyrion.lannister@mail.com", first_name: "Tyrion",
          last_name: "Lannister", gender: "male", phone: "1230897645", username: "tyrlan",
          account_type: :administrator, password: "phoenix",
          password_hash: "$2b$12$EoAdWD1LeOKTdB67l5KLBO1hM9dkTy.dsSue8Ss9o/spzZs4g7Sr2"}
    |> change
    |> put_assoc(:administrator, %{hospital_id: hospital_id})
    |> Repo.insert!
  end

  def create_default_patient do
    query = from d in Doctor, select: d.id, limit: 1
    doctor_id = List.first(Repo.all(query))

    %User{address: "Somewhere", email: "the.hound@mail.com", first_name: "Sandor",
          last_name: "Clegane", gender: "male", phone: "1230984576", username: "hound",
          account_type: :patient, password: "phoenix",
          password_hash: "$2b$12$EoAdWD1LeOKTdB67l5KLBO1hM9dkTy.dsSue8Ss9o/spzZs4g7Sr2"}
    |> change
    |> put_assoc(:patient, %{proof_of_insurance: "proof", primary_doctor_id: doctor_id})
    |> Repo.insert!
  end
end