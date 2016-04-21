class AddCompatibilityToSubject < ActiveRecord::Migration
  def change
    add_column(:subjects, :compatibility, :string)
  end
end
