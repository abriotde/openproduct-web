module CreateTablePersons

import SearchLight.Migrations: create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
  create_table(:persons) do
    [
      pk()
      column(:firstname, :string, limit = 100)
      column(:lastname, :string, limit = 100)
      column(:phoneNumber, :integer)
      column(:email, :string, limit = 250)
      column(:country, :string, limit = 100)
      column(:member, :integer)
      column(:address, :string, limit = 512)
      column(:postcode, :integer)
      column(:city, :string, limit = 512)
      column(:producer, :integer)
      column(:options, :string, limit = 100)
      column(:notes, :string, limit = 1_000)
    ]
  end

	add_index(:persons, :email)
	add_index(:persons, :address)
    # add_index(:persons, [:firstname, :lastname])
end

function down()
  drop_table(:persons)
end

end
